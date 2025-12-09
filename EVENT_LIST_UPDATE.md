# Event List UI Update - Goal-Relevant Curated Events

## Overview
Updated the Event List screen to display curated, goal-relevant events with clear match explanations and actionable insights.

## ✅ Key Changes

### 1. Curated Event Lists (Not Generic)
- **Primary Recommendations** (Top 3 events)
  - Highest relevance to user's active goal
  - Displayed first with "Recommended for you" header
  - Subtitle: "Based on your active goals"
  
- **Other Circles to Explore** (2 events)
  - Secondary recommendations
  - Lower match scores but still relevant
  - Separate section below primary events

### 2. Match Reason - WHY This Event is Useful
Each event card prominently displays a reason, such as:
- ✨ "23 investors match your fundraising goal"
- ✨ "Strong fit: AI + SaaS (92% match)"
- ✨ "5 people from your circles are attending"
- ✨ "8 SaaS founders match your interests"
- ✨ "Popular with founders in your network"

**Display:**
- Highlighted in a pastel blue box with star icon
- Positioned directly below event name
- Bold, easy-to-read font

### 3. Relevance Indicators
- **Match Percentage Badge**: Top-right corner showing "94%", "92%", etc.
- **Color-coded**:
  - Green (85%+): High match
  - Amber (70-84%): Medium match
  - Gray (<70%): Lower match
- **Match Level**: Stored as "High match", "Medium match", or percentage string

### 4. Primary Actions on Each Card

**If Not Joined:**
- **"Join Circle"** button (primary, filled)
  - Blue background, white text
  - Takes up 2/3 of button row
  - Marks user as part of event circle
  - Shows success snackbar
  
- **"Not interested"** button (secondary, text-only)
  - Gray text
  - Takes up 1/3 of button row
  - Dismisses event from list
  - Shows "Undo" snackbar

**If Already Joined:**
- Green success banner: "✓ Joined"
- Replaces action buttons

### 5. "Ask Event Assistant" Link
- Small link at bottom of each card
- Icon: Chat bubble outline
- Opens Event Assistant screen for that specific event
- TODO: Implement Event Assistant chat screen

### 6. Updated Data Model

**Event model now includes:**
```dart
String? matchReason;        // Why relevant
String? matchLevel;         // "High match", "Medium match"
int? matchPercentage;       // 0-100
bool isPrimaryRecommendation; // Top 3 vs other circles
bool isDismissed;           // User dismissed
```

## 🎨 UI/UX Design

### Card Layout
1. **Header Row**: Event name + Match percentage badge
2. **Date Badge**: Small calendar icon + "In X days"
3. **Match Reason Box**: ⭐ Highlighted reason (pastel blue background)
4. **Location**: 📍 Pin icon + venue
5. **Action Buttons**: Join Circle + Not interested
6. **Footer Link**: Ask Event Assistant

### Visual Style
- Clean white cards with subtle borders
- Pastel blue highlight for match reasons
- Color-coded match badges (green/amber/gray)
- Success green for joined state
- Consistent spacing using AppConstants
- No banner images (focused on data)

### Empty State
- Icon: diversity/group icon
- Title: "No Matching Events"
- Message: "Create a task and your assistant will find relevant event circles"

## 🔄 New Behaviors

### Join Circle
```dart
void _joinEventCircle(Event event)
```
- Updates event state to `isJoined: true`
- Shows green success snackbar
- Replaces buttons with "Joined" banner

### Dismiss Event
```dart
void _dismissEvent(Event event)
```
- Marks event as `isDismissed: true`
- Removes from visible list
- Shows snackbar with "Undo" action
- Can restore if user taps Undo

### Ask Event Assistant
```dart
void _openEventAssistant(Event event)
```
- TODO: Navigate to Event Assistant chat screen
- Currently shows placeholder snackbar

## 📊 Mock Data Examples

**High Match (94%):**
- TechCrunch Disrupt 2025
- Reason: "23 investors match your fundraising goal"

**High Match (92%):**
- AI Founders Meetup
- Reason: "Strong fit: AI + SaaS (92% match)"

**High Match (88%):**
- Y Combinator Demo Day
- Reason: "5 people from your circles are attending"

**Medium Match (72%):**
- SaaS Summit 2025
- Reason: "8 SaaS founders match your interests"

**Medium Match (68%):**
- Startup Grind Global
- Reason: "Popular with founders in your network"

## 🚀 Next Steps

### Backend Integration
- [ ] API endpoint: GET /events/recommended?goalId=X
- [ ] Return events with match scores and reasons
- [ ] POST /events/{id}/join - Join event circle
- [ ] POST /events/{id}/dismiss - Store dismissal preference

### Event Assistant
- [ ] Create EventAssistantScreen(eventId: string)
- [ ] Event-specific chat context
- [ ] Pre-loaded questions about event
- [ ] Show attendee insights

### Enhanced Matching
- [ ] Real ML-based match scoring
- [ ] Factor in: goal tags, user profile, network overlap
- [ ] A/B test different reason formats
- [ ] Track which reasons drive most joins

### Future Features
- [ ] "Tell me more" - expand match reason
- [ ] Show sample attendees (profile pics)
- [ ] Calendar integration
- [ ] Reminder notifications
- [ ] Post-event follow-ups

## 📝 Technical Notes

- All events filtered by `isDismissed: false`
- Events sorted by `isPrimaryRecommendation` then `matchPercentage`
- Color thresholds: 85% (green), 70% (amber), <70% (gray)
- Undo dismissal supported via snackbar action
- No navigation to EventDetailsScreen (removed for MVP)

---

**Updated:** November 21, 2025  
**Status:** ✅ Complete - Ready for Testing  
**Focus:** Goal-relevant curation with clear "why" explanations
