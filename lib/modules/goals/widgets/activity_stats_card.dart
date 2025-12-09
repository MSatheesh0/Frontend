import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ActivityStatsCard extends StatelessWidget {
  final int totalContacted;
  final int conversationsInProgress;
  final int positiveInterest;
  final int declined;

  const ActivityStatsCard({
    super.key,
    required this.totalContacted,
    required this.conversationsInProgress,
    required this.positiveInterest,
    required this.declined,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatTile('Total Contacted', totalContacted.toString(),
            AppTheme.primaryColor),
        const SizedBox(width: AppConstants.spacingSm),
        _buildStatTile('In Progress', conversationsInProgress.toString(),
            AppTheme.accentColor),
        const SizedBox(width: AppConstants.spacingSm),
        _buildStatTile(
            'Positive', positiveInterest.toString(), AppTheme.successColor),
        const SizedBox(width: AppConstants.spacingSm),
        _buildStatTile('Declined', declined.toString(), Colors.grey[400]!),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
