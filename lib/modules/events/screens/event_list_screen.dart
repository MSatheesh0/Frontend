import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/theme.dart';
import 'event_details_screen.dart';
import 'event_assistant_screen.dart';
import 'package:intl/intl.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    // Mock curated events based on user's active goal
    // TODO: Replace with API call that returns goal-relevant events
    setState(() {
      _events = [
        // Primary recommendations (top 3)
        Event(
          id: 'event_1',
          name: 'TechCrunch Disrupt 2025',
          description:
              'Join thousands of founders, investors, and tech leaders for the most influential startup event of the year.',
          dateTime: DateTime.now().add(const Duration(days: 15)),
          location: 'Moscone Center, San Francisco',
          imageUrl: null,
          isPrimaryRecommendation: true,
          matchReason: '23 investors match your fundraising goal',
          matchLevel: 'High match',
          matchPercentage: 94,
          photos: ['photo_1', 'photo_2', 'photo_3'],
          videos: ['video_1'],
        ),
        Event(
          id: 'event_3',
          name: 'AI Founders Meetup',
          description:
              'Network with AI founders, share challenges, and explore collaboration opportunities.',
          dateTime: DateTime.now().add(const Duration(days: 7)),
          location: 'WeWork SoMa, San Francisco',
          imageUrl: null,
          isPrimaryRecommendation: true,
          matchReason: 'Strong fit: AI + SaaS (92% match)',
          matchLevel: '92% match',
          matchPercentage: 92,
          photos: ['photo_1', 'photo_2'],
          videos: [],
        ),
        Event(
          id: 'event_2',
          name: 'Y Combinator Demo Day',
          description:
              'Watch the latest batch of YC startups pitch their companies to top investors.',
          dateTime: DateTime.now().add(const Duration(days: 30)),
          location: 'YC Headquarters, Mountain View',
          imageUrl: null,
          isPrimaryRecommendation: true,
          matchReason: '5 people from your circles are attending',
          matchLevel: 'High match',
          matchPercentage: 88,
          photos: ['photo_1'],
          videos: ['video_1', 'video_2'],
        ),

        // Other circles to explore (2 more)
        Event(
          id: 'event_4',
          name: 'SaaS Summit 2025',
          description:
              'Learn from successful SaaS founders about scaling, product-market fit, and growth strategies.',
          dateTime: DateTime.now().add(const Duration(days: 45)),
          location: 'Marriott Marquis, San Francisco',
          imageUrl: null,
          isPrimaryRecommendation: false,
          matchReason: '8 SaaS founders match your interests',
          matchLevel: 'Medium match',
          matchPercentage: 72,
        ),
        Event(
          id: 'event_5',
          name: 'Startup Grind Global',
          description:
              'Connect with entrepreneurs from around the world at the largest independent startup conference.',
          dateTime: DateTime.now().add(const Duration(days: 60)),
          location: 'Silicon Valley Convention Center',
          imageUrl: null,
          isPrimaryRecommendation: false,
          matchReason: 'Popular with founders in your network',
          matchLevel: 'Medium match',
          matchPercentage: 68,
        ),
      ].where((event) => !event.isDismissed).toList();
    });
  }

  void _dismissEvent(Event event) {
    setState(() {
      _events = _events
          .map((e) {
            if (e.id == event.id) {
              return e.copyWith(isDismissed: true);
            }
            return e;
          })
          .where((e) => !e.isDismissed)
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Event dismissed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _events.add(event);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _joinEventCircle(Event event) {
    setState(() {
      _events = _events.map((e) {
        if (e.id == event.id) {
          return e.copyWith(isJoined: true);
        }
        return e;
      }).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined ${event.name} circle!'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEventAssistant(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventAssistantScreen(event: event),
      ),
    );
  }

  void _viewEventDetails(Event event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );

    // Refresh if event status changed
    if (result == true) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryEvents =
        _events.where((e) => e.isPrimaryRecommendation).toList();
    final otherEvents =
        _events.where((e) => !e.isPrimaryRecommendation).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Event Circles',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _events.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              children: [
                // Header
                Text(
                  'Recommended for you',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Based on your active goals',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Primary recommendations
                ...primaryEvents.map((event) => _buildEventCard(event)),

                // Other circles section
                if (otherEvents.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingLg),
                  Text(
                    'Other circles to explore',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  ...otherEvents.map((event) => _buildEventCard(event)),
                ],
              ],
            ),
    );
  }

  Widget _buildEventCard(Event event) {
    final dateFormat = DateFormat('MMM dd');
    final daysUntil = event.dateTime.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Event name + Match badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Date badge
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                daysUntil == 0
                                    ? 'Today'
                                    : daysUntil == 1
                                        ? 'Tomorrow'
                                        : '${dateFormat.format(event.dateTime)} • In $daysUntil days',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    // Match percentage badge
                    if (event.matchPercentage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getMatchColor(event.matchPercentage!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getMatchColor(event.matchPercentage!)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${event.matchPercentage}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _getMatchColor(event.matchPercentage!),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),

                // WHY this event is relevant - PROMINENT
                if (event.matchReason != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.matchReason!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppConstants.spacingMd),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Action buttons
                if (event.isJoined)
                  // Joined state
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Joined',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Not joined - show action buttons
                  Row(
                    children: [
                      // Join Circle button (primary)
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => _joinEventCircle(event),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusSm),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Join Circle',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
                      // Not interested button
                      Expanded(
                        child: TextButton(
                          onPressed: () => _dismissEvent(event),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Not interested',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // Bottom action links
                const SizedBox(height: AppConstants.spacingSm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // View Details
                    Expanded(
                      child: InkWell(
                        onTap: () => _viewEventDetails(event),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    // Ask Event Assistant
                    Expanded(
                      child: InkWell(
                        onTap: () => _openEventAssistant(event),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ask Assistant',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 85) {
      return AppTheme.successColor;
    } else if (percentage >= 70) {
      return const Color(0xFFF59E0B); // Amber
    } else {
      return AppTheme.textSecondary;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.diversity_3_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              'No Matching Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Create a task and your assistant will find relevant event circles',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
