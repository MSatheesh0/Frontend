import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SummaryHighlightCard extends StatelessWidget {
  final int totalAgents;
  final int strongMatches;
  final int maybeMatches;
  final int notNowMatches;
  final int followingsEngaged;

  const SummaryHighlightCard({
    super.key,
    required this.totalAgents,
    required this.strongMatches,
    required this.maybeMatches,
    required this.notNowMatches,
    this.followingsEngaged = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildInsightRow(
            icon: Icons.people_outline,
            title: 'Agents Contacted',
            value: totalAgents.toString(),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          _buildInsightRow(
            icon: Icons.check_circle_outline,
            title: 'Strong Matches',
            value: '$strongMatches ($maybeMatches maybes)',
          ),
          if (followingsEngaged > 0) ...[
            const SizedBox(height: AppConstants.spacingSm),
            _buildInsightRow(
              icon: Icons.favorite_outline,
              title: 'Followings Engaged',
              value: followingsEngaged.toString(),
            ),
          ],
          const SizedBox(height: AppConstants.spacingSm),
          _buildInsightRow(
            icon: Icons.lightbulb_outline,
            title: 'Top Feedback',
            value: 'Clarify traction & ticket size',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
