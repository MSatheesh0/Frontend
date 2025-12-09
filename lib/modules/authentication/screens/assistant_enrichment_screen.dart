import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

/// Optional screen for collecting additional user information
/// User can skip this entirely and complete it later
class AssistantEnrichmentScreen extends StatefulWidget {
  final AuthService authService;

  const AssistantEnrichmentScreen({
    super.key,
    required this.authService,
  });

  @override
  State<AssistantEnrichmentScreen> createState() =>
      _AssistantEnrichmentScreenState();
}

class _AssistantEnrichmentScreenState extends State<AssistantEnrichmentScreen> {
  final _companyController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  final _oneLinerController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _companyController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _oneLinerController.dispose();
    super.dispose();
  }

  /// Navigate to main app
  void _goToMainApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
      (route) => false,
    );
  }

  /// Save optional info and go to main app
  Future<void> _handleFinishSetup() async {
    final hasAnyData = _companyController.text.trim().isNotEmpty ||
        _websiteController.text.trim().isNotEmpty ||
        _locationController.text.trim().isNotEmpty ||
        _oneLinerController.text.trim().isNotEmpty;

    if (!hasAnyData) {
      // Nothing to save, just navigate
      _goToMainApp();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Old auth system
      /* await widget.authService.updateUserProfile(
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile update not available yet')),
      );

      if (!mounted) return;

      _goToMainApp();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => _isLoading = false);
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
          'Help your assistant know you better',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtitle
                    Text(
                      'This is optional. You can skip everything and add it later.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingXl),

                    // Company Name
                    Text(
                      'Company / Startup',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextField(
                      controller: _companyController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'e.g., Acme Inc.',
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
                    ),

                    const SizedBox(height: AppConstants.spacingLg),

                    // Website or LinkedIn
                    Text(
                      'Website or LinkedIn URL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextField(
                      controller: _websiteController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: 'https://...',
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
                    ),

                    const SizedBox(height: AppConstants.spacingLg),

                    // Location
                    Text(
                      'City / Country',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextField(
                      controller: _locationController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'e.g., San Francisco, USA',
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
                    ),

                    const SizedBox(height: AppConstants.spacingLg),

                    // One-liner description
                    Text(
                      'What do you do?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    TextField(
                      controller: _oneLinerController,
                      enabled: !_isLoading,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'e.g., AI SaaS for manufacturing analytics',
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
                    ),

                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingXl),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Finish Setup Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleFinishSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          AppTheme.primaryColor.withOpacity(0.5),
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
                            'Finish Setup',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),

                  const SizedBox(height: AppConstants.spacingSm),

                  // Skip Button
                  TextButton(
                    onPressed: _isLoading ? null : _goToMainApp,
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
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
}
