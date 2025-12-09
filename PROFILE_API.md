# Profile API Documentation

## 📋 Profile Endpoints

### 1. Get Profile Details
**Endpoint:** `GET /me`

**Description:** Retrieves the authenticated user's complete profile information

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request:** No body required

**Response (200 OK):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "name": "John Doe",
  "role": "founder",
  "primaryGoal": "fundraising",
  "company": "My Startup Inc",
  "website": "https://mystartup.com",
  "location": "Chennai, India",
  "oneLiner": "Building AI SaaS for manufacturing analytics",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-20T15:45:00.000Z"
}
```

**Response Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Unique user identifier (MongoDB ObjectId) |
| `email` | string | Yes | User's email address |
| `name` | string | Yes | User's full name |
| `role` | string | Yes | User's role/profession (enum) |
| `primaryGoal` | string | Yes | User's primary goal (enum) |
| `company` | string | No | Company or startup name |
| `website` | string | No | Personal or company website URL |
| `location` | string | No | City, Country location |
| `oneLiner` | string | No | Brief description of what they do |
| `createdAt` | string | Yes | ISO 8601 timestamp of account creation |
| `updatedAt` | string | Yes | ISO 8601 timestamp of last update |

**Role Enum Values:**
- `"founder"` - Founder / Co-founder
- `"investor"` - Investor / Angel
- `"mentor"` - Mentor / Advisor
- `"cxo"` - CXO / Leader
- `"service"` - Service Provider / Agency
- `"other"` - Other

**Primary Goal Enum Values:**
- `"fundraising"` - Raise funds
- `"clients"` - Find clients
- `"cofounder"` - Find co-founder / team
- `"hiring"` - Hire or find talent
- `"learn"` - Learn & connect
- `"other"` - Explore startup opportunities

**Error Responses:**

**401 Unauthorized:**
```json
{
  "message": "Invalid or expired token"
}
```

**500 Internal Server Error:**
```json
{
  "message": "Internal server error"
}
```

---

### 2. Update Profile
**Endpoint:** `PUT /me`

**Description:** Updates the authenticated user's profile information. Supports partial updates - only send fields you want to change.

**Headers:**
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "John Doe Updated",
  "role": "founder",
  "primaryGoal": "clients",
  "company": "New Company Inc",
  "website": "https://newcompany.com",
  "location": "Mumbai, India",
  "oneLiner": "Revolutionizing fintech in India"
}
```

**Request Parameters:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | User's full name |
| `role` | string | No | User's role (must be valid enum value) |
| `primaryGoal` | string | No | User's primary goal (must be valid enum value) |
| `company` | string | No | Company or startup name |
| `website` | string | No | Website URL |
| `location` | string | No | City, Country |
| `oneLiner` | string | No | Brief description (max 200 chars recommended) |

**Notes:**
- All fields are optional - send only what you want to update
- `email` and `id` cannot be updated via this endpoint
- `role` and `primaryGoal` must be valid enum values (see above)
- Empty strings will clear the field value for optional fields

**Response (200 OK):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "name": "John Doe Updated",
  "role": "founder",
  "primaryGoal": "clients",
  "company": "New Company Inc",
  "website": "https://newcompany.com",
  "location": "Mumbai, India",
  "oneLiner": "Revolutionizing fintech in India",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-20T16:00:00.000Z"
}
```

**Error Responses:**

**400 Bad Request:**
```json
{
  "message": "Invalid role value. Must be one of: founder, investor, mentor, cxo, service, other"
}
```

or

```json
{
  "message": "Invalid primaryGoal value. Must be one of: fundraising, clients, cofounder, hiring, learn, other"
}
```

**401 Unauthorized:**
```json
{
  "message": "Invalid or expired token"
}
```

**500 Internal Server Error:**
```json
{
  "message": "Failed to update profile"
}
```

---

## 🔄 Flutter Integration

### Get Profile
```dart
// Already implemented in AuthService
final profile = await authService.fetchUserProfile();

