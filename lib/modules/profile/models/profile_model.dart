class ProfileHeaderInfo {
  final String name;
  final String handle;
  final String photoUrl;
  final String tagline;

  ProfileHeaderInfo({
    required this.name,
    required this.handle,
    required this.photoUrl,
    required this.tagline,
  });
}

class ProfileSection {
  final String type;
  final String title;
  final String? description;
  final List<dynamic>? items;
  bool isPinned;
  bool isVisible;

  ProfileSection({
    required this.type,
    required this.title,
    this.description,
    this.items,
    this.isPinned = false,
    this.isVisible = true,
  });

  ProfileSection copyWith({
    String? type,
    String? title,
    String? description,
    List<dynamic>? items,
    bool? isPinned,
    bool? isVisible,
  }) {
    return ProfileSection(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
      isPinned: isPinned ?? this.isPinned,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class ProfileScreenModel {
  final ProfileHeaderInfo headerInfo;
  final List<ProfileSection> dynamicSections;

  ProfileScreenModel({
    required this.headerInfo,
    required this.dynamicSections,
  });

  // Mock data generator
  static ProfileScreenModel getMockProfile() {
    return ProfileScreenModel(
      headerInfo: ProfileHeaderInfo(
        name: 'John Davidson',
        handle: '@johnd1290',
        photoUrl: '',
        tagline: 'Building the future of AI-driven networking',
      ),
      dynamicSections: [
        ProfileSection(
          type: 'current_goals',
          title: 'Current Goals',
          items: [
            {
              'title': 'Raise Pre-Seed Round',
              'status': 'Active',
              'progress': 0.65,
            },
            {
              'title': 'Build MVP',
              'status': 'In Progress',
              'progress': 0.40,
            },
          ],
        ),
        ProfileSection(
          type: 'ai_summary',
          title: 'AI Summary',
          description:
              'John is a serial entrepreneur with expertise in AI and SaaS. Currently focused on building innovative networking solutions. Active in the startup ecosystem and passionate about connecting founders with investors.',
        ),
        ProfileSection(
          type: 'interests',
          title: 'Interests',
          items: [
            'Artificial Intelligence',
            'SaaS',
            'Fundraising',
            'Startup Growth',
            'Product Design',
            'Healthcare Technology',
          ],
        ),
        ProfileSection(
          type: 'circles',
          title: 'Circles & Communities',
          items: [
            {'name': 'AI Founders Circle', 'members': 245},
            {'name': 'Healthcare Innovation', 'members': 180},
            {'name': 'Fintech Builders', 'members': 320},
          ],
        ),
        ProfileSection(
          type: 'projects',
          title: 'Highlighted Projects',
          items: [
            {
              'name': 'ConnectApp',
              'description': 'AI-powered networking platform',
              'status': 'Active',
            },
            {
              'name': 'HealthTech Dashboard',
              'description': 'Patient management system',
              'status': 'Completed',
            },
          ],
        ),
        ProfileSection(
          type: 'recent_tasks',
          title: 'Recent Assistant Tasks',
          items: [
            'Matched with 3 new investors',
            'Scheduled 2 intro calls',
            'Researched 5 potential partners',
          ],
          isVisible: true,
        ),
        ProfileSection(
          type: 'social_links',
          title: 'Social Links',
          items: [
            {'platform': 'LinkedIn', 'url': 'linkedin.com/in/johnd'},
            {'platform': 'Twitter', 'url': 'twitter.com/johnd'},
            {'platform': 'GitHub', 'url': 'github.com/johnd'},
          ],
        ),
      ],
    );
  }
}
