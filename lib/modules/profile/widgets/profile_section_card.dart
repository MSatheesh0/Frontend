import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../utils/theme.dart';

class ProfileSectionCard extends StatelessWidget {
  final ProfileSection section;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onTogglePin;

  const ProfileSectionCard({
    super.key,
    required this.section,
    this.onToggleVisibility,
    this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    if (!section.isVisible) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(
        left: AppConstants.spacingMd,
        right: AppConstants.spacingMd,
        bottom: AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: section.isPinned
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader(context),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: _buildSectionContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: section.isPinned
            ? AppTheme.primaryColor.withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusMd),
          topRight: Radius.circular(AppConstants.radiusMd),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              section.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (section.type == 'recent_tasks')
            IconButton(
              icon: Icon(
                section.isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppTheme.textSecondary,
              ),
              onPressed: onToggleVisibility,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: AppConstants.spacingXs),
          IconButton(
            icon: Icon(
              section.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: 18,
              color: section.isPinned
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
            onPressed: onTogglePin,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context) {
    switch (section.type) {
      case 'current_goals':
        return _buildGoalsContent();
      case 'ai_summary':
        return _buildSummaryContent();
      case 'interests':
        return _buildInterestsContent();
      case 'circles':
        return _buildCirclesContent();
      case 'projects':
        return _buildProjectsContent();
      case 'recent_tasks':
        return _buildTasksContent();
      case 'social_links':
        return _buildSocialLinksContent();
      default:
        return _buildDefaultContent();
    }
  }

  Widget _buildGoalsContent() {
    return Column(
      children: section.items?.map<Widget>((goal) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingXs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          goal['status'],
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    child: LinearProgressIndicator(
                      value: goal['progress'],
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildSummaryContent() {
    return Text(
      section.description ?? '',
      style: TextStyle(
        fontSize: 14,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildInterestsContent() {
    return Wrap(
      spacing: AppConstants.spacingSm,
      runSpacing: AppConstants.spacingSm,
      children: section.items?.map<Widget>((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingSm,
                vertical: AppConstants.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                border: Border.all(
                  color: AppTheme.secondaryColor.withOpacity(0.3),
                ),
              ),
              child: Text(
                interest,
                style: const TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildCirclesContent() {
    return Column(
      children: section.items?.map<Widget>((circle) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                    ),
                    child: Icon(
                      Icons.group_outlined,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${circle['members']} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildProjectsContent() {
    return Column(
      children: section.items?.map<Widget>((project) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          project['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingXs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: project['status'] == 'Active'
                              ? AppTheme.successColor.withOpacity(0.1)
                              : Colors.grey[200],
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          project['status'],
                          style: TextStyle(
                            fontSize: 11,
                            color: project['status'] == 'Active'
                                ? AppTheme.successColor
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    project['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildTasksContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: section.items?.map<Widget>((task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Text(
                      task,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildSocialLinksContent() {
    return Column(
      children: section.items?.map<Widget>((link) {
            IconData icon;
            switch (link['platform']) {
              case 'LinkedIn':
                icon = Icons.work_outline;
                break;
              case 'Twitter':
                icon = Icons.chat_bubble_outline;
                break;
              case 'GitHub':
                icon = Icons.code;
                break;
              default:
                icon = Icons.link;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
              padding: const EdgeInsets.all(AppConstants.spacingSm),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: AppConstants.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link['platform'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          link['url'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textTertiary,
                  ),
                ],
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildDefaultContent() {
    if (section.description != null) {
      return Text(
        section.description!,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
          height: 1.5,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
