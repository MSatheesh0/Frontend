import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/theme.dart';
import '../services/networking_service.dart';
import '../services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'add_event_screen.dart';
import 'event_details_screen.dart';

class EventStatusScreen extends StatefulWidget {
  const EventStatusScreen({super.key});

  @override
  State<EventStatusScreen> createState() => _EventStatusScreenState();
}

class _EventStatusScreenState extends State<EventStatusScreen> with SingleTickerProviderStateMixin {
  final _networkingService = NetworkingService();
  late TabController _tabController;
  List<Event> _myEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<AppState>(context, listen: false).currentUser;
      
      // Fetch user's own events
      final myEventsData = await _networkingService.getAllEvents(my: true);
      List<Event> events = myEventsData.map((data) => _parseEvent(data)).toList();
      
      // If admin, also fetch all pending events
      if (user?.role == 'admin') {
        final pendingData = await _networkingService.getPendingEvents();
        final pendingEvents = pendingData.map((data) => _parseEvent(data)).toList();
        
        // Merge but avoid duplicates
        for (var pe in pendingEvents) {
          if (!events.any((e) => e.id == pe.id)) {
            events.add(pe);
          }
        }
      }

      if (mounted) {
        setState(() {
          _myEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading events: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Event _parseEvent(Map<String, dynamic> data) {
    final eventId = data['_id'] ?? data['id'] ?? '';
    return Event(
      id: eventId,
      name: data['name'] ?? '',
      headline: data['headline'],
      description: data['description'] ?? '',
      dateTime: data['dateTime'] != null 
          ? DateTime.parse(data['dateTime'])
          : DateTime.now(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      isEvent: data['isEvent'] ?? true,
      isCommunity: data['isCommunity'] ?? false,
      isVerified: data['isVerified'] ?? false,
      createdBy: data['createdBy'] is Map 
          ? (data['createdBy']['_id'] ?? data['createdBy']['id']) 
          : data['createdBy'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    // 1) Pending Events (isEvent && !isVerified)
    final pendingEvents = _myEvents.where((e) => e.isEvent && !e.isVerified).toList();
    
    // 2) Upcoming Events (isVerified && dateTime > now)
    final upcomingEvents = _myEvents.where((e) => e.isVerified && e.dateTime.isAfter(now)).toList();
    
    // 3) Completed Events (dateTime < now)
    // Note: Completed events can be verified or not, but usually they are verified.
    // User requested: "Show events where dateTime < currentDateTime"
    final completedEvents = _myEvents.where((e) => e.dateTime.isBefore(now)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Status'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEventList(pendingEvents, type: 'pending'),
                _buildEventList(upcomingEvents, type: 'upcoming'),
                _buildEventList(completedEvents, type: 'completed'),
              ],
            ),
    );
  }

  Widget _buildEventList(List<Event> events, {required String type}) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'pending' ? 'pending' : type} events found',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event, type);
      },
    );
  }

  Widget _buildEventCard(Event event, String type) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    final isCreator = event.createdBy == user?.id;
    final isAdmin = user?.role == 'admin';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (type == 'pending' && isAdmin)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _handleApprove(event),
                        tooltip: 'Approve',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _handleReject(event),
                        tooltip: 'Reject',
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(event.dateTime),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  event.location,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // View Details - Always available
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventDetailsScreen(event: event)),
                  ),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Details'),
                ),
                
                // Edit - Only for Upcoming and Creator
                if (type == 'upcoming' && isCreator)
                  TextButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEventScreen(event: event),
                        ),
                      );
                      if (result == true) _loadEvents();
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),

                // Delete/Cancel - For Creator or Admin
                if (isCreator || isAdmin)
                  TextButton.icon(
                    onPressed: () => _handleDelete(event, isCancel: type == 'pending'),
                    icon: Icon(
                      type == 'pending' ? Icons.close : Icons.delete_outline, 
                      size: 18, 
                      color: Colors.red
                    ),
                    label: Text(
                      type == 'pending' ? 'Cancel Request' : 'Delete',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleApprove(Event event) async {
    try {
      await _networkingService.approveEvent(event.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event approved!'), backgroundColor: Colors.green),
      );
      _loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleReject(Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Event'),
        content: const Text('Are you sure you want to reject and delete this event?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reject', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _networkingService.rejectEvent(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event rejected and deleted.')),
        );
        _loadEvents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleDelete(Event event, {bool isCancel = false}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCancel ? 'Cancel Event Request' : 'Delete Event'),
        content: Text(isCancel 
          ? 'Are you sure you want to cancel this event request?' 
          : 'Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text(isCancel ? 'Yes, Cancel' : 'Delete', style: const TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _networkingService.deleteEvent(event.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isCancel ? 'Event request cancelled.' : 'Event deleted successfully.')),
        );
        _loadEvents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
