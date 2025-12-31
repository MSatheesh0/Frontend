import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';
import '../services/auth_service.dart';
import 'signup_details_screen.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/app_state.dart';
import 'main_screen.dart';
import '../services/api_client.dart';

/// Screen for entering and verifying OTP
/// Handles both new user signup and existing user signin
class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final AuthService authService;

  const OtpVerifyScreen({
    super.key,
    required this.email,
    required this.authService,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  /// Verify OTP and navigate based on user status
  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await widget.authService.verifyOtp(widget.email, otp);
      
      if (!mounted) return;
      
      // Extract user and isNewUser from result
      final user = result['user'] as Map<String, dynamic>;
      final isNewUser = result['isNewUser'] as bool;
      
      // Sync user to AppState
      if (mounted) {
        final userModel = User.fromMap(user);
        Provider.of<AppState>(context, listen: false).setUser(userModel);
      }

      if (isNewUser) {
        // New user: go to profile setup
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SignupDetailsScreen(
              email: widget.email,
              authService: widget.authService,
            ),
          ),
        );
      } else {
        // Existing user: go directly to main app
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Handle 409 Conflict (Concurrent Login)
      if (e is ApiException && e.statusCode == 409) {
        final shouldForceLogin = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Already Logged In'),
            content: const Text(
                'You are currently logged in on another device. Do you want to end that session and log in here?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Log in Here',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );

        if (shouldForceLogin == true && mounted) {
           setState(() => _isLoading = true);
           try {
             // Retry with force logout
             final result = await widget.authService.verifyOtp(
               widget.email, 
               otp, 
               logoutFromOtherDevices: true
             );
             
             // ... Success Logic (duplicated for now, or extracted to method) ...
             if (!mounted) return;
             final user = result['user'] as Map<String, dynamic>;
             final isNewUser = result['isNewUser'] as bool;
             if (mounted) {
               final userModel = User.fromMap(user);
               Provider.of<AppState>(context, listen: false).setUser(userModel);
             }
             if (isNewUser) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SignupDetailsScreen(
                      email: widget.email,
                      authService: widget.authService,
                    ),
                  ),
                );
             } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (route) => false,
                );
             }
             return; // Done
           } catch (retryError) {
              if(!mounted) return;
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Force login failed: ${retryError.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
           }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Resend OTP
  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);

    try {
      // Resend OTP
      await widget.authService.requestOtp(widget.email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New verification code sent!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
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
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Enter verification code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'We sent a 6-digit code to',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingXl),

              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                autofocus: true,
                enabled: !_isLoading,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: AppTheme.textPrimary,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: Colors.grey[300],
                    letterSpacing: 8,
                  ),
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
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleVerifyOtp(),
              ),

              const SizedBox(height: AppConstants.spacingLg),

              // Resend OTP Button
              TextButton(
                onPressed: _isResending || _isLoading ? null : _handleResendOtp,
                child: _isResending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Didn\'t receive code? Resend',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const Spacer(),

              // Verify Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
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
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: AppConstants.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
