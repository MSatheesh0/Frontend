import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../services/app_state.dart';
import '../screens/following_list_screen.dart';
import '../screens/followers_list_screen.dart';
import '../screens/connections_list_screen.dart';
import '../utils/theme.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileHeaderInfo headerInfo;

  const ProfileHeader({super.key, required this.headerInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                headerInfo.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Name
          Text(
            headerInfo.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.spacingXs),

          // Handle
          Text(
            headerInfo.handle,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Tagline
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    headerInfo.tagline,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingXs),
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Connection Stats
          _buildConnectionStats(context),
        ],
      ),
    );
  }

  Widget _buildConnectionStats(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final followingCount = appState.followState.followingCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ConnectionsListScreen(),
              ),
            );
          },
          child: _buildStat(
            context,
            '1,234',
            'Connections',
            isClickable: true,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FollowersListScreen(),
              ),
            );
          },
          child: _buildStat(
            context,
            '567',
            'Followers',
            isClickable: true,
          ),
        ),
        const SizedBox(width: AppConstants.spacingMd),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FollowingListScreen(),
              ),
            );
          },
          child: _buildStat(
            context,
            followingCount.toString(),
            'Following',
            isClickable: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(
    BuildContext context,
    String value,
    String label, {
    bool isClickable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: isClickable
            ? AppTheme.primaryColor.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
