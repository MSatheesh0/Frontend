# Backend API Integration - Complete ✅

## Overview

The Flutter app has been successfully integrated with the GoalNet backend API. All authentication and profile management now use real HTTP calls to the backend server.

**Base URL**: Configured in `lib/config/api_config.dart`
- **Current**: `https://cpt4x27j-3000.inc1.devtunnels.ms`
- **Local Dev**: `http://localhost:3000` (commented in config file)

## What Was Changed

### 1. **AuthService (`lib/services/auth_service.dart`)**

**Before**: Mock implementation with simulated delays and hardcoded OTP (123456)

**After**: Real HTTP calls to backend API endpoints

#### Updated Methods:

- ✅ **`requestOtp(email)`** - POST to `/auth/request-otp`
- ✅ **`verifyOtp(email, otp)`** - POST to `/auth/verify-otp`
- ✅ **`saveUserProfile(profile)`** - PUT to `/me`
- ✅ **`updateUserProfile(...)`** - PUT to `/me`
- ✅ **`fetchUserProfile()`** - GET `/me` (new method)

### 2. **User Profile Model (`lib/models/user_profile_auth.dart`)**

Added mapping functions to convert between UI display values and backend API enum values:

- **UserRole.toApiValue()** - Convert display names to API values
  - "Founder / Co-founder" → "founder"
  - "Investor / Angel" → "investor"
  - etc.

- **UserRole.fromApiValue()** - Convert API values to display names
  - "founder" → "Founder / Co-founder"
  - etc.

- **PrimaryGoal.toApiValue()** - Convert display names to API values
  - "Raise funds" → "fundraising"
  - "Find clients" → "clients"
  - etc.

- **PrimaryGoal.fromApiValue()** - Convert API values to display names

### 3. **Configuration (`lib/config/api_config.dart`)**

✅ **Centralized API Configuration**

All API endpoints and base URLs are now managed in one place: `lib/config/api_config.dart`

**Current Setup**:
- Base URL: `https://cpt4x27j-3000.inc1.devtunnels.ms` (dev tunnel)
- All endpoints defined as constants
- Timeout durations configured

**To switch environments**, simply update `ApiConfig.baseUrl`:
- Local: `http://localhost:3000`
- Dev Tunnel: `https://cpt4x27j-3000.inc1.devtunnels.ms`
- Production: Update with your production URL

**Future Enhancement**: Consider using `flutter_dotenv` for environment-based configuration

## API Integration Details

### Request Headers

All authenticated requests include:
```dart
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
}
```

### Error Handling

The service handles various HTTP status codes:

- **200**: Success
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (invalid/expired token)
- **429**: Rate Limited (too many OTP requests)
- **500**: Server Error

All errors are thrown as `Exception` with user-friendly messages.

### Data Flow

#### Signup Flow:
1. User enters email → `requestOtp()` → POST `/auth/request-otp`
2. User enters OTP → `verifyOtp()` → POST `/auth/verify-otp` → Receives token + isNewUser flag
3. User fills profile → `saveUserProfile()` → PUT `/me` (with API enum values)
4. Response is converted from API enums to display values

#### Signin Flow:
1. User enters email → `requestOtp()` → POST `/auth/request-otp`
2. User enters OTP → `verifyOtp()` → POST `/auth/verify-otp` → Receives token + full profile
3. Profile data is converted from API enums to display values
4. User lands on main screen

## Testing

### Prerequisites

1. **Backend must be running**: `http://localhost:3000`
   ```bash
   cd backend
   npm run dev
   ```

2. **Check backend health**:
   ```bash
   curl http://localhost:3000/health
   ```

### Test Scenarios

#### 1. New User Signup
```
Email: newuser@test.com
OTP: Check backend console for actual OTP
Flow: Auth → Email → OTP → Signup Details → Enrichment → Main
```

#### 2. Existing User Signin
```
Email: Use an email already in database
OTP: Check backend console
Flow: Auth → Email → OTP → Main (skips signup)
```

#### 3. Invalid OTP
```
Enter wrong OTP code
Expected: Error message "Invalid OTP. Please try again."
```

