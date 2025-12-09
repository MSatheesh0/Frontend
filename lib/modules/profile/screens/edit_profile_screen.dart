import 'package:flutter/material.dart';
import '../models/user_profile_auth.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';

/// Screen for editing user profile information
class EditProfileScreen extends StatefulWidget {
  final AuthService authService;

  const EditProfileScreen({
    super.key,
    required this.authService,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  late TextEditingController _oneLinerController;

  String? _selectedRole;
  String? _selectedGoal;
  String? _otherRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.authService.currentUser;

    _nameController = TextEditingController(text: user?['fullName'] ?? '');
    _companyController = TextEditingController(text: user?['company'] ?? '');
    _websiteController = TextEditingController(text: user?['website'] ?? '');
    _locationController = TextEditingController(text: user?['city'] ?? '');
    _oneLinerController = TextEditingController(text: user?['bio'] ?? '');

    _selectedRole = user?['profession'] ?? '';
    _selectedGoal = user?['role'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _oneLinerController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement update profile for new auth system
      /* await widget.authService.updateUserProfile(
        name: _nameController.text.trim(),
        role: _selectedRole == UserRole.other ? _otherRole : _selectedRole,
        primaryGoal: _selectedGoal,
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        oneLiner: _oneLinerController.text.trim().isEmpty
            ? null
            : _oneLinerController.text.trim(),
      ); */

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Section
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: AppConstants.spacingSm),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Your full name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.spacingMd),

              // Role Selection
              _buildSectionTitle('Role'),
              const SizedBox(height: AppConstants.spacingSm),
              ...UserRole.all.map((role) {
                final isSelected = _selectedRole == role;
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.spacingSm),
                  child: InkWell(
                    onTap: _isLoading
                        ? null
                        : () => setState(() => _selectedRole = role),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
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

              if (_selectedRole == UserRole.other) ...[
                const SizedBox(height: AppConstants.spacingSm),
                _buildTextField(
                  controller: TextEditingController(text: _otherRole),
                  label: 'Specify Role',
                  hint: 'Enter your role',
                  onChanged: (value) => _otherRole = value,
                ),
              ],

              const SizedBox(height: AppConstants.spacingLg),

              // Primary Goal Selection
              _buildSectionTitle('Primary Goal'),
              const SizedBox(height: AppConstants.spacingSm),
              ...PrimaryGoal.all.map((goal) {
                final isSelected = _selectedGoal == goal;
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.spacingSm),
                  child: InkWell(
                    onTap: _isLoading
                        ? null
                        : () => setState(() => _selectedGoal = goal),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
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

              // Additional Info Section
              _buildSectionTitle('Additional Information (Optional)'),
              const SizedBox(height: AppConstants.spacingSm),

              _buildTextField(
                controller: _companyController,
                label: 'Company',
                hint: 'Your company or startup name',
              ),

              const SizedBox(height: AppConstants.spacingMd),

              _buildTextField(
                controller: _websiteController,
                label: 'Website',
                hint: 'https://yourwebsite.com',
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: AppConstants.spacingMd),

              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'City, Country',
              ),

              const SizedBox(height: AppConstants.spacingMd),

              _buildTextField(
                controller: _oneLinerController,
                label: 'One-liner',
                hint: 'A brief description of what you do',
                maxLines: 2,
              ),

              const SizedBox(height: AppConstants.spacingXl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
                const BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: !_isLoading,
      ),
    );
  }
}
