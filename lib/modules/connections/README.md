# Connections Module

## Overview
Connection management, My Spaces organization, following system, and smart recommendations.

## Features
- ✅ View and manage connections
- ✅ Organize connections into spaces
- ✅ Follow/unfollow users
- ✅ Smart recommendations
- ✅ Connection insights
- ✅ Search and filter

## Files

### Models
- `connection.dart` - Connection model
- `my_spaces.dart` - Spaces model
- `following.dart` - Following model
- `recommendation.dart` - Recommendation model
- `tagged_person.dart` - Tagged person model

### Screens
- `connections_list_screen.dart` - Connection management
- `my_spaces_screen.dart` - Organized connection groups
- `following_list_screen.dart` - Following management
- `followers_list_screen.dart` - Followers view
- `recommendations_screen.dart` - Smart recommendations

### Widgets
- `recommendation_card.dart` - Recommendation card
- `smart_recommendations_section.dart` - Recommendations section
- `match_insight_tile.dart` - Match insight tile
- `match_insight_list_view.dart` - Match insight list
- `match_category_section.dart` - Match category section
- `key_feedback_section.dart` - Feedback section

## Usage

```dart
import 'package:goal_networking_app/modules/connections/connections.dart';
```

## Dependencies
- Core (theme, config)
- Profile module (for profile data)
- AI Assistant module (for recommendations)

## API Endpoints
- `GET /connections` - List connections
- `POST /connections` - Add connection
- `DELETE /connections/:id` - Remove connection
- `GET /connections/recommendations` - Get recommendations
- `GET /connections/spaces` - List spaces
- `POST /connections/spaces` - Create space

## My Spaces
Organize connections into custom spaces:
- Investors
- Mentors
- Potential Clients
- Team Members
- Event Connections
- Custom spaces

## Recommendations
AI-powered recommendations based on:
- Goals and objectives
- Profile similarity
- Mutual connections
- Event attendance
- Activity patterns
