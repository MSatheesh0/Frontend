
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/theme.dart';
import '../services/networking_service.dart';
import 'event_details_screen.dart';
import 'event_assistant_screen.dart';
import 'add_event_screen.dart';
import 'event_status_screen.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/user.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _networkingService = NetworkingService();
  List<Event> _events = [];
  String _selectedTab = 'event'; // 'event' or 'community'

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    try {
      // Load events from database
      final eventsData = await _networkingService.getAllEvents();
      
      if (!mounted) return;

      setState(() {
        _events = eventsData.map((eventData) {
          final eventId = eventData['_id'] ?? eventData['id'] ?? '';
          
          final isEvt = eventData['isEvent'] ?? true;
          final isComm = eventData['isCommunity'] ?? false;
          final isVer = eventData['isVerified'] ?? false;
          
          return Event(
            id: eventId,
            name: eventData['name'] ?? '',
            headline: eventData['headline'],
            description: eventData['description'] ?? '',
            dateTime: eventData['dateTime'] != null 
                ? DateTime.parse(eventData['dateTime'])
                : DateTime.now(),
            location: eventData['location'] ?? '',
            imageUrl: eventData['imageUrl'],
            isEvent: isEvt, 
            isCommunity: isComm,
            isVerified: isVer, // Check verification status
            isJoined: eventData['isJoined'] ?? false,
            photos: eventData['photos'] != null 
                ? List<String>.from(eventData['photos']) 
                : [],
            videos: eventData['videos'] != null 
                ? List<String>.from(eventData['videos']) 
                : [],
            tags: eventData['tags'] != null 
                ? List<String>.from(eventData['tags']) 
                : [],
            attendees: eventData['attendees'] != null
                ? List<String>.from(eventData['attendees'])
                : [],
            isPrimaryRecommendation: false,
            createdBy: eventData['createdBy'] is Map 
                ? (eventData['createdBy']['_id'] ?? eventData['createdBy']['id']) 
                : eventData['createdBy'],
          );
        }).where((event) => !event.isDismissed).toList().cast<Event>();
      });
    } catch (e) {
      print('Error loading events: $e');
      if (mounted) {
        setState(() {
          _events = []; // Better error handling
        });
      }
    }
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
        content: const Text('Dismissed'),
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

  void _joinEventCircle(Event event) async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final userId = appState.currentUser?.id ?? 'user_1';

      await _networkingService.joinEvent(
        eventId: event.id,
        participantId: userId,
      );

      if (mounted) {
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
    } catch (e) {
      print('Error joining event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to join. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    if (result == true) {
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic:
    // Tab "Events": Show if isEvent is true AND NOT isCommunity (Strict separation)
    // Tab "Communities": Show if isCommunity is true AND isVerified is true
    
    final filteredEvents = _events.where((e) {
      if (_selectedTab == 'event') {
         // Prevent communities from showing here even if isEvent is accidentally true
         return e.isEvent && !e.isCommunity; 
      } else {
         // Only show verified communities
         return e.isCommunity && e.isVerified;
      }
    }).toList();
    
    final primaryEvents =
        filteredEvents.where((e) => e.isPrimaryRecommendation).toList();
    final otherEvents =
        filteredEvents.where((e) => !e.isPrimaryRecommendation).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Circles', 
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventStatusScreen(
                    initialTab: _selectedTab,
                    hideToggle: true,
                  ),
                ),
              );
              if (result == true) {
                _loadEvents();
              }
            },
            tooltip: _selectedTab == 'event' ? 'Event Status' : 'Community Status',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
            onPressed: () async {
              final isComm = _selectedTab == 'community';
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventScreen(
                    initialIsEvent: !isComm,
                    initialIsCommunity: isComm,
                  ),
                ),
              );
              if (result == true) {
                _loadEvents();
              }
            },
            tooltip: 'Add New',
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle UI
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildTabButton('Events', 'event'),
                const SizedBox(width: 12),
                _buildTabButton('Communities', 'community'),
              ],
            ),
          ),
          
          Expanded(
            child: filteredEvents.isEmpty
              ? RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                       height: MediaQuery.of(context).size.height * 0.6,
                       child: _buildEmptyState(),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    children: [
                      if (primaryEvents.isNotEmpty) ...[
                        Text(
                          'Recommended for you',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        ...primaryEvents.map((event) => _buildEventCard(event)),
                        const SizedBox(height: AppConstants.spacingLg),
                      ],
    
                      if (otherEvents.isNotEmpty) ...[
                        Text(
                          'Explore ${_selectedTab == 'community' ? 'Communities' : 'Events'}',
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
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedTab == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
             label,
             style: TextStyle(
               color: isSelected ? Colors.white : Colors.grey[600],
               fontWeight: FontWeight.w600,
               fontSize: 14,
             ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
     _loadEvents();
     // Also reload user profile for sync
     try {
       final userMap = await AuthService().fetchUserProfile();
       if (mounted) {
           final user = User.fromMap(userMap);
           Provider.of<AppState>(context, listen: false).setUser(user);
       }
     } catch (_) {}
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
                    // Manage Circle Icon (for creator or admin)
                    _buildManageIcon(event),
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
                if (event.matchReason != null) ...[
                  const SizedBox(height: AppConstants.spacingSm),
                  // WHY this event is relevant
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
                ],
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

                // Result Action Buttons Logic
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
                  // SHOW JOIN BUTTON FOR EVERYONE (EVENTS + COMMUNITIES)
                  Row(
                    children: [
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
                            'Join',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingSm),
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

  Widget _buildManageIcon(Event event) {
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    final isCreator = event.createdBy == user?.id;
    final isAdmin = user?.role == 'admin';

    if (!isCreator && !isAdmin) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.settings_outlined, size: 20, color: AppTheme.primaryColor),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEventScreen(event: event),
          ),
        );
        if (result == true) _loadEvents();
      },
      tooltip: 'Edit Circle',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
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
              'No $_selectedTab${_selectedTab == 'community' ? 'ies' : 's'} found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Create a task or add a new one!',
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

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF10B981); // Emerald
    if (percentage >= 60) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFFF59E0B); // Amber
  }
}
