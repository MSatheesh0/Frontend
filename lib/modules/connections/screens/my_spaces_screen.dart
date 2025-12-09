import 'package:flutter/material.dart';
import '../models/my_spaces.dart';
import '../utils/theme.dart';

class MySpacesScreen extends StatefulWidget {
  const MySpacesScreen({super.key});

  @override
  State<MySpacesScreen> createState() => _MySpacesScreenState();
}

class _MySpacesScreenState extends State<MySpacesScreen> {
  List<NetworkCodeGroup> _networkCodeGroups = [];
  List<Circle> _circles = [];

  @override
  void initState() {
    super.initState();
    _loadMySpaces();
  }

  void _loadMySpaces() {
    // TODO: Replace with real data from providers/services
    setState(() {
      _networkCodeGroups = [
        NetworkCodeGroup(
          id: 'nc_1',
          name: 'TN Summit Network Code',
          code: 'TNSMT2025',
          memberCount: 47,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          description: 'Connections from StartupTN Summit',
        ),
        NetworkCodeGroup(
          id: 'nc_2',
          name: 'My Investors',
          code: 'INVSTR',
          memberCount: 12,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          description: 'Curated list of potential investors',
        ),
        NetworkCodeGroup(
          id: 'nc_3',
          name: 'AI Founders Group',
          code: 'AIFND',
          memberCount: 23,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          description: 'Fellow AI startup founders',
        ),
      ];

      _circles = [
        Circle(
          id: 'circle_event_1',
          name: 'TechCrunch Disrupt 2025',
          type: CircleType.event,
          memberCount: 234,
          joinedAt: DateTime.now().subtract(const Duration(days: 5)),
          description: 'Startup event circle',
          tags: ['Tech', 'Startups', 'Investors'],
        ),
        Circle(
          id: 'circle_event_2',
          name: 'AI Founders Meetup',
          type: CircleType.event,
          memberCount: 89,
          joinedAt: DateTime.now().subtract(const Duration(days: 2)),
          description: 'AI-focused networking',
          tags: ['AI', 'Machine Learning'],
        ),
        Circle(
          id: 'circle_interest_1',
          name: 'SaaS Growth Circle',
          type: CircleType.interest,
          memberCount: 156,
          joinedAt: DateTime.now().subtract(const Duration(days: 45)),
          description: 'SaaS founders sharing growth tactics',
          tags: ['SaaS', 'Growth', 'B2B'],
        ),
        Circle(
          id: 'circle_industry_1',
          name: 'HealthTech Innovators',
          type: CircleType.industry,
          memberCount: 67,
          joinedAt: DateTime.now().subtract(const Duration(days: 20)),
          description: 'Healthcare technology professionals',
          tags: ['HealthTech', 'Medical'],
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Spaces',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              'Where your assistant works',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        children: [
          // Network Groups Section
          _buildSectionHeader(
            icon: Icons.people_outline,
            title: 'Network Groups',
            subtitle: 'Your curated connections',
            count: _networkCodeGroups.length,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ..._networkCodeGroups.map((group) => _buildNetworkCodeCard(group)),

          const SizedBox(height: AppConstants.spacingXl),

          // Circles Section
          _buildSectionHeader(
            icon: Icons.bubble_chart_outlined,
            title: 'Circles',
            subtitle: 'Events & interest groups',
            count: _circles.length,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ..._circles.map((circle) => _buildCircleCard(circle)),

          const SizedBox(height: AppConstants.spacingXl),

          // Info card
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkCodeCard(NetworkCodeGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Center(
              child: Text(
                group.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Code: ${group.code}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.people,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberCount} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCard(Circle circle) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCircleColor(circle.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(
              _getCircleIcon(circle.type),
              size: 24,
              color: _getCircleColor(circle.type),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  circle.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCircleColor(circle.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        circle.type.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getCircleColor(circle.type),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.people,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${circle.memberCount} members',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (circle.tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: circle.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              'Your assistant searches Network Groups first (higher trust), then expands to Circles for broader matches.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCircleIcon(CircleType type) {
    switch (type) {
      case CircleType.event:
        return Icons.event;
      case CircleType.interest:
        return Icons.favorite_outline;
      case CircleType.industry:
        return Icons.business_outlined;
      case CircleType.location:
        return Icons.location_on_outlined;
    }
  }

  Color _getCircleColor(CircleType type) {
    switch (type) {
      case CircleType.event:
        return const Color(0xFF8B5CF6); // Purple
      case CircleType.interest:
        return const Color(0xFFEC4899); // Pink
      case CircleType.industry:
        return const Color(0xFF3B82F6); // Blue
      case CircleType.location:
        return const Color(0xFF10B981); // Green
    }
  }
}
