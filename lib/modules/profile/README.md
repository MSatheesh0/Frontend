# Profile Module

## Overview
User profile management, AI-generated profiles, document management, and profile viewing.

## Features
- ✅ AI-generated profile summaries
- ✅ Profile editing
- ✅ Document management (pitch decks, resumes, portfolios)
- ✅ Profile viewing (self and others)
- ✅ Profile enrichment

## Files

### Models
- `user.dart` - Basic user model
- `user_profile.dart` - User profile model
- `profile_model.dart` - Extended profile model

### Screens
- `ai_profile_screen.dart` - AI-enhanced profile view
- `edit_profile_screen.dart` - Profile editing
- `profile_viewer_screen.dart` - View other profiles
- `profile_screen_backup.dart` - Backup profile screen

### Services
- `profile_repository.dart` - Profile data access
- `documents_service.dart` - Document management

### Widgets
- `profile_header.dart` - Profile header widget
- `profile_section_card.dart` - Profile section display

## Usage

```dart
import 'package:goal_networking_app/modules/profile/profile.dart';
```

## Dependencies
- Core (theme, config)
- AI Assistant module (for AI-generated content)
- Authentication module (for user data)

## API Endpoints
- `GET /me` - Get user profile
- `PUT /me` - Update user profile
- `GET /me/documents` - List documents
- `POST /me/documents` - Upload document
- `DELETE /me/documents/:id` - Delete document

## Profile Sections
- Basic Information (name, role, company)
- AI-Generated Summary
- Current Focus Areas
- Strengths & Skills
- Highlights & Achievements
- Documents

## Document Types
- PDF files (pitch decks, resumes)
- Links (YouTube, portfolio websites)
- Images
- Other attachments

## Documentation
See [PROFILE_API.md](../../../PROFILE_API.md) for detailed API documentation.
