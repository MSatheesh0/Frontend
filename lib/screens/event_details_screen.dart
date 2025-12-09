import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/theme.dart';
import 'create_goal_screen.dart';
import 'event_assistant_screen.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late bool _isJoined;

  @override
  void initState() {
    super.initState();
    _isJoined = widget.event.isJoined;
  }

  void _joinEventCircle() {
    setState(() {
      _isJoined = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined ${widget.event.name} circle!'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: Add event circle to user's data
    // TODO: Create EventCircle object
    // final eventCircle = EventCircle(
    //   id: 'circle_${widget.event.id}',
    //   eventId: widget.event.id,
    //   eventName: widget.event.name,
    //   joinedAt: DateTime.now(),
    // );
  }

  void _createGoalForEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGoalScreen(
          eventId: widget.event.id,
          eventName: widget.event.name,
        ),
      ),
    );
  }

  void _openEventAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventAssistantScreen(event: widget.event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context, _isJoined),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.textPrimary),
            onPressed: () {
              // Share event
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.3),
                    AppTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.event,
                  size: 80,
                  color: AppTheme.primaryColor.withOpacity(0.6),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name
                  Text(
                    widget.event.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Date & time card
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date & Time',
                    subtitle:
                        '${dateFormat.format(widget.event.dateTime)}\n${timeFormat.format(widget.event.dateTime)}',
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Location card
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Location',
                    subtitle: widget.event.location,
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    widget.event.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Photos section
                  if (widget.event.photos.isNotEmpty) ...[
                    const Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.event.photos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 160,
                            margin: EdgeInsets.only(
                              right: index < widget.event.photos.length - 1
                                  ? AppConstants.spacingSm
                                  : 0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusSm),
                              image:
                                  widget.event.photos[index].startsWith('http')
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              widget.event.photos[index]),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                            ),
                            child: widget.event.photos[index].startsWith('http')
                                ? null
                                : Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],

                  // Videos section
                  if (widget.event.videos.isNotEmpty) ...[
                    const Text(
                      'Videos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    ...widget.event.videos.map((videoUrl) {
                      return Container(
                        height: 180,
                        margin: const EdgeInsets.only(
                            bottom: AppConstants.spacingSm),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],

                  // Join status or button
                  if (_isJoined) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 24,
                          ),
                          const SizedBox(width: AppConstants.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You are part of this event circle',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Start connecting with other attendees!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Create goal button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _createGoalForEvent,
                        icon: const Icon(Icons.flag_outlined, size: 18),
                        label: const Text('Create Task for This Event'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _joinEventCircle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusMd),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Join Event Circle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEventAssistant,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: const Text(
          'Ask Event Assistant',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
