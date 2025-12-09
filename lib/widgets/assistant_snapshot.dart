import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AssistantSnapshot extends StatelessWidget {
  const AssistantSnapshot({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.people_outline,
            label: 'Matches today',
            value: '12',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.chat_bubble_outline,
            label: 'Conversations',
            value: '3',
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.star_outline,
            label: 'Shortlisted',
            value: '8',
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
