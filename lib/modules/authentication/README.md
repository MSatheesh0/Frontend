# Authentication Module

## Overview
Handles all authentication flows including OTP-based and email/password authentication, user signup, and profile enrichment.

## Features
- ✅ Email-based OTP authentication
- ✅ Email/password authentication
- ✅ User signup with role selection
- ✅ Profile enrichment flow
- ✅ JWT token management
- ✅ Session restoration

## Files

### Models
- `user_profile_auth.dart` - User profile and auth data models

### Screens
- `auth_entry_screen.dart` - Landing page for authentication
- `email_input_screen.dart` - Email input screen
- `otp_verify_screen.dart` - OTP verification screen
- `signup_details_screen.dart` - Required signup information
- `assistant_enrichment_screen.dart` - Optional profile enrichment
- `simple_login_screen.dart` - Email/password login
- `simple_signup_screen.dart` - Email/password signup

### Services
- `auth_service.dart` - Authentication business logic and API calls

## Usage

```dart
// Import the entire module
import 'package:goal_networking_app/modules/authentication/authentication.dart';

// Or import specific components
import 'package:goal_networking_app/modules/authentication/screens/auth_entry_screen.dart';
import 'package:goal_networking_app/modules/authentication/services/auth_service.dart';
```

## Dependencies
- Core (theme, config)
- HTTP package for API calls
- Provider for state management

## API Endpoints
- `POST /auth/request-otp` - Send OTP to email
- `POST /auth/verify-otp` - Verify OTP and get token
- `POST /auth/login` - Email/password login
- `POST /auth/signup` - Email/password signup
- `PUT /me` - Update user profile

## User Roles
- Founder / Co-founder
- Investor / Angel
- Mentor / Advisor
- CXO / Leader
- Service Provider / Agency
- Other

## Primary Goals
- Raise funds
- Find clients
- Find co-founder / team
- Hire or find talent
- Learn & connect
- Explore startup opportunities

## Testing
Test with mock OTP: `123456` (development mode)

## Documentation
See [AUTH_FLOW_README.md](../../../AUTH_FLOW_README.md) for detailed documentation.
