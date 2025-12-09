import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../utils/theme.dart';

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback onAction;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onAction,
  });

  IconData _getIconForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.matchNda:
        return Icons.assignment_outlined;
      case RecommendationType.missingPitchInfo:
        return Icons.description_outlined;
      case RecommendationType.missingBusinessInfo:
        return Icons.info_outline;
      case RecommendationType.missedOpportunities:
        return Icons.warning_amber_outlined;
      case RecommendationType.eventSuggestion:
        return Icons.event_outlined;
      case RecommendationType.profileImprovement:
        return Icons.person_outline;
      case RecommendationType.generalAdvice:
        return Icons.lightbulb_outline;
    }
  }

  Color _getColorForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.matchNda:
        return const Color(0xFF4CAF50); // Green
      case RecommendationType.missingPitchInfo:
        return const Color(0xFFFF9800); // Orange
      case RecommendationType.missingBusinessInfo:
        return const Color(0xFF2196F3); // Blue
      case RecommendationType.missedOpportunities:
        return const Color(0xFFF44336); // Red
      case RecommendationType.eventSuggestion:
        return const Color(0xFF9C27B0); // Purple
      case RecommendationType.profileImprovement:
        return AppTheme.primaryColor;
      case RecommendationType.generalAdvice:
        return const Color(0xFF607D8B); // Grey
    }
  }

  String _getButtonTextForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.matchNda:
        return 'Review & Approve';
      case RecommendationType.missingPitchInfo:
        return 'Fix Pitch Deck';
      case RecommendationType.missingBusinessInfo:
        return 'Provide Info';
      case RecommendationType.missedOpportunities:
        return 'See How to Fix';
      case RecommendationType.eventSuggestion:
        return 'Plan with Assistant';
      case RecommendationType.profileImprovement:
        return 'Improve Profile';
      case RecommendationType.generalAdvice:
        return 'Open in Assistant';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(recommendation.type);
    final icon = _getIconForType(recommendation.type);
    final buttonText = _getButtonTextForType(recommendation.type);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (recommendation.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    recommendation.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppConstants.spacingSm),

                // Action Button
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
