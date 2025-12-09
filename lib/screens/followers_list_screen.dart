import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/tagged_person.dart';
import '../utils/theme.dart';

class FollowersListScreen extends StatefulWidget {
  const FollowersListScreen({super.key});

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  final Set<String> _followingBack = {
    '2',
    '4',
    '6'
  }; // IDs of users we follow back

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final taggedFollowings = appState.taggedFollowings;
    final mockFollowers = _getMockFollowers();

    // Group by network code
    final groupedFollowings = <String, List<FollowingPerson>>{};
    for (var following in taggedFollowings) {
      final key = following.networkCodeId;
      if (!groupedFollowings.containsKey(key)) {
        groupedFollowings[key] = [];
      }
      groupedFollowings[key]!.add(following);
    }

    final hasTaggedFollowings = taggedFollowings.isNotEmpty;
    final hasMockFollowers = mockFollowers.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Followings',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: (!hasTaggedFollowings && !hasMockFollowers)
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                // Tagged followings grouped by network code
                ...groupedFollowings.entries.map((entry) {
                  final networkCodeLabel =
                      appState.getNetworkCodeLabel(entry.key);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppConstants.spacingSm,
                          bottom: AppConstants.spacingSm,
                        ),
                        child: Text(
                          'From: $networkCodeLabel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      ...entry.value.map((following) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.spacingMd,
                            ),
                            child: _buildTaggedFollowingCard(
                                context, following, appState),
                          )),
                      const SizedBox(height: AppConstants.spacingSm),
                    ],
                  );
                }).toList(),

                // Mock followers (legacy)
                if (hasMockFollowers) ...[
                  if (hasTaggedFollowings)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppConstants.spacingSm,
                        bottom: AppConstants.spacingSm,
                        top: AppConstants.spacingMd,
                      ),
                      child: Text(
                        'Other Followers',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ...mockFollowers.map((follower) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.spacingMd,
                        ),
                        child: _buildFollowerCard(context, follower),
                      )),
                ],
              ],
            ),
    );
  }

  Widget _buildTaggedFollowingCard(
    BuildContext context,
    FollowingPerson following,
    AppState appState,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Center(
                  child: Text(
                    following.label[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      following.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 12,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            appState
                                .getNetworkCodeLabel(following.networkCodeId),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textTertiary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Unfollow button
              TextButton(
                onPressed: () {
                  // Unfollow action
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text(
                  'Unfollow',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Tags
          if (following.userTags.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spacingSm),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: following.userTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowerCard(
      BuildContext context, Map<String, dynamic> follower) {
    final isFollowingBack = _followingBack.contains(follower['id']);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            child: Center(
              child: Text(
                follower['name'][0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  follower['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  follower['role'],
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Follow back button
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  if (isFollowingBack) {
                    _followingBack.remove(follower['id']);
                  } else {
                    _followingBack.add(follower['id']);
                  }
                });
              },
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    isFollowingBack ? Colors.white : AppTheme.primaryColor,
                foregroundColor:
                    isFollowingBack ? AppTheme.textPrimary : Colors.white,
                side: BorderSide(
                  color: isFollowingBack
                      ? Colors.grey[300]!
                      : AppTheme.primaryColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                isFollowingBack ? 'Following' : 'Follow Back',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'No followers yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'People who follow you will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockFollowers() {
    return [
      {
        'id': '1',
        'name': 'Alex Thompson',
        'role': 'Entrepreneur & Angel Investor',
      },
      {
        'id': '2',
        'name': 'Rachel Green',
        'role': 'VP of Sales at SaaS Corp',
      },
      {
        'id': '3',
        'name': 'Chris Martinez',
        'role': 'Full Stack Developer',
      },
      {
        'id': '4',
        'name': 'Sophia Lee',
        'role': 'Growth Marketing Lead',
      },
      {
        'id': '5',
        'name': 'Daniel Brown',
        'role': 'Product Designer at Adobe',
      },
      {
        'id': '6',
        'name': 'Nina Patel',
        'role': 'Healthcare Tech Founder',
      },
      {
        'id': '7',
        'name': 'Oliver Smith',
        'role': 'DevOps Engineer',
      },
    ];
  }
}
