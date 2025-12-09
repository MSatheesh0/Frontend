import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/recommendation.dart';
import '../utils/theme.dart';
import '../utils/recommendation_handler.dart';
import '../widgets/networking_mode_view_new.dart';
import '../widgets/goal_card.dart';
import '../widgets/assistant_snapshot.dart';
import '../widgets/assistant_activity_list.dart';
import '../widgets/smart_recommendations_section.dart';
import 'create_goal_screen.dart';
import 'goal_insights_screen.dart';
// QR Scanner not compatible with web - commented out
// import '../widgets/qr_scanner_view.dart';
// import '../widgets/scan_result_bottom_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tasks',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Networking mode toggle
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Networking Mode',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Switch(
                    value: appState.isNetworkingMode,
                    onChanged: (value) => appState.setNetworkingMode(value),
                    activeThumbColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Show networking mode if enabled
          if (appState.isNetworkingMode) {
            return const NetworkingModeView();
          }

          // Show scanner mode if enabled
          if (appState.isScannerMode) {
            return _buildScannerMode(context);
          }

          // Show dashboard based on goal status
          if (!appState.hasActiveGoal) {
            return _buildEmptyState(context);
          }

          return _buildActiveGoalState(context, appState);
        },
      ),
      floatingActionButton: Consumer<AppState>(
        builder: (context, appState, child) {
          // Only show FAB when there's an active goal
          if (!appState.hasActiveGoal) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ask Assistant coming soon!')),
              );
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // Mock goals for demo
    final mockGoals = [
      {'id': 'goal_1', 'title': 'Raise Pre-Seed Round', 'emoji': '💰'},
      {'id': 'goal_2', 'title': 'Find Technical Co-founder', 'emoji': '👨‍💻'},
      {'id': 'goal_3', 'title': 'Build Strategic Partnerships', 'emoji': '🤝'},
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacingXl),
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingXl),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                size: 60,
                color: AppTheme.primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              'You have no active tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Create a task and let your AI assistant\nhelp you achieve it',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateGoalScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                    vertical: AppConstants.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
                child: const Text(
                  'Create Task to Start',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            Text(
              'Or explore sample insights',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ...mockGoals.map((goal) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppConstants.spacingSm),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(
                        goal['emoji']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        goal['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppTheme.textTertiary,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GoalInsightsScreen(
                              goalId: goal['id']!,
                              goalTitle: goal['title']!,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )),
            const SizedBox(height: AppConstants.spacingXl),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGoalState(BuildContext context, AppState appState) {
    final goal = appState.activeGoal!;
    final activities = appState.activities;
    final recommendations = Recommendation.getMockRecommendations();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal Card
          GoalCard(goal: goal),
          const SizedBox(height: AppConstants.spacingLg),

          // Smart Recommendations Section
          SmartRecommendationsSection(
            recommendations: recommendations,
            onRecommendationTap: handleRecommendationTap,
          ),

          // Key Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalInsightsScreen(
                          goalId: goal.id,
                          goalTitle: goal.title,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.insights, size: 18),
                  label: const Text('View Insights'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spacingSm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingLg),

          // Assistant Snapshot
          const AssistantSnapshot(),
          const SizedBox(height: AppConstants.spacingLg),

          // Section Title
          Text(
            'Your Assistant is Working',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Activity List (grouped by day, max 4 items)
          AssistantActivityList(activities: activities),
        ],
      ),
    );
  }

  Widget _buildScannerMode(BuildContext context) {
    // QR Scanner not available on web
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            const Text(
              'QR Scanner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingXl),
              child: Text(
                'QR scanning is not available on web. Please use the mobile app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScan(BuildContext context, String code) {
    // Not used on web
  }
}
