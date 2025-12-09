import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_service.dart';
import '../../../models/user_profile_auth.dart';
import 'assistant_enrichment_screen.dart';

/// Screen for collecting required user information during signup
/// Shows only for new users after OTP verification
class SignupDetailsScreen extends StatefulWidget {
  final String email;
  final AuthService authService;

  const SignupDetailsScreen({
    super.key,
    required this.email,
    required this.authService,
  });

  @override
  State<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends State<SignupDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedRole;
  String? _selectedGoal;
  String? _otherRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedRole != null &&
        _selectedGoal != null &&
        (_selectedRole != UserRole.other || _otherRole != null);
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate() || !_isFormValid) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final role =
          _selectedRole == UserRole.other ? _otherRole! : _selectedRole!;

      // Get current user from auth service (already has ID from backend)
      final currentUser = widget.authService.currentUser;
      if (currentUser == null) {
        throw Exception('No user session found');
      }

      // Create updated profile with user's input
      final profile = UserProfile(
        id: currentUser['id'], // Use existing ID from backend
        email: widget.email,
        name: _nameController.text.trim(),
        role: (_selectedRole == UserRole.other ? _otherRole : _selectedRole) ?? '',
        primaryGoal: _selectedGoal ?? '',
      );

      // TODO: Old auth system
      /* await widget.authService.saveUserProfile(profile); */
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use the new signup screen')),
      );

      if (!mounted) return;

      // Navigate to optional enrichment screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AssistantEnrichmentScreen(
            authService: widget.authService,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        automaticallyImplyLeading: false,
        title: Text(
          'Let\'s set up your assistant',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingXl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      Text(
                        'What\'s your name?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      TextFormField(
                        controller: _nameController,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Full name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: AppConstants.spacingXl),

                      // Role Selection
                      Text(
                        'What describes you best?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      ...UserRole.all.map((role) {
                        final isSelected = _selectedRole == role;
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.spacingSm),
                          child: InkWell(
                            onTap: _isLoading
                                ? null
                                : () => setState(() {
                                      _selectedRole = role;
                                    }),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(AppConstants.spacingMd),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusMd),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: AppConstants.spacingSm),
                                  Expanded(
                                    child: Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      // Other Role Input (if "Other" selected)
                      if (_selectedRole == UserRole.other) ...[
                        const SizedBox(height: AppConstants.spacingSm),
                        TextFormField(
                          enabled: !_isLoading,
                          decoration: InputDecoration(
                            hintText: 'Please specify your role',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusMd),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          onChanged: (value) => setState(() {
                            _otherRole =
                                value.trim().isEmpty ? null : value.trim();
                          }),
                        ),
                      ],

                      const SizedBox(height: AppConstants.spacingXl),

                      // Primary Goal
                      Text(
                        'What brings you here today?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      ...PrimaryGoal.all.map((goal) {
                        final isSelected = _selectedGoal == goal;
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.spacingSm),
                          child: InkWell(
                            onTap: _isLoading
                                ? null
                                : () => setState(() {
                                      _selectedGoal = goal;
                                    }),
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(AppConstants.spacingMd),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusMd),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: AppConstants.spacingSm),
                                  Expanded(
                                    child: Text(
                                      goal,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: AppConstants.spacingLg),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingMd, // 16px left
                AppConstants.spacingMd, // 16px top
                AppConstants.spacingMd, // 16px right
                AppConstants.spacingLg, // 24px bottom (for safe area)
              ),
              decoration: BoxDecoration(
                color: Colors.grey[50], // Match background
              ),
              child: SizedBox(
                width: double.infinity, // Full width
                child: ElevatedButton(
                  onPressed:
                      _isFormValid && !_isLoading ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
}
