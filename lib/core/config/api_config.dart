/// API Configuration
///
/// This file contains the base URL and other API-related configuration.
/// Update the baseUrl when switching between environments (local, dev, staging, prod).
class ApiConfig {
  /// Base URL for the backend API
  ///
  /// Local development: 'http://localhost:3000'
  /// Dev tunnel: 'https://cpt4x27j-3000.inc1.devtunnels.ms'
  /// Production: Update with your production API URL
  static const String baseUrl = 'https://cpt4x27j-3000.inc1.devtunnels.ms';

  /// API endpoints
  static const String requestOtpEndpoint = '/auth/request-otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String userProfileEndpoint = '/me';

  /// Timeout durations
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}
