import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../services/app_state.dart';
import '../utils/theme.dart';

class CreateGoalScreen extends StatefulWidget {
  final String? eventId;
  final String? eventName;

  const CreateGoalScreen({
    super.key,
    this.eventId,
    this.eventName,
  });

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _offeringController = TextEditingController();
  final _needController = TextEditingController();

  String _selectedAssistance = 'Investor Finder';
  final List<String> _assistanceOptions = [
    'Investor Finder',
    'Talent Recruiter',
    'Partnership Builder',
    'Market Research',
    'Business Development',
  ];

  GoalRunScope _selectedRunScope = GoalRunScope.allNetwork;
  List<String> _selectedFollowingIds = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill task name with event context if provided
    if (widget.eventName != null) {
      _taskNameController.text = 'Connect at ${widget.eventName}';
    }
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _objectiveController.dispose();
    _offeringController.dispose();
    _needController.dispose();
    super.dispose();
  }

  void _showAssistanceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick your assistance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            ..._assistanceOptions.map((option) {
              final isSelected = option == _selectedAssistance;
              return ListTile(
                title: Text(
                  option,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                        color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedAssistance = option;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _createGoal() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);

      // Create tags from the offering and need fields
      final tags = <String>[];
      if (_offeringController.text.isNotEmpty) {
        tags.addAll(_offeringController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .take(3));
      }

      // Add event name as a tag if coming from event
      if (widget.eventName != null && !tags.contains(widget.eventName)) {
        tags.add(widget.eventName!);
      }

      final newGoal = Goal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _taskNameController.text,
        description: _objectiveController.text,
        tags: tags,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        status: GoalStatus.active,
        progress: 0,
        runScope: _selectedRunScope,
        selectedFollowingIds: _selectedFollowingIds,
        contextCircleId: widget.eventId, // Link to event circle
      );

      // Set the active goal in AppState
      appState.createGoal(newGoal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created! Your AI assistant is now working.'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Task',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                children: [
                  // Event context hint
                  if (widget.eventName != null)
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      margin:
                          const EdgeInsets.only(bottom: AppConstants.spacingLg),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          Expanded(
                            child: Text(
                              'Your assistant will match inside the ${widget.eventName} circle',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Task Name
                  _buildTextField(
                    controller: _taskNameController,
                    label: 'Task Name',
                    hint: 'Ex: Find Investors',
                    maxLines: 1,
                    showDone: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Objective
                  _buildTextField(
                    controller: _objectiveController,
                    label: 'Objective',
                    hint: 'What do you want to achieve?',
                    maxLines: 5,
                    showDone: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe your objective';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // What I offer
                  _buildTextField(
                    controller: _offeringController,
                    label: 'What I offer',
                    hint: 'What can you provide or share?',
                    maxLines: 5,
                    showDone: false,
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // What I need
                  _buildTextField(
                    controller: _needController,
                    label: 'What I need',
                    hint: 'What are you looking for?',
                    maxLines: 5,
                    showDone: false,
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Pick your assistance
                  Text(
                    'Pick your assistance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  InkWell(
                    onTap: _showAssistanceSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                        vertical: AppConstants.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedAssistance,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Where should your assistant run this task?
                  _buildRunScopeSection(),
                ],
              ),
            ),
            // Bottom button area
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: ElevatedButton(
                    onPressed: _createGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool showDone = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines > 1 ? 3 : 1,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          textInputAction: showDone
              ? TextInputAction.done
              : (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (value) {
            if (showDone) {
              FocusScope.of(context).unfocus();
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingMd,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRunScopeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where should your assistant run this task?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        _buildRunScopeOption(
          GoalRunScope.allNetwork,
          'Entire Network',
          'Search across all profiles and circles',
        ),
        const SizedBox(height: AppConstants.spacingSm),
        _buildRunScopeOption(
          GoalRunScope.followingsOnly,
          'People/Circles I Follow',
          'Only search within profiles and circles you follow',
        ),
        const SizedBox(height: AppConstants.spacingSm),
        _buildRunScopeOption(
          GoalRunScope.selectedCircles,
          'Custom Followings',
          'Select specific profiles or circles',
        ),
        if (_selectedRunScope == GoalRunScope.selectedCircles) ...[
          const SizedBox(height: AppConstants.spacingSm),
          _buildCustomFollowingSelector(),
        ],
      ],
    );
  }

  Widget _buildRunScopeOption(
    GoalRunScope scope,
    String title,
    String description,
  ) {
    final isSelected = _selectedRunScope == scope;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRunScope = scope;
          if (scope != GoalRunScope.selectedCircles) {
            _selectedFollowingIds = [];
          }
        });
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[400],
              size: 22,
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFollowingSelector() {
    final appState = Provider.of<AppState>(context, listen: false);
    final availableFollowings = appState.followState.followings;

    return InkWell(
      onTap: () => _showCustomFollowingPicker(availableFollowings),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedFollowingIds.isEmpty
                    ? 'Select profiles or circles'
                    : '${_selectedFollowingIds.length} selected',
                style: TextStyle(
                  fontSize: 15,
                  color: _selectedFollowingIds.isEmpty
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomFollowingPicker(List<dynamic> followings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLg),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Followings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Expanded(
                    child: ListView.separated(
                      itemCount: followings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppConstants.spacingSm),
                      itemBuilder: (context, index) {
                        final following = followings[index];
                        final isSelected =
                            _selectedFollowingIds.contains(following.id);

                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              setState(() {
                                if (isSelected) {
                                  _selectedFollowingIds.remove(following.id);
                                } else {
                                  _selectedFollowingIds.add(following.id);
                                }
                              });
                            });
                          },
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                          child: Container(
                            padding:
                                const EdgeInsets.all(AppConstants.spacingMd),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.08)
                                  : Colors.grey[50],
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusMd),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey[400],
                                ),
                                const SizedBox(width: AppConstants.spacingMd),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        following.label,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        following.role ?? following.type,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
