# Dynamic AI-Driven Profile Screen

## Overview
The Profile Screen is designed to be dynamic and AI-controlled, where the order and visibility of sections can be determined by the AI assistant based on context, user goals, and relevance.

## Architecture

### 1. Data Models (`lib/models/profile_model.dart`)

#### ProfileHeaderInfo
Static header information that appears at the top:
- `name`: User's full name
- `handle`: User's unique handle (e.g., @johnd1290)
- `photoUrl`: Profile picture URL
- `tagline`: Editable user tagline/bio

#### ProfileSection
Dynamic section that can be reordered and toggled:
- `type`: Section identifier (current_goals, ai_summary, interests, etc.)
- `title`: Display title
- `description`: Optional text description
- `items`: Optional list of section-specific items
- `isPinned`: Whether section is pinned to top
- `isVisible`: Whether section is currently shown

#### ProfileScreenModel
Main model containing:
- `headerInfo`: Static header data
- `dynamicSections`: List of reorderable sections

### 2. UI Components

#### ProfileHeader (`lib/widgets/profile_header.dart`)
- Static header with circular avatar
- Name, handle, and editable tagline
- White background with grey border
- Always visible at top

#### ProfileSectionCard (`lib/widgets/profile_section_card.dart`)
Renders different section types:
- **Current Goals**: Progress bars with status badges
- **AI Summary**: Text block with assistant-generated description
- **Interests**: Tag chips with colored borders
- **Circles & Communities**: List of groups with member counts
- **Projects**: Project cards with status badges
- **Recent Tasks**: Bullet list of assistant activities
- **Social Links**: Platform links with icons

Each section has:
- Pin button (to keep at top)
- Visibility toggle (for certain sections)
- Border highlight when pinned

#### ProfileScreen (`lib/screens/profile_screen.dart`)
Main screen features:
- CustomScrollView with slivers
- Static header + dynamic sections
- Floating "Manage Sections" button
- Bottom sheet for section management

### 3. Section Management

Users can:
1. **Reorder sections**: Drag and drop to rearrange
2. **Pin sections**: Keep important sections at top
3. **Toggle visibility**: Show/hide certain sections
4. **View in modal**: Full-screen section manager

## AI-Driven Logic (Future)

The current implementation uses mock data, but is designed for AI control:

```dart
// Future: AI determines section order based on:
// - User's active goal context
// - Recent activities
// - Connection patterns
// - Time of day
// - Upcoming meetings

ProfileScreenModel getAIDrivenProfile(User user, Context context) {
  // AI analyzes:
  // 1. User's current goal ("Raise Pre-Seed Round")
  // 2. Recent assistant activities
  // 3. Connection patterns
  // 4. Time-based relevance
  
  // Returns dynamically ordered sections:
  return ProfileScreenModel(
    sections: [
      // Goal-relevant sections first
      ProfileSection(type: 'current_goals', isPinned: true),
      ProfileSection(type: 'recent_tasks'),
      
      // Context-specific sections
      if (hasUpcomingInvestorMeetings)
        ProfileSection(type: 'investor_pitch'),
      
      // Standard sections
      ProfileSection(type: 'ai_summary'),
      ProfileSection(type: 'interests'),
      // ...
    ],
  );
}
```

## Section Types

### current_goals
Shows active goals with:
- Goal title
- Status badge (Active, In Progress, Completed)
- Progress bar (0.0 to 1.0)

### ai_summary
AI-generated profile summary showing:
- Expertise areas
- Current focus
- Key achievements

### interests
Tag chips showing:
- Topics of interest
- Skills
- Industries

### circles
Community memberships with:
- Circle name
- Member count
- Circle icon

### projects
Highlighted projects with:
- Project name
- Description
- Status (Active/Completed)

### recent_tasks
Bullet list of:
- Recent assistant activities
- Match updates
- Scheduled actions

### social_links
External links to:
- LinkedIn
- Twitter
- GitHub
- Other platforms

## Theming

Follows app-wide clean theme:
- Background: `grey[50]`
- Cards: White with `grey[300]` borders
- No heavy shadows
- Minimal, clean design
- Consistent spacing (AppConstants)

## Usage

Navigate to Profile via bottom navigation:
```dart
// Already integrated in MainScreen
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icons.dashboard, label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icons.person, label: 'Profile'),
  ],
);
```

## Future Enhancements

1. **Real-time AI Updates**: Sections reorder based on context changes
2. **Section Templates**: Predefined layouts for different user types
3. **Custom Sections**: Users can create custom sections
4. **Analytics**: Track which sections get most engagement
5. **Smart Suggestions**: AI suggests which sections to show/hide
6. **Section Animations**: Smooth transitions when reordering
7. **Section Collaboration**: Share specific sections with others

## Mock Data

Current implementation includes:
- Sample user: "John Davidson" (@johnd1290)
- 2 active goals
- AI summary paragraph
- 6 interests
- 3 circles
- 2 projects
- 3 recent tasks
- 3 social links

All mock data is in `ProfileScreenModel.getMockProfile()` method.