// Access profile data
print('Name: ${profile.name}');
print('Role: ${profile.role}');
print('Company: ${profile.company}');
```

### Update Profile (Full Update)
```dart
await authService.updateUserProfile(
  name: 'John Doe',
  role: 'Founder / Co-founder', // UI display value
  primaryGoal: 'Raise funds', // UI display value
  company: 'My Startup',
  website: 'https://mystartup.com',
  location: 'Chennai, India',
  oneLiner: 'Building the future',
);
```

### Update Profile (Partial Update)
```dart
// Update only specific fields
await authService.updateUserProfile(
  company: 'New Company Name',
  website: 'https://newsite.com',
);

// Update only core fields
await authService.updateUserProfile(
  name: 'New Name',
  role: 'Investor / Angel',
);
```

### Enum Conversion
The Flutter app automatically converts between UI display values and API enum values:

**UI → API (when sending):**
- `"Founder / Co-founder"` → `"founder"`
- `"Raise funds"` → `"fundraising"`

**API → UI (when receiving):**
- `"founder"` → `"Founder / Co-founder"`
- `"fundraising"` → `"Raise funds"`

This conversion is handled by:
- `UserRole.toApiValue()` and `UserRole.fromApiValue()`
- `PrimaryGoal.toApiValue()` and `PrimaryGoal.fromApiValue()`

---

## 🧪 Testing Examples

### Test 1: Get Profile
```bash
curl -X GET \
  https://cpt4x27j-3000.inc1.devtunnels.ms/me \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  -H 'Content-Type: application/json'
```

### Test 2: Update Name and Company
```bash
curl -X PUT \
  https://cpt4x27j-3000.inc1.devtunnels.ms/me \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Jane Smith",
    "company": "TechCorp"
  }'
```

### Test 3: Update Full Profile
```bash
curl -X PUT \
  https://cpt4x27j-3000.inc1.devtunnels.ms/me \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE' \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Jane Smith",
    "role": "investor",
    "primaryGoal": "fundraising",
    "company": "Angel Ventures",
    "website": "https://angelventures.com",
    "location": "Bangalore, India",
    "oneLiner": "Investing in early-stage startups"
  }'
```

---

## ✅ Implementation Checklist

### Backend Requirements
- [x] `GET /me` endpoint returns user profile
- [x] `PUT /me` endpoint accepts partial updates
- [x] Token validation on both endpoints
- [x] Enum validation for role and primaryGoal
- [x] Returns updated `updatedAt` timestamp
- [x] Handles optional fields correctly (null values)

### Frontend Implementation
- [x] EditProfileScreen created
- [x] Profile edit button added to AIProfileScreen
- [x] Auth user data displayed in profile header
- [x] updateUserProfile() supports all fields
- [x] Enum conversion for role and primaryGoal
- [x] Form validation in edit screen
- [x] Success/error messages
- [x] Loading states

---

## 📱 UI Flow

```
Profile Screen (AIProfileScreen)
  ↓
  [Edit Button Click]
  ↓
Edit Profile Screen (EditProfileScreen)
  ↓
  [User modifies fields]
  ↓
  [Save Button Click]
  ↓
PUT /me API Call
  ↓
  [Success]
  ↓
Profile Updated & Screen Refreshed
```

---

## 🔐 Security Notes

1. **Authentication Required**: Both endpoints require valid JWT token
2. **User Isolation**: Users can only view/update their own profile
3. **Token Expiry**: Tokens expire after 30 days
4. **Secure Storage**: Tokens stored in device keychain/keystore
5. **HTTPS Only**: All API calls must use HTTPS in production

---

## 🎯 Next Steps

1. **Test the endpoints** with Postman/curl
2. **Run the Flutter app** and try editing your profile
3. **Verify** profile data persists after app restart
4. **Check** enum conversions work correctly
5. **Test** partial updates (update only 1-2 fields)

Your profile editing feature is now fully implemented! 🎉
