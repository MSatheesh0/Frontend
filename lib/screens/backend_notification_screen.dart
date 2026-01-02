import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/app_notification_service.dart';
import '../services/app_state.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

class BackendNotificationScreen extends StatefulWidget {
  const BackendNotificationScreen({super.key});

  @override
  State<BackendNotificationScreen> createState() => _BackendNotificationScreenState();
}

class _BackendNotificationScreenState extends State<BackendNotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).refreshNotifications();
    });
  }

  Future<void> _dismiss(BuildContext context, String id) async {
    await Provider.of<AppState>(context, listen: false).dismissNotification(id);
  }

  Future<void> _dismissGroup(BuildContext context, List<AppNotification> group) async {
    for (var n in group) {
      await Provider.of<AppState>(context, listen: false).dismissNotification(n.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: AppTheme.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final notifications = appState.notifications;
          
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          // Grouping logic
          final Map<String, List<AppNotification>> eventGroups = {};
          for (var n in notifications) {
            if (n.isDismissed) continue;
            if (!eventGroups.containsKey(n.eventId)) {
              eventGroups[n.eventId] = [];
            }
            eventGroups[n.eventId]!.add(n);
          }

          final List<Widget> listItems = [];

          eventGroups.forEach((eventId, notifs) {
            notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final eventName = notifs.first.eventName;
            
            if (notifs.length <= 5) {
              for (var n in notifs) {
                listItems.add(_buildNotificationTile(context, n));
              }
            } else {
              for (var i = 0; i < 5; i++) {
                 listItems.add(_buildNotificationTile(context, notifs[i]));
              }
              final remainingCount = notifs.length - 5;
              listItems.add(_buildGroupTile(context, remainingCount, eventName, notifs.sublist(5)));
            }
          });

          return RefreshIndicator(
            onRefresh: () => appState.refreshNotifications(),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: listItems,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, AppNotification n) {
    return Dismissible(
      key: Key(n.id),
      onDismissed: (direction) => _dismiss(context, n.id),
      background: Container(
        color: Colors.red[100],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          backgroundImage: n.actorPhotoUrl != null ? NetworkImage(n.actorPhotoUrl!) : null,
          child: n.actorPhotoUrl == null ? Text(n.actorName[0], style: const TextStyle(color: AppTheme.primaryColor)) : null,
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            children: [
              TextSpan(text: n.actorName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: ' had been joined the event '),
              TextSpan(text: n.eventName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ],
          ),
        ),
        subtitle: Text(
          DateFormat.jm().format(n.createdAt),
          style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18, color: AppTheme.textTertiary),
          onPressed: () => _dismiss(context, n.id),
        ),
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, int count, String eventName, List<AppNotification> group) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: const Icon(Icons.group_add, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        '$count others added to this event',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(eventName, style: const TextStyle(fontSize: 12)),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18, color: AppTheme.textTertiary),
        onPressed: () => _dismissGroup(context, group),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No notifications', style: TextStyle(color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}
