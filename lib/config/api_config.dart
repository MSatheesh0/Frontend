/// API Configuration
///
/// This file contains the base URL and other API-related configuration.
/// Update the baseUrl when switching between environments (local, dev, staging, prod).
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  /// Base URL for the backend API
  ///
  /// Local development: 'http://localhost:3000'
  /// LAN Testing: 'http://192.168.137.2:3000'
  /// Public Tunnel: 'https://rich-hairs-grow.loca.lt'
  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  }

  /// Use mock authentication (set to true for development without backend)
  static const bool useMockAuth = false; // ✅ Backend connected to MongoDB Atlas!

  /// API endpoints
  
  // Auth
  static const String requestOtpEndpoint = '/auth/request-otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  
  // User
  static const String userProfileEndpoint = '/users/me';
  
  // Network Codes
  static const String networkCodesEndpoint = '/network-codes';
  static const String searchNetworkCodesEndpoint = '/network-codes/search';
  
  // Connections
  static const String connectionsEndpoint = '/connections';
  static const String connectionRequestsEndpoint = '/connections/requests';
  
  // Goals
  static const String goalsEndpoint = '/me/goals';
  
  // AI Profile
  static const String aiProfileEndpoint = '/me/ai-profile';

  // Followings
  static const String followingsEndpoint = '/followings';

  /// Timeout durations
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}
