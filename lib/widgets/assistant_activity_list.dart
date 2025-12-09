import 'package:flutter/material.dart';
import '../models/assistant_activity.dart';
import '../utils/theme.dart';

class AssistantActivityList extends StatelessWidget {
  final List<AssistantActivity> activities;

  const AssistantActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    // Group activities by day
    final today = <AssistantActivity>[];
    final earlier = <AssistantActivity>[];

    for (var activity in activities.take(4)) {
      if (activity.timeAgo.contains('min') ||
          activity.timeAgo.contains('hour') ||
          activity.timeAgo == 'Just now') {
        today.add(activity);
      } else {
        earlier.add(activity);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (today.isNotEmpty) ...[
          _buildDayHeader(context, 'Today'),
          ...today.map((activity) => _buildActivityItem(context, activity)),
          const SizedBox(height: AppConstants.spacingMd),
        ],
        if (earlier.isNotEmpty) ...[
          _buildDayHeader(context, 'Earlier this week'),
          ...earlier.map((activity) => _buildActivityItem(context, activity)),
        ],

        // View all activity link
        const SizedBox(height: AppConstants.spacingSm),
        Center(
          child: TextButton(
            onPressed: () {
              // TODO: Navigate to full activity view
            },
            child: Text(
              'View all activity',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayHeader(BuildContext context, String day) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppConstants.spacingSm,
        top: AppConstants.spacingXs,
      ),
      child: Text(
        day,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, AssistantActivity activity) {
    final iconData = _getIconForActivity(activity.type);
    final iconColor = _getColorForActivity(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(iconData, color: iconColor, size: 18),
          ),
          const SizedBox(width: AppConstants.spacingSm),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  activity.timeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.connectionSuggestion:
        return Icons.person_add_outlined;
      case ActivityType.goalProgress:
        return Icons.trending_up;
      case ActivityType.research:
        return Icons.search;
      case ActivityType.reminder:
        return Icons.notifications_outlined;
      case ActivityType.insight:
        return Icons.lightbulb_outline;
    }
  }

  Color _getColorForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.connectionSuggestion:
        return AppTheme.primaryColor;
      case ActivityType.goalProgress:
        return AppTheme.successColor;
      case ActivityType.research:
        return AppTheme.infoColor;
      case ActivityType.reminder:
        return AppTheme.warningColor;
      case ActivityType.insight:
        return AppTheme.accentColor;
    }
  }
}