#### 4. Rate Limiting
```
Request OTP 4+ times within 5 minutes
Expected: Error message about too many requests
```

## Network Errors

The service catches network errors and provides user-friendly messages:

```dart
try {
  // API call
} catch (e) {
  if (e.toString().contains('Exception:')) {
    rethrow;  // Re-throw custom exceptions
  }
  throw Exception('Network error. Please check your connection.');
}
```

## Console Logging

The service logs important events:

- ✅ `OTP sent to email@example.com`
- ✅ `OTP verified for email@example.com (isNewUser: true/false)`
- ✅ `User profile saved: John Doe`
- ✅ `User profile updated`
- ✅ `User signed out`

## Known Limitations & TODOs

### 1. **Token Storage** 🔴
- **Current**: Tokens stored in memory (lost on app restart)
- **TODO**: Implement secure storage with `flutter_secure_storage`
  ```dart
  final storage = FlutterSecureStorage();
  await storage.write(key: 'auth_token', value: token);
  ```

### 2. **Session Restoration** 🔴
- **Current**: `restoreSession()` is a placeholder
- **TODO**: Load token from secure storage and validate with backend
  ```dart
  final token = await storage.read(key: 'auth_token');
  if (token != null) {
    _authToken = token;
    await fetchUserProfile();  // Validate token
  }
  ```

### 3. **Environment Configuration** 🟡
- **Current**: Base URL hardcoded to localhost
- **TODO**: Use environment variables
  ```yaml
  # .env
  API_BASE_URL_DEV=http://localhost:3000
  API_BASE_URL_PROD=https://api.goalnet.com
  ```

### 4. **Offline Support** 🟡
- **Current**: No offline caching
- **TODO**: Cache profile data locally, sync when online

### 5. **Token Refresh** 🟡
- **Current**: No automatic token refresh
- **TODO**: Handle 401 errors by refreshing token or re-authenticating

### 6. **Logout Endpoint** 🟢
- **Current**: Only clears local data
- **Note**: Backend doesn't have `/auth/logout` endpoint (JWT is stateless)
- This is fine for MVP since token expiry handles security

## Production Checklist

Before deploying to production:

- [ ] Move base URL to environment configuration
- [ ] Implement secure token storage
- [ ] Implement session restoration
- [ ] Add token refresh logic
- [ ] Add offline support and caching
- [ ] Add request/response logging (for debugging)
- [ ] Add analytics tracking for API calls
- [ ] Handle different base URLs for dev/staging/prod
- [ ] Add retry logic for transient failures
- [ ] Add timeout configuration for API calls
- [ ] Test with slow network conditions
- [ ] Test with airplane mode
- [ ] Add certificate pinning for production (security)

## API Reference

### Backend Endpoints Used

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| POST | `/auth/request-otp` | Send OTP to email | No |
| POST | `/auth/verify-otp` | Verify OTP, get token | No |
| GET | `/me` | Fetch user profile | Yes |
| PUT | `/me` | Update user profile | Yes |

### Request/Response Examples

See `AUTH_FLOW_README.md` section "Backend Integration" for detailed examples.

## Troubleshooting

### Issue: "Network error. Please check your connection."
- **Cause**: Backend not running or unreachable
- **Fix**: Start backend server: `npm run dev`

### Issue: "Session expired. Please login again."
- **Cause**: Token expired (30 days) or invalid
- **Fix**: User must re-authenticate

### Issue: "Too many requests. Please try again later."
- **Cause**: Rate limit exceeded (3 OTPs per 5 minutes)
- **Fix**: Wait and try again

### Issue: OTP not arriving
- **Check**: Backend console logs for OTP code
- **Note**: In development, OTP is logged to console, not sent via email

## Summary

✅ **Complete backend integration**  
✅ **Real HTTP calls to all endpoints**  
✅ **Proper enum value mapping**  
✅ **Error handling for all scenarios**  
✅ **User-friendly error messages**  
✅ **Console logging for debugging**  

🔴 **Critical TODOs**: Token storage, session restoration  
🟡 **Nice-to-haves**: Environment config, offline support, token refresh  

The app is now fully functional with the backend API and ready for testing!
