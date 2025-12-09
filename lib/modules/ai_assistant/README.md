# AI Assistant Module

## Overview
AI-powered assistant that provides recommendations, insights, and conversational interface for goal-based networking.

## Features
- ✅ Conversational AI interface
- ✅ Profile analysis and enrichment
- ✅ Connection recommendations
- ✅ Goal insights and suggestions
- ✅ Activity tracking
- ✅ Smart alerts and notifications

## Files

### Models
- `assistant_activity.dart` - Activity tracking model
- `assistant_alert.dart` - Alert system model
- `chat_message.dart` - Chat message model

### Screens
- `assistant_screen.dart` - Main assistant interface
- `assistant_chat_screen.dart` - Chat interface
- `assistant_conversation_screen.dart` - Conversation view
- `attention_alerts_screen.dart` - Alerts and notifications

### Services
- `ai_profile_service.dart` - AI profile management and API calls

### Widgets
- `assistant_activity_list.dart` - Activity list widget
- `assistant_snapshot.dart` - Assistant snapshot widget
- `chat_log_view.dart` - Chat log display
- `conversation_summary_card.dart` - Conversation summary

## Usage

```dart
import 'package:goal_networking_app/modules/ai_assistant/ai_assistant.dart';
```

## Dependencies
- Core (theme, config)
- Profile module (for profile data)
- Groq API for AI capabilities

## API Endpoints
- `GET /me/ai-profile` - Get AI-generated profile
- `POST /me/ai-profile/regenerate` - Regenerate AI profile
- `GET /assistant/recommendations` - Get recommendations
- `POST /assistant/chat` - Chat with assistant

## AI Capabilities
- Profile summarization
- Connection matching
- Goal recommendations
- Event suggestions
- Conversation analysis
- Activity insights

## Documentation
See [AI_PROFILE_API.md](../../../AI_PROFILE_API.md) for detailed API documentation.
