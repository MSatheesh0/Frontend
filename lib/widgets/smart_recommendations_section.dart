import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../utils/theme.dart';
import '../widgets/recommendation_card.dart';
import '../screens/recommendations_screen.dart';

class SmartRecommendationsSection extends StatelessWidget {
  final List<Recommendation> recommendations;
  final Function(BuildContext, Recommendation) onRecommendationTap;

  const SmartRecommendationsSection({
    super.key,
    required this.recommendations,
    required this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayRecommendations = recommendations.take(3).toList();
    final hasMore = recommendations.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 20,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    'Smart Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (hasMore)
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecommendationsScreen(
                          recommendations: recommendations,
                          onRecommendationTap: onRecommendationTap,
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),

        // Recommendations List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
          ),
          itemCount: displayRecommendations.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppConstants.spacingMd),
          itemBuilder: (context, index) {
            final recommendation = displayRecommendations[index];
            return RecommendationCard(
              recommendation: recommendation,
              onAction: () => onRecommendationTap(context, recommendation),
            );
          },
        ),
        const SizedBox(height: AppConstants.spacingLg),
      ],
    );
  }
}
