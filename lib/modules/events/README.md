# Events Module

## Overview
Event discovery, management, and event-based networking through event circles.

## Features
- ✅ Browse upcoming events
- ✅ Join event circles
- ✅ Create event-specific tasks
- ✅ Event-based networking
- ✅ Attendee discovery

## Files

### Models
- `event.dart` - Event and EventCircle models

### Screens
- `event_list_screen.dart` - Event browsing and discovery
- `event_details_screen.dart` - Event information and details
- `event_assistant_screen.dart` - Event-specific assistant

### Services
- `events_service.dart` - Event management (to be created)

## Usage

```dart
import 'package:goal_networking_app/modules/events/events.dart';
```

## Dependencies
- Core (theme, config)
- Goals module (for event tasks)
- Connections module (for attendee networking)

## API Endpoints
- `GET /events` - List upcoming events
- `GET /events/:id` - Get event details
- `POST /events/:id/join` - Join event circle
- `GET /events/:id/attendees` - Get event attendees

## Event Properties
- Name and description
- Date, time, and location
- Event banner/image
- Attendee count
- Join status

## Event Circles
Event circles are dedicated networking spaces for event attendees, enabling connections before, during, and after events.

## Documentation
See [EVENT_MODULE_README.md](../../../EVENT_MODULE_README.md) for detailed documentation.
