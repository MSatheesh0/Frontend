# Goals Module

## Overview
Goal creation, tracking, task management, and goal insights with AI-powered recommendations.

## Features
- ✅ Create and manage goals
- ✅ Task creation with event context
- ✅ Progress tracking
- ✅ Milestone management
- ✅ Goal insights and analytics
- ✅ AI-powered recommendations

## Files

### Models
- `goal.dart` - Goal model
- `goal_insights.dart` - Goal insights model

### Screens
- `dashboard_screen.dart` - Task dashboard
- `create_goal_screen.dart` - Goal creation
- `goal_insights_screen.dart` - Goal analytics

### Services
- `goals_service.dart` - Goals management
- `task_execution_service.dart` - Task execution logic

### Widgets
- `goal_card.dart` - Goal card widget
- `activity_stats_card.dart` - Activity statistics
- `summary_highlight_card.dart` - Summary highlights

## Usage

```dart
import 'package:goal_networking_app/modules/goals/goals.dart';
```

## Dependencies
- Core (theme, config)
- Events module (for event tasks)
- AI Assistant module (for recommendations)

## API Endpoints
- `GET /me/goals` - List goals
- `POST /me/goals` - Create goal
- `PUT /me/goals/:id` - Update goal
- `DELETE /me/goals/:id` - Delete goal
- `GET /me/goals/:id/insights` - Get goal insights

## Goal Categories
- Fundraising
- Hiring
- Product Development
- Growth
- Networking
- Learning
- Other

## Goal Properties
- Title and description
- Category
- Status (active, completed, paused, archived)
- Progress percentage
- Target date
- Milestones
- Context (event, circle, etc.)

## Task Execution
Tasks can be created with event context, automatically linking them to specific events for targeted networking.
