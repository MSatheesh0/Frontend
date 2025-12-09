# WayTree (GoalNet) - AI-Powered Goal-Based Networking Platform

<div align="center">

**Connect. Collaborate. Achieve.**

A revolutionary networking application that uses AI to help professionals achieve their goals through meaningful connections.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Core Modules](#core-modules)
- [Authentication System](#authentication-system)
- [AI Assistant](#ai-assistant)
- [Event Management](#event-management)
- [Networking Features](#networking-features)
- [Profile Management](#profile-management)
- [Goals & Tasks](#goals--tasks)
- [Backend Integration](#backend-integration)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Testing](#testing)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

**WayTree (GoalNet)** is an AI-powered networking platform designed for founders, investors, mentors, and professionals to connect based on shared goals and mutual value. Unlike traditional social networks, WayTree focuses on **meaningful connections** and **goal achievement** through intelligent matching and AI-driven assistance.

### What Makes WayTree Different?

- 🤖 **AI-Powered Matching**: Intelligent assistant that matches you with relevant people based on your goals
- 🎯 **Goal-Centric**: Every connection is purpose-driven and aligned with your objectives
- 🎪 **Event Circles**: Join events and network with attendees in focused circles
- 📊 **Smart Insights**: Get AI-generated insights about your connections and progress
- 🔒 **Privacy-First**: No vanity metrics, no social media patterns, just professional networking
- 📱 **Cross-Platform**: Built with Flutter for iOS, Android, and Web

---

## 🚀 Key Features

### 1. **Intelligent AI Assistant**
- Real-time conversational AI that understands your goals
- Proactive recommendations for connections
- Context-aware suggestions based on your profile and activities
- Multi-agent architecture for specialized tasks
- Voice and text interaction support

### 2. **Goal-Based Networking**
- Create and track professional goals
- Get matched with people who can help you achieve them
- Task management with event context
- Progress tracking and insights
- Goal categories: Fundraising, Hiring, Finding Clients, Learning, etc.

### 3. **Event Management**
- Discover upcoming networking events
- Join event-specific circles
- Create tasks for event networking
- Connect with attendees before, during, and after events
- Event-based recommendations

### 4. **Smart QR & Network Codes**
- Generate custom QR profiles for different contexts
- Create network codes for group networking
- Scan QR codes to instantly connect
- Context-aware connection requests
- Multiple QR profiles for different purposes

### 5. **AI-Generated Profiles**
- Auto-generated professional summaries
- Current focus areas and strengths
- Highlights and achievements
- Document management (pitch decks, resumes, portfolios)
- Profile enrichment with AI insights

### 6. **Connections & Spaces**
- View and manage your professional network
- "My Spaces" - organized connection groups
- Following system for staying updated
- Connection insights and analytics
- Smart recommendations

### 7. **Passwordless Authentication**
- Email-based OTP authentication
- Simplified email/password option
- Secure JWT token management
- Session restoration
- Role-based onboarding

---

## 🏗️ Architecture

### Technology Stack

**Frontend:**
- **Flutter** 3.0+ (Dart SDK >=2.17.0 <4.0.0)
- **Provider** for state management
- **HTTP** for API communication
- **QR Code Scanner** for networking features
- **Flutter Secure Storage** for token management
- **File Picker** for document uploads

**Backend:**
- Node.js/Express (REST API)
- MongoDB (Database)
- JWT Authentication
- Groq API (AI/ML capabilities)
- Email service for OTP delivery

**Design Principles:**
- Clean Architecture with separation of concerns
- Provider pattern for state management
- Repository pattern for data access
- Service layer for business logic
- Modular widget composition

---

## 🎯 Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher
- Dart SDK 2.17.0 or higher
- iOS Simulator / Android Emulator / Chrome browser
- Backend API server running (for full functionality)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/waytree.git
   cd waytree
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   
   Edit `lib/config/api_config.dart`:
   ```dart
   class ApiConfig {
     static const String baseUrl = 'http://localhost:3000'; // or your backend URL
   }
   ```

4. **Run the application:**
   ```bash
   # For Chrome (web)
   flutter run -d chrome
   
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   ```

### Quick Start Script

For Unix-based systems, use the provided script:
```bash
chmod +x install_and_run.sh
./install_and_run.sh
```

---

## 📦 Core Modules

### Authentication Module

**Files:**
- `lib/services/auth_service.dart` - Authentication business logic
- `lib/models/user_profile_auth.dart` - User and auth data models
- `lib/screens/auth_entry_screen.dart` - Landing page
- `lib/screens/email_input_screen.dart` - Email input
- `lib/screens/otp_verify_screen.dart` - OTP verification
- `lib/screens/simple_login_screen.dart` - Email/password login
- `lib/screens/simple_signup_screen.dart` - Email/password signup

**Features:**
- ✅ Email-based OTP authentication
- ✅ Email/password authentication (simplified)
- ✅ JWT token management
- ✅ Session restoration
- ✅ Role-based onboarding
- ✅ Profile enrichment flow

**Authentication Flow:**
```
Landing → Email Input → OTP Verification → Profile Setup → Main App
```

**User Roles:**
- Founder / Co-founder
- Investor / Angel
- Mentor / Advisor
- CXO / Leader
- Service Provider / Agency
- Other

**Primary Goals:**
- Raise funds
- Find clients
- Find co-founder / team
- Hire or find talent
- Learn & connect
- Explore startup opportunities

📖 **Detailed Documentation:** [AUTH_FLOW_README.md](AUTH_FLOW_README.md)

---

### AI Assistant Module

**Files:**
- `lib/screens/assistant_screen.dart` - Main assistant interface
- `lib/screens/assistant_chat_screen.dart` - Chat interface
- `lib/screens/assistant_conversation_screen.dart` - Conversation view
- `lib/services/ai_profile_service.dart` - AI profile management
- `lib/models/assistant_activity.dart` - Activity tracking
- `lib/models/assistant_alert.dart` - Alert system

**Features:**
- ✅ Conversational AI interface
- ✅ Goal-based recommendations
- ✅ Connection matching
- ✅ Activity tracking
- ✅ Smart alerts and notifications
- ✅ Context-aware suggestions
- ✅ Multi-agent architecture

**AI Capabilities:**
- Profile analysis and enrichment
- Connection recommendations
- Goal insights and suggestions
- Event recommendations
- Conversation summaries
- Activity highlights

📖 **Detailed Documentation:** [AI_PROFILE_API.md](AI_PROFILE_API.md)

---

### Event Management Module

**Files:**
- `lib/screens/event_list_screen.dart` - Event browsing
- `lib/screens/event_details_screen.dart` - Event information
- `lib/screens/event_assistant_screen.dart` - Event-specific assistant
- `lib/models/event.dart` - Event and EventCircle models

**Features:**
- ✅ Browse upcoming events
- ✅ Join event circles
- ✅ Create event-specific tasks
- ✅ Event-based networking
- ✅ Attendee discovery
- ✅ Event context preservation

**Event Information:**
- Event name and description
- Date, time, and location
- Event banner/image
- Attendee count
- Join status

**Event Flow:**
```
Event List → Event Details → Join Circle → Create Task → Network
```

📖 **Detailed Documentation:** [EVENT_MODULE_README.md](EVENT_MODULE_README.md)

---

### Networking Features

**Files:**
- `lib/screens/create_qr_profile_screen.dart` - QR profile creation
- `lib/screens/create_network_code_screen.dart` - Network code creation
- `lib/widgets/qr_scanner_view.dart` - QR scanning
- `lib/widgets/networking_mode_view.dart` - Networking interface
- `lib/models/qr_profile.dart` - QR profile model
- `lib/models/network_code.dart` - Network code model

**Features:**
- ✅ Custom QR profile generation
- ✅ Network code creation for groups
- ✅ QR code scanning
- ✅ Instant connection requests
- ✅ Context-aware profiles
- ✅ Multiple QR profiles

**QR Profile Types:**
- Professional networking
- Event-specific
- Fundraising
- Hiring
- Custom contexts

**Network Codes:**
- Group networking sessions
- Event-based codes
- Time-limited access
- Member tracking

---

### Profile Management

**Files:**
- `lib/screens/ai_profile_screen.dart` - AI-enhanced profile view
- `lib/screens/edit_profile_screen.dart` - Profile editing
- `lib/screens/profile_viewer_screen.dart` - View other profiles
- `lib/services/profile_repository.dart` - Profile data management
- `lib/models/profile_model.dart` - Profile data model
- `lib/models/user_profile.dart` - User profile model

**Features:**
- ✅ AI-generated profile summary
- ✅ Current focus areas
- ✅ Strengths and highlights
- ✅ Document management
- ✅ Profile editing
- ✅ Profile viewing
- ✅ Profile enrichment

**Profile Sections:**
- Basic Information (name, role, company)
- AI-Generated Summary
- Current Focus Areas
- Strengths & Skills
- Highlights & Achievements
- Documents (pitch decks, resumes, portfolios)
- Goals & Objectives

**Document Types:**
- PDF files (pitch decks, resumes)
- Links (YouTube, portfolio websites)
- Images
- Other attachments

📖 **Detailed Documentation:** [PROFILE_API.md](PROFILE_API.md)

---

### Goals & Tasks Module

**Files:**
- `lib/screens/create_goal_screen.dart` - Goal creation
- `lib/screens/goal_insights_screen.dart` - Goal analytics
- `lib/screens/dashboard_screen.dart` - Task dashboard
- `lib/services/goals_service.dart` - Goals management
- `lib/services/task_execution_service.dart` - Task execution
- `lib/models/goal.dart` - Goal model
- `lib/models/goal_insights.dart` - Insights model

**Features:**
- ✅ Create and manage goals
- ✅ Task creation with event context
- ✅ Progress tracking
- ✅ Milestone management
- ✅ Goal insights and analytics
- ✅ AI-powered recommendations
- ✅ Goal categories

**Goal Categories:**
- Fundraising
- Hiring
- Product Development
- Growth
- Networking
- Learning
- Other

**Goal Properties:**
- Title and description
- Category
- Status (active, completed, paused, archived)
- Progress percentage
- Target date
- Milestones
- Context (event, circle, etc.)

---

### Connections & Spaces

**Files:**
- `lib/screens/connections_list_screen.dart` - Connection management
- `lib/screens/my_spaces_screen.dart` - Organized connection groups
- `lib/screens/following_list_screen.dart` - Following management
- `lib/screens/followers_list_screen.dart` - Followers view
- `lib/screens/recommendations_screen.dart` - Smart recommendations
- `lib/models/connection.dart` - Connection model
- `lib/models/my_spaces.dart` - Spaces model
- `lib/models/following.dart` - Following model
- `lib/models/recommendation.dart` - Recommendation model

**Features:**
- ✅ View all connections
- ✅ Organize connections into spaces
- ✅ Follow/unfollow users
- ✅ Smart recommendations
- ✅ Connection insights
- ✅ Search and filter

**My Spaces:**
- Investors
- Mentors
- Potential Clients
- Team Members
- Event Connections
- Custom spaces

---

## 🔐 Authentication System

### OTP-Based Authentication (Primary)

**Flow:**
1. User enters email
2. Backend sends 6-digit OTP
3. User verifies OTP
4. Backend returns JWT token + user status
5. New users complete profile setup
6. Existing users go to main app

**Endpoints:**
- `POST /auth/request-otp` - Send OTP
- `POST /auth/verify-otp` - Verify OTP and get token
- `PUT /me` - Complete/update profile

### Email/Password Authentication (Alternative)

**Flow:**
1. User enters email and password
2. Backend validates credentials
3. Returns JWT token
4. User goes to main app

**Endpoints:**
- `POST /auth/login` - Email/password login
- `POST /auth/signup` - Email/password signup

### Token Management

- JWT tokens stored in secure storage
- 30-day expiration
- Automatic session restoration
- Token refresh on expiry

📖 **Detailed Documentation:** [AUTH_QUICK_START.md](AUTH_QUICK_START.md)

---

## 🤖 AI Assistant

### AI Profile Generation

The AI assistant analyzes your profile, documents, and goals to generate:

- **Professional Summary**: 2-3 sentence overview
- **Current Focus**: Active projects and priorities
- **Strengths**: Key skills and expertise
- **Highlights**: Major achievements and credentials

### AI Endpoints

- `GET /me/ai-profile` - Get AI-generated profile
- `POST /me/ai-profile/regenerate` - Regenerate AI profile
- `GET /me/documents` - Get documents list
- `POST /me/documents` - Upload document
- `DELETE /me/documents/:id` - Delete document

### AI Features

- Profile enrichment
- Connection matching
- Goal recommendations
- Event suggestions
- Conversation summaries
- Activity insights

📖 **Detailed Documentation:** [AI_PROFILE_IMPLEMENTATION.md](AI_PROFILE_IMPLEMENTATION.md)

---

## 🎪 Event Management

### Event Discovery

Browse and discover networking events:
- Event name and description
- Date, time, and location
- Event banner
- Days until event badge
- Join status

### Event Circles

Join event-specific networking circles:
- Dedicated space for event attendees
- Event-based recommendations
- Pre-event networking
- Post-event follow-ups

### Event Tasks

Create tasks specifically for events:
- Pre-filled task name
- Event context preservation
- Event-based matching
- Automatic event tagging

📖 **Detailed Documentation:** [EVENT_LIST_UPDATE.md](EVENT_LIST_UPDATE.md)

---

## 🌐 Networking Features

### QR Profiles

Create custom QR codes for different contexts:
- Professional networking
- Event-specific
- Fundraising pitch
- Hiring
- Custom messages

**QR Profile Fields:**
- Title
- Description
- Context type
- Custom message
- Generated QR code

### Network Codes

Create codes for group networking:
- Event sessions
- Workshop groups
- Meetup circles
- Time-limited access

**Network Code Fields:**
- Code name
- Description
- Access code
- Expiration
- Member list

### QR Scanning

Scan QR codes to connect:
- Instant profile view
- Context-aware connection
- Connection request
- Add to spaces

---

## 👤 Profile Management

### Profile Sections

**Basic Information:**
- Name
- Email
- Role
- Company
- Website
- Location
- One-liner

**AI-Generated Content:**
- Professional summary
- Current focus areas
- Strengths
- Highlights

**Documents:**
- Pitch decks
- Resumes
- Portfolios
- Demo videos
- Other files

**Goals:**
- Active goals
- Completed goals
- Goal progress
- Milestones

### Profile Editing

Edit your profile information:
- Update basic details
- Change role and goals
- Add/remove documents
- Regenerate AI profile

### Profile Viewing

View other users' profiles:
- Public profile information
- AI-generated summary
- Shared documents
- Connection status
- Mutual connections

---

## 🎯 Goals & Tasks

### Goal Management

**Create Goals:**
- Title and description
- Category selection
- Target date
- Milestones

**Track Progress:**
- Progress percentage
- Milestone completion
- Status updates
- Timeline view

**Goal Insights:**
- AI-powered analytics
- Recommendation suggestions
- Connection opportunities
- Progress trends

### Task Execution

**Task Types:**
- General tasks
- Event-based tasks
- Circle-specific tasks
- Connection tasks

**Task Properties:**
- Title and description
- Due date
- Priority
- Status
- Context (event, circle)
- Tags

---

## 🔌 Backend Integration

### API Configuration

**Base URL:** Configured in `lib/config/api_config.dart`

```dart
class ApiConfig {
  static const String baseUrl = 'https://your-api-url.com';
  
  // Endpoints
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String getProfile = '/me';
  static const String updateProfile = '/me';
  // ... more endpoints
}
```

### API Endpoints

**Authentication:**
- `POST /auth/request-otp` - Send OTP
- `POST /auth/verify-otp` - Verify OTP
- `POST /auth/login` - Email/password login
- `POST /auth/signup` - Email/password signup

**Profile:**
- `GET /me` - Get user profile
- `PUT /me` - Update user profile

**AI Profile:**
- `GET /me/ai-profile` - Get AI profile
- `POST /me/ai-profile/regenerate` - Regenerate AI profile

**Documents:**
- `GET /me/documents` - List documents
- `POST /me/documents` - Upload document
- `DELETE /me/documents/:id` - Delete document

**Goals:**
- `GET /me/goals` - List goals
- `POST /me/goals` - Create goal
- `PUT /me/goals/:id` - Update goal
- `DELETE /me/goals/:id` - Delete goal

**Events:**
- `GET /events` - List events
- `GET /events/:id` - Get event details
- `POST /events/:id/join` - Join event circle

### Request Headers

All authenticated requests include:
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Error Handling

- **400**: Bad Request (validation errors)
- **401**: Unauthorized (invalid/expired token)
- **429**: Rate Limited
- **500**: Server Error

📖 **Detailed Documentation:** [BACKEND_INTEGRATION_COMPLETE.md](BACKEND_INTEGRATION_COMPLETE.md)

---

## 📁 Project Structure

```
waytree/
├── lib/
│   ├── config/
│   │   └── api_config.dart              # API configuration
│   ├── models/
│   │   ├── user.dart                    # User model
│   │   ├── user_profile.dart            # User profile model
│   │   ├── user_profile_auth.dart       # Auth profile model
│   │   ├── goal.dart                    # Goal model
│   │   ├── event.dart                   # Event & EventCircle models
│   │   ├── connection.dart              # Connection model
│   │   ├── qr_profile.dart              # QR profile model
│   │   ├── network_code.dart            # Network code model
│   │   ├── recommendation.dart          # Recommendation model
│   │   ├── my_spaces.dart               # Spaces model
│   │   ├── following.dart               # Following model
│   │   ├── assistant_activity.dart      # Assistant activity model
│   │   ├── assistant_alert.dart         # Assistant alert model
│   │   ├── chat_message.dart            # Chat message model
│   │   ├── goal_insights.dart           # Goal insights model
│   │   ├── profile_model.dart           # Profile model
│   │   └── tagged_person.dart           # Tagged person model
│   ├── screens/
│   │   ├── auth_entry_screen.dart       # Auth landing page
│   │   ├── email_input_screen.dart      # Email input
│   │   ├── otp_verify_screen.dart       # OTP verification
│   │   ├── simple_login_screen.dart     # Email/password login
│   │   ├── simple_signup_screen.dart    # Email/password signup
│   │   ├── signup_details_screen.dart   # Profile setup
│   │   ├── assistant_enrichment_screen.dart  # Profile enrichment
│   │   ├── main_screen.dart             # Main navigation
│   │   ├── dashboard_screen.dart        # Task dashboard
│   │   ├── assistant_screen.dart        # AI assistant
│   │   ├── assistant_chat_screen.dart   # Chat interface
│   │   ├── assistant_conversation_screen.dart  # Conversation view
│   │   ├── ai_profile_screen.dart       # AI profile view
│   │   ├── edit_profile_screen.dart     # Profile editing
│   │   ├── profile_viewer_screen.dart   # View profiles
│   │   ├── event_list_screen.dart       # Event browsing
│   │   ├── event_details_screen.dart    # Event details
│   │   ├── event_assistant_screen.dart  # Event assistant
│   │   ├── create_goal_screen.dart      # Goal creation
│   │   ├── goal_insights_screen.dart    # Goal analytics
│   │   ├── connections_list_screen.dart # Connection management
│   │   ├── my_spaces_screen.dart        # Spaces management
│   │   ├── following_list_screen.dart   # Following management
│   │   ├── followers_list_screen.dart   # Followers view
│   │   ├── recommendations_screen.dart  # Recommendations
│   │   ├── attention_alerts_screen.dart # Alerts
│   │   ├── create_qr_profile_screen.dart  # QR profile creation
│   │   └── create_network_code_screen.dart  # Network code creation
│   ├── services/
│   │   ├── auth_service.dart            # Authentication logic
│   │   ├── app_state.dart               # App state management
│   │   ├── profile_repository.dart      # Profile data access
│   │   ├── ai_profile_service.dart      # AI profile management
│   │   ├── documents_service.dart       # Document management
│   │   ├── goals_service.dart           # Goals management
│   │   ├── task_execution_service.dart  # Task execution
│   │   └── mock_data_service.dart       # Mock data for testing
│   ├── widgets/
│   │   ├── goal_card.dart               # Goal card widget
│   │   ├── profile_header.dart          # Profile header widget
│   │   ├── profile_section_card.dart    # Profile section widget
│   │   ├── qr_card.dart                 # QR card widget
│   │   ├── qr_scanner_view.dart         # QR scanner widget
│   │   ├── qr_profile_selector_sheet.dart  # QR profile selector
│   │   ├── network_code_card.dart       # Network code card
│   │   ├── network_code_selector_sheet.dart  # Network code selector
│   │   ├── networking_mode_view.dart    # Networking interface
│   │   ├── scan_result_bottom_sheet.dart  # Scan result sheet
│   │   ├── recommendation_card.dart     # Recommendation card
│   │   ├── assistant_activity_list.dart # Activity list
│   │   ├── assistant_snapshot.dart      # Assistant snapshot
│   │   ├── chat_log_view.dart           # Chat log view
│   │   ├── conversation_summary_card.dart  # Conversation summary
│   │   ├── activity_stats_card.dart     # Activity stats
│   │   ├── key_feedback_section.dart    # Feedback section
│   │   ├── match_insight_tile.dart      # Match insight tile
│   │   ├── match_insight_list_view.dart # Match insight list
│   │   ├── match_category_section.dart  # Match category section
│   │   ├── smart_recommendations_section.dart  # Recommendations section
│   │   └── summary_highlight_card.dart  # Summary highlight
│   ├── utils/
│   │   └── theme.dart                   # App theme
│   └── main.dart                        # App entry point
├── assets/
│   ├── images/                          # Image assets
│   └── data/                            # Data files
├── test/
│   └── widget_test.dart                 # Widget tests
├── pubspec.yaml                         # Dependencies
├── README.md                            # This file
├── AUTH_FLOW_README.md                  # Auth documentation
├── AI_PROFILE_API.md                    # AI profile API docs
├── EVENT_MODULE_README.md               # Event module docs
├── BACKEND_INTEGRATION.md               # Backend integration docs
├── PROFILE_API.md                       # Profile API docs
└── LICENSE                              # License file
```

---

## ⚙️ Configuration

### Dependencies

**Core Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  http: ^0.13.3                    # HTTP client
  provider: ^6.1.1                 # State management
  qr_code_scanner: ^1.0.1          # QR scanning
  intl: ^0.18.1                    # Internationalization
  flutter_secure_storage: ^9.0.0   # Secure storage
  file_picker: ^8.1.2              # File picking
```

### Environment Configuration

**API Base URL:**
- Development: `http://localhost:3000`
- Staging: `https://staging-api.waytree.com`
- Production: `https://api.waytree.com`

**Environment Variables:**
- `API_BASE_URL` - Backend API URL
- `API_TIMEOUT` - Request timeout (default: 30s)

### Theme Configuration

**Primary Colors:**
- Primary: Transformative Teal (`#00BFA5`)
- Success: Green (`#4CAF50`)
- Error: Red (`#F44336`)
- Warning: Orange (`#FF9800`)

**Typography:**
- Primary Font: System default
- Heading: Bold, 24-32px
- Body: Regular, 14-16px
- Caption: Light, 12-14px

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Manual Testing

**Authentication Flow:**
1. Launch app
2. Enter email
3. Verify OTP (check backend console for code)
4. Complete profile setup
5. Verify main screen loads

**Event Flow:**
1. Navigate to Events tab
2. Browse event list
3. Tap event to view details
4. Join event circle
5. Create task for event

**Networking Flow:**
1. Create QR profile
2. Generate QR code
3. Scan another user's QR code
4. Send connection request
5. View connection in list

**Profile Flow:**
1. Navigate to Profile tab
2. View AI-generated profile
3. Edit profile information
4. Upload documents
5. Regenerate AI profile

### Test Accounts

**Development:**
- Email: `test@example.com`
- OTP: `123456` (mock mode)

---

## 🗺️ Roadmap

### ✅ Completed Features

- [x] Email-based OTP authentication
- [x] Email/password authentication
- [x] AI-powered profile generation
- [x] Event management and circles
- [x] QR code networking
- [x] Network codes
- [x] Goal and task management
- [x] Connection management
- [x] My Spaces organization
- [x] Smart recommendations
- [x] AI assistant interface
- [x] Backend API integration
- [x] Document management

### 🚧 In Progress

- [ ] Voice interaction with AI
- [ ] Real-time chat
- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Event creation by users

### 📋 Planned Features

**Phase 1 - Core Enhancements:**
- [ ] Offline support and caching
- [ ] Token refresh mechanism
- [ ] Advanced search and filters
- [ ] Profile verification badges
- [ ] Connection notes and tags

**Phase 2 - AI Improvements:**
- [ ] Voice-to-text for assistant
- [ ] Multi-language support
- [ ] Sentiment analysis
- [ ] Conversation insights
- [ ] Automated follow-ups

**Phase 3 - Event Features:**
- [ ] Event creation by users
- [ ] Ticketing integration
- [ ] Event analytics
- [ ] Sponsor modules
- [ ] Live event features

**Phase 4 - Networking:**
- [ ] Video introductions
- [ ] Virtual coffee chats
- [ ] Group networking sessions
- [ ] Referral system
- [ ] Success stories

**Phase 5 - Enterprise:**
- [ ] Organization accounts
- [ ] Team management
- [ ] Custom branding
- [ ] API access
- [ ] White-label solution

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test thoroughly**
5. **Commit with clear messages**
   ```bash
   git commit -m "Add: feature description"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Create a Pull Request**

### Code Standards

- Follow Flutter/Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Write unit tests for new features
- Update documentation

### Commit Message Format

```
Type: Brief description

Detailed explanation (optional)

Types: Add, Update, Fix, Remove, Refactor, Docs, Test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

For questions, issues, or feature requests:

- **GitHub Issues**: [Create an issue](https://github.com/yourusername/waytree/issues)
- **Email**: support@waytree.com
- **Documentation**: See individual module README files

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Provider package for state management
- QR Code Scanner package
- All contributors and testers

---

## 📚 Additional Documentation

For detailed information about specific modules, see:

- [Authentication Flow](AUTH_FLOW_README.md) - Complete auth system documentation
- [AI Profile API](AI_PROFILE_API.md) - AI profile endpoints and integration
- [Event Module](EVENT_MODULE_README.md) - Event management features
- [Backend Integration](BACKEND_INTEGRATION.md) - API integration guide
- [Profile API](PROFILE_API.md) - Profile management endpoints
- [Quick Start Guide](AUTH_QUICK_START.md) - Get started quickly

---

<div align="center">

**Built with ❤️ using Flutter**

[Website](https://waytree.com) • [Documentation](https://docs.waytree.com) • [Blog](https://blog.waytree.com)

</div>