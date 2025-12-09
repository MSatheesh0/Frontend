# AI-Built Profile Implementation

## Overview
Implemented a flexible, chat-based AI profile builder system that learns about users over time rather than using traditional forms.

## Features

### 1. AI Profile Screen (`lib/screens/ai_profile_screen.dart`)
A comprehensive profile view with:
- **Header Section**: User avatar, name, and headline
- **AI Profile Summary**: AI-generated summary of the user (with placeholder state when empty)
- **Current Focus**: Chip-style display of what the user is currently focused on
- **Strengths & Highlights**: Bulleted list of user's key strengths
- **Docs & Links**: Attachable documents and external links (PDF, web links)

#### Actions Available:
- **Refine with Assistant**: Opens chat with a profile refinement prompt
- **Copy HTML**: Generates and copies styled HTML version of the profile to clipboard
- **Attach Doc/Link**: Adds mock documents (one-pagers, LinkedIn, roadmaps, etc.)
- **Remove Docs**: Delete button on each attached document

### 2. Data Models (`lib/models/user_profile.dart`)

#### UserProfile
- `userId`: Unique identifier
- `displayName`: User's name
- `headline`: Optional tagline (e.g., "CEO & Founder at TechCorp")
- `aiSummary`: AI-generated profile summary paragraph
- `currentFocus`: List of current priorities/focus areas
- `strengths`: List of strengths and highlights
- `docs`: List of attached documents/links
- `lastUpdated`: Timestamp of last profile update
- `copyWith()`: Immutable update method

#### ProfileDoc
- `id`: Unique identifier
- `title`: Document/link title
- `type`: Either 'pdf' or 'link'
- `urlOrPath`: URL or file path
- `description`: Optional description

### 3. Profile Repository (`lib/services/profile_repository.dart`)
ChangeNotifier-based repository:
- **Mock Profile**: John Davidson (CEO, AI/Blockchain founder)
  - 4 strengths (Deep AI/ML expertise, Blockchain thought leader, etc.)
  - 3 current focus areas (Raising Series A, Product-market fit, Team scaling)
  - 2 attached docs (Pitch deck, LinkedIn profile)
- **Methods**:
  - `getProfile()`: Get current profile
  - `updateProfile(UserProfile)`: Update entire profile
  - `addDoc(ProfileDoc)`: Add document/link
  - `removeDoc(String id)`: Remove document
  - `notifyListeners()`: Reactive UI updates

### 4. Profile Utilities (`lib/utils/profile_utils.dart`)

#### `generateProfileHtml(UserProfile profile)`
Generates a complete HTML document with:
- Embedded CSS styling (modern card-based design)
- All profile sections (header, summary, focus, strengths, docs)
- Proper date formatting ("Updated: January 10, 2025")
- Ready to copy/paste or embed externally

#### `applyChatToProfile(UserProfile profile, String chatTranscript)`
AI logic placeholder that:
- Takes current profile and chat transcript
- Updates profile fields (currently adds mock strength, updates summary)
- Returns updated profile
- **TODO**: Replace with actual AI/LLM integration

### 5. Chat Integration (`lib/screens/assistant_chat_screen.dart`)
Updated AssistantChatScreen with:
- **Menu Action** (appears after 4+ messages): "Use chat to improve my profile"
- **Profile Update Flow**:
  1. Collects all chat messages into transcript
  2. Calls `applyChatToProfile()` with current profile and transcript
  3. Updates ProfileRepository (triggers reactive UI)
  4. Shows success snackbar

### 6. App Integration

#### Main App (`lib/main.dart`)
- Added `ProfileRepository` to MultiProvider
- Now provides both `AppState` and `ProfileRepository` globally

#### Dashboard (`lib/screens/dashboard_screen.dart`)
- Added person icon button in AppBar
- Clicking opens AIProfileScreen
- Easy access to profile from main navigation

## User Flow

### Creating/Updating Profile
1. User chats with assistant about their goals, expertise, needs
2. After conversation, user clicks "Use chat to improve my profile" in menu
3. Profile is updated automatically based on conversation
4. User can further refine by clicking "Refine with Assistant" from profile screen

### Viewing Profile
1. Click person icon in Dashboard AppBar
2. View all profile sections
3. See AI-generated summary (or placeholder if still learning)

### Exporting Profile
1. Open AI Profile Screen
2. Click "Copy HTML" button
3. View HTML in dialog
4. Click "Copy HTML" to copy to clipboard
5. Paste into external systems (websites, emails, etc.)

### Attaching Documents
1. Open AI Profile Screen
2. Click "Attach" button in Docs & Links section
3. Mock document is added (randomly selected from: One-Pager, LinkedIn, Roadmap)
4. Click delete icon to remove documents

## Mock Data
Profile comes pre-populated with John Davidson (CEO at AI startup):
- **Headline**: "CEO & Founder at TechCorp | AI & Blockchain Innovator"
- **AI Summary**: ~100 word professional summary
- **Focus Areas**: Raising Series A, Product-market fit, Team scaling
- **Strengths**: AI/ML expertise, Blockchain thought leader, 20+ patent portfolio, Stanford PhD
- **Docs**: Pitch deck (PDF), LinkedIn profile (link)

## Design Patterns
- **Provider/ChangeNotifier**: Reactive state management
- **Repository Pattern**: Clean separation of data layer
- **Mock Data**: All data is in-memory with realistic examples
- **Immutable Updates**: copyWith pattern for profile updates
- **Modular UI**: Reusable section widgets

## Future Enhancements (TODOs)
1. **AI Integration**: Replace `applyChatToProfile()` with real LLM API
2. **Real File Upload**: Replace mock docs with actual file picker
3. **Profile Privacy**: Add public/private toggles for sections
4. **Export Options**: PDF export, social media formatting
5. **Profile Templates**: Industry-specific profile templates
6. **Analytics**: Track profile views, engagement metrics
7. **Recommendations**: AI-suggested profile improvements
8. **Multi-language**: Support for multiple languages in profiles

## Technical Notes
- All profile operations trigger `notifyListeners()` for reactive UI
- HTML generation includes inline CSS for portability
- Profile screen uses Consumer<ProfileRepository> for reactivity
- Chat transcript format: "role: message" separated by double newlines
- Date formatting uses human-readable format ("January 10, 2025")

## Files Modified/Created
### Created:
- `lib/models/user_profile.dart` (models)
- `lib/services/profile_repository.dart` (repository)
- `lib/utils/profile_utils.dart` (utilities)
- `lib/screens/ai_profile_screen.dart` (UI)

### Modified:
- `lib/main.dart` (added ProfileRepository provider)
- `lib/screens/assistant_chat_screen.dart` (added profile improvement action)
- `lib/screens/dashboard_screen.dart` (added profile button)
