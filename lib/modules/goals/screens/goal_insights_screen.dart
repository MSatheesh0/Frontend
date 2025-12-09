import 'package:flutter/material.dart';
import '../../../models/goal_insights.dart';
import '../utils/theme.dart';
import '../widgets/summary_highlight_card.dart';
import '../widgets/key_feedback_section.dart';
import '../widgets/match_insight_list_view.dart';

class GoalInsightsScreen extends StatefulWidget {
  final String goalId;
  final String goalTitle;

  const GoalInsightsScreen({
    super.key,
    required this.goalId,
    required this.goalTitle,
  });

  @override
  State<GoalInsightsScreen> createState() => _GoalInsightsScreenState();
}

class _GoalInsightsScreenState extends State<GoalInsightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late GoalInsights insights;

  @override
  void initState() {
    super.initState();
    insights = GoalInsights.getMockInsights(widget.goalId, widget.goalTitle);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strongMatches =
        insights.matches.where((m) => m.category == 'strong').toList();
    final maybeMatches =
        insights.matches.where((m) => m.category == 'maybe').toList();
    final notNowMatches =
        insights.matches.where((m) => m.category == 'not_now').toList();
    final contactedMatches =
        insights.matches.where((m) => m.category == 'contacted').toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Insights',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.goalTitle,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Highlight Card
                  SummaryHighlightCard(
                    totalAgents: insights.totalAgents,
                    strongMatches: insights.strongMatches,
                    maybeMatches: insights.maybeMatches,
                    notNowMatches: insights.notNowMatches,
                    followingsEngaged: insights.followingsEngaged,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  // Common Feedback Section
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: KeyFeedbackSection(feedback: insights.keyFeedback),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingSm),

            // TabBar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  _buildTab('Strong', strongMatches.length, 'strong'),
                  _buildTab('Maybe', maybeMatches.length, 'maybe'),
                  _buildTab('Not Now', notNowMatches.length, 'not_now'),
                  _buildTab('Contacted', contactedMatches.length, 'contacted'),
                ],
                indicatorColor: _getIndicatorColor(_tabController.index),
                indicatorWeight: 3,
                labelColor: AppTheme.textPrimary,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                onTap: (index) {
                  setState(() {});
                },
              ),
            ),

            // Divider
            Divider(
              height: 1,
              color: Colors.grey[300],
            ),

            // TabBarView content based on selected tab
            _getCurrentTabContent(
              strongMatches,
              maybeMatches,
              notNowMatches,
              contactedMatches,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentTabContent(
    List<MatchInsight> strongMatches,
    List<MatchInsight> maybeMatches,
    List<MatchInsight> notNowMatches,
    List<MatchInsight> contactedMatches,
  ) {
    List<MatchInsight> matches;
    switch (_tabController.index) {
      case 0:
        matches = strongMatches;
        break;
      case 1:
        matches = maybeMatches;
        break;
      case 2:
        matches = notNowMatches;
        break;
      case 3:
        matches = contactedMatches;
        break;
      default:
        matches = strongMatches;
    }
    return MatchInsightListView(matches: matches);
  }

  Widget _buildTab(String label, int count, String category) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getCategoryColor(category),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'strong':
        return AppTheme.successColor;
      case 'maybe':
        return AppTheme.accentColor;
      case 'not_now':
        return Colors.grey[400]!;
      case 'contacted':
        return AppTheme.primaryColor;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getIndicatorColor(int tabIndex) {
    final categories = ['strong', 'maybe', 'not_now', 'contacted'];
    return _getCategoryColor(categories[tabIndex]);
  }
}
