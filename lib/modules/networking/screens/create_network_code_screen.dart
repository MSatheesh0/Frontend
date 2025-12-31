import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goal_networking_app/services/networking_service.dart';
import 'package:goal_networking_app/services/auth_service.dart';
import 'package:goal_networking_app/services/app_state.dart';
import 'package:goal_networking_app/models/network_code.dart';
import 'package:goal_networking_app/utils/theme.dart';

class CreateNetworkCodeScreen extends StatefulWidget {
  const CreateNetworkCodeScreen({super.key});

  @override
  State<CreateNetworkCodeScreen> createState() =>
      _CreateNetworkCodeScreenState();
}

class _CreateNetworkCodeScreenState extends State<CreateNetworkCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeIdController = TextEditingController();
  final _keywordsController = TextEditingController();
  bool _autoConnect = false;
  DateTime? _expiryDate;

  final List<String> _suggestedTags = [
    'Healthcare Technology',
    'AI service',
    'Fundraising',
    'Hospital Partnerships',
    'Startup',
    'Innovation',
    'Networking',
    'Investment',
    'Fintech',
    'Banking',
  ];

  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _nameController.dispose();
    _codeIdController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  Future<void> _generateNetworkCode() async {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        // Get current user ID from AuthService
        final authService = AuthService();
        final userId = authService.currentUser?['id'] ?? 'user_1';

        // Parse keywords
        final keywords = _keywordsController.text
            .split(',')
            .map((k) => k.trim())
            .where((k) => k.isNotEmpty)
            .toList();

        // Add selected tags to keywords
        keywords.addAll(_selectedTags);

        // Create network code using NetworkingService
        final networkCode = await NetworkingService().createNetworkCode(
          userId: userId,
          code: _codeIdController.text.toUpperCase().trim(),
          name: _nameController.text.trim(),
          description: keywords.take(3).join(', '),
          autoConnect: _autoConnect,
          expiresAt: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
          maxConnections: 100,
          tags: keywords,
        );

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Add network code to AppState (this will auto-select it)
        if (mounted) {
          final appState = Provider.of<AppState>(context, listen: false);
          final networkCodeModel = NetworkCode.fromJson(networkCode);
          appState.addNetworkCode(networkCodeModel);
          
          print('✅ Network code added to AppState and selected: ${networkCodeModel.codeId}');
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Network Code created and selected: ${networkCode['codeId'] ?? networkCode['code']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Go back and refresh
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Network Code',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                'Add your Network Code for sharable profile',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name of the Network Code',
                  hintText: 'Ex: Events, AI Meetup, Healthcare Circle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Code ID field
              TextFormField(
                controller: _codeIdController,
                decoration: InputDecoration(
                  labelText: 'Code ID',
                  hintText: 'Ex: john.ai, sam.health, kevin-fintech',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Code ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Auto connect toggle
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Enable auto-connect',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            'Automatically connect when Network Code is scanned',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoConnect,
                      onChanged: (value) {
                        setState(() {
                          _autoConnect = value;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Expiry Date Picker
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    helpText: 'Select Expiry Date',
                  );
                  
                  if (pickedDate != null && mounted) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      helpText: 'Select Expiry Time',
                    );
                    
                    if (pickedTime != null && mounted) {
                      setState(() {
                        _expiryDate = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expiry Date & Time',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXs),
                            Text(
                              _expiryDate != null
                                  ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year} ${_expiryDate!.hour}:${_expiryDate!.minute.toString().padLeft(2, '0')}'
                                  : 'Tap to set expiry date & time',
                              style: TextStyle(
                                color: _expiryDate != null ? AppTheme.primaryColor : AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),

              // Keywords field
              TextFormField(
                controller: _keywordsController,
                decoration: InputDecoration(
                  labelText: 'Keywords',
                  hintText: 'Ex: Healthcare, Technology',
                  helperText: 'Separate multiple keywords with commas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Suggested tags
              Text(
                'Suggested Tags',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Wrap(
                spacing: AppConstants.spacingSm,
                runSpacing: AppConstants.spacingSm,
                children: _suggestedTags.map<Widget>((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (mounted) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      }
                    },
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryColor,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingXl * 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: ElevatedButton(
            onPressed: _generateNetworkCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
            child: const Text(
              'Generate Network Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
