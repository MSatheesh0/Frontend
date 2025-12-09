class Following {
  final String id;
  final String label;
  final String type; // "profile" or "circle"
  final String? role; // e.g. "Investor", "Founder", "Company", "Community"
  final List<String> tags;

  Following({
    required this.id,
    required this.label,
    required this.type,
    this.role,
    required this.tags,
  });

  static List<Following> getMockFollowings() {
    return [
      Following(
        id: 'following_001',
        label: 'BlueStone Capital',
        type: 'profile',
        role: 'Investor',
        tags: ['AI', 'SaaS', 'Pre-Seed'],
      ),
      Following(
        id: 'following_002',
        label: 'AI Founder Circle',
        type: 'circle',
        role: 'Community',
        tags: ['AI', 'Founders'],
      ),
      Following(
        id: 'following_003',
        label: 'Healthcare Network',
        type: 'circle',
        role: 'Community',
        tags: ['Healthcare'],
      ),
      Following(
        id: 'following_004',
        label: 'Arjun Patel',
        type: 'profile',
        role: 'Founder',
        tags: ['AI', 'B2B', 'SaaS'],
      ),
      Following(
        id: 'following_005',
        label: 'Tech Ventures India',
        type: 'profile',
        role: 'Investor',
        tags: ['B2B', 'Enterprise', 'Seed'],
      ),
      Following(
        id: 'following_006',
        label: 'SaaS Founders Meetup',
        type: 'circle',
        role: 'Community',
        tags: ['SaaS', 'Networking'],
      ),
    ];
  }
}

class UserFollowState {
  final List<Following> followings;

  UserFollowState({
    required this.followings,
  });

  int get followingCount => followings.length;

  bool isFollowing(String followingId) {
    return followings.any((f) => f.id == followingId);
  }

  UserFollowState follow(Following following) {
    if (isFollowing(following.id)) {
      return this;
    }
    return UserFollowState(
      followings: [...followings, following],
    );
  }

  UserFollowState unfollow(String followingId) {
    return UserFollowState(
      followings: followings.where((f) => f.id != followingId).toList(),
    );
  }

  static UserFollowState getMockState() {
    final allFollowings = Following.getMockFollowings();
    // Start with first 3 followed
    return UserFollowState(
      followings: allFollowings.take(3).toList(),
    );
  }
}
