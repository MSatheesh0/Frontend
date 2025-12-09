# 🚀 Quick Start Guide - Auth Flow Testing

## What Was Implemented

✅ Complete email-based OTP authentication flow
✅ Passwordless signup and signin
✅ Goal-based onboarding for new users
✅ Optional profile enrichment
✅ Mock implementations ready for backend integration

## Files Created

### Models
- `lib/models/user_profile_auth.dart` - User profile and auth result models

### Services
- `lib/services/auth_service.dart` - Authentication business logic (mock implementation)

### Screens
1. `lib/screens/auth_entry_screen.dart` - Landing page
2. `lib/screens/email_input_screen.dart` - Email input
3. `lib/screens/otp_verify_screen.dart` - OTP verification
4. `lib/screens/signup_details_screen.dart` - Required signup info
5. `lib/screens/assistant_enrichment_screen.dart` - Optional info

### Updated
- `lib/main.dart` - Added auth check and routing logic

## Testing the Flow

### Test as New User

1. **Run the app** - You'll see the `AuthEntryScreen` (unless already authenticated)

2. **Tap "Continue with Email"**

3. **Enter email**: Use an email containing "new" or "test"
   - Example: `newuser@test.com` or `test@gmail.com`

4. **Check console** - You'll see:
   ```
   🔐 [MOCK] OTP sent to newuser@test.com: 123456
   ```

5. **Enter OTP**: `123456` (fixed for testing)

6. **Fill signup details**:
   - Name: Your name
   - Role: Select any role (try "Founder / Co-founder")
   - Goal: Select any goal (try "Raise funds")
   - Tap "Continue"

7. **Optional enrichment** - Either:
   - Fill in company, website, etc. and tap "Finish Setup"
   - OR tap "Skip for now"

8. **Success!** - You'll land on the MainScreen (authenticated)

### Test as Existing User

1. **Enter email** WITHOUT "new" or "test"
   - Example: `user@company.com`

2. **Console shows**:
   ```
   🔐 [MOCK] OTP sent to user@company.com: 123456
   ```

3. **Enter OTP**: `123456`

4. **Success!** - Skips signup, goes directly to MainScreen

### Test OTP Resend

1. On the OTP screen, tap **"Didn't receive code? Resend"**
2. Check console for new OTP message
3. Still use `123456` to verify

### Test Invalid OTP

1. Enter any code other than `123456` (e.g., `000000`)
2. Tap "Verify"
3. You'll see error: "Invalid OTP. Please try again."

### Test Form Validation

1. Try leaving name empty on signup → Error appears
2. Try submitting without selecting role → Button stays disabled
3. Try submitting without selecting goal → Button stays disabled
4. Select "Other" as role → New text field appears for custom role

## Key Testing Points

✅ **Mock OTP is always**: `123456`  
✅ **Emails with "new" or "test"** → New user flow  
✅ **Other emails** → Existing user flow  
✅ **All screens show loading states** during async operations  
✅ **Error handling** works (try wrong OTP)  
✅ **Skip functionality** works on enrichment screen  
✅ **Form validation** prevents invalid submissions  

## Console Output Examples

```
🔐 [MOCK] OTP sent to newuser@test.com: 123456
✅ [MOCK] User profile saved: John Doe (newuser@test.com)
✅ [MOCK] User profile updated
```

## Navigation Flow Visualization

### New User
```
AuthCheckScreen (loading)
    ↓
AuthEntryScreen
    ↓
EmailInputScreen
    ↓
OtpVerifyScreen
    ↓
SignupDetailsScreen
    ↓
AssistantEnrichmentScreen
    ↓
MainScreen ✅
```

### Existing User
```
AuthCheckScreen (loading)
    ↓
AuthEntryScreen
    ↓
EmailInputScreen
    ↓
OtpVerifyScreen
    ↓
MainScreen ✅
```

## What's NOT Implemented (As Requested)

❌ SMS OTP  
❌ Password login  
❌ Social logins (Google, LinkedIn)  
❌ Remember me  
❌ Multi-device logout  

All marked with TODO comments for future implementation.

## Backend Integration Checklist

When you're ready to connect to a real backend:

1. **Replace mock methods in** `lib/services/auth_service.dart`
   - Look for `// TODO: Real implementation` comments
   - Add your HTTP client (dio, http, etc.)

2. **Add secure storage** for auth token:
   ```yaml
   # pubspec.yaml
   dependencies:
     flutter_secure_storage: ^9.0.0
   ```

3. **Implement** `restoreSession()` in `AuthService`
   - Load token from secure storage
   - Validate with backend
   - Load user profile

4. **Backend endpoints needed**:
   - `POST /auth/request-otp` - Send OTP email
   - `POST /auth/verify-otp` - Verify OTP, return token + user data
   - `POST /auth/complete-profile` - Save new user profile
   - `PATCH /user/profile` - Update optional fields

## Design Principles Used

✨ **Minimalism** - Clean, white backgrounds, single CTA per screen  
🤖 **Assistant-Centric** - Copy emphasizes "your assistant"  
🎯 **Goal-Based** - Focus on user goals, not vanity metrics  
📱 **Progressive Disclosure** - Required fields first, optional later  
⚡ **Clear Feedback** - Loading states, errors, validation messages  

## Troubleshooting

**Q: App still shows MainScreen immediately?**  
A: AuthService checks `isAuthenticated`. Since it's in-memory, it resets on hot reload. Restart app to see auth flow.

**Q: OTP always 123456?**  
A: Yes! This is intentional for easy testing. Change `_generateMockOtp()` in `auth_service.dart` for random OTPs.

**Q: How to test existing user flow?**  
A: Use any email WITHOUT "new" or "test" (e.g., `user@company.com`)

**Q: Profile screen needs auth user data?**  
A: Auth user is stored in `AuthService.currentUser`. Access via Provider or pass to existing profile system.

## Next Steps

1. ✅ Test the complete flow (both new and existing user)
2. 📱 Test on physical device to see OTP email entry UX
3. 🔗 Plan backend API integration
4. 📊 Add analytics tracking for funnel metrics
5. 🔐 Implement secure token storage
6. 📧 Set up email service (SendGrid, AWS SES, etc.)
7. ✨ Add your branding and copy refinements

## Documentation

Full documentation in: `AUTH_FLOW_README.md`

---

**Ready to test!** Just run the app and follow the flow above. The OTP is `123456` for all tests. 🎉
