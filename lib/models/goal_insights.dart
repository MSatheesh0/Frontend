class ChatMessage {
  final String sender; // "assistant" or "other"
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

class ConversationSummary {
  final String matchId;
  final String title;
  final String outcome;
  final List<String> keyPoints;
  final List<ChatMessage> messages;

  ConversationSummary({
    required this.matchId,
    required this.title,
    required this.outcome,
    required this.keyPoints,
    required this.messages,
  });

  static ConversationSummary getMockConversation(String matchId) {
    return ConversationSummary(
      matchId: matchId,
      title: 'Discussion about funding fit and ticket size',
      outcome: 'Recommended to contact',
      keyPoints: [
        'Investor is actively looking for early-stage AI SaaS companies',
        'Preferred ticket size: \$500K - \$2M',
        'Requested demo and more details on traction',
        'Interested in US and EU markets',
      ],
      messages: [
        ChatMessage(
          sender: 'other',
          text:
              'Hi! Thanks for reaching out. What type of companies are you working with?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ChatMessage(
          sender: 'assistant',
          text:
              'We\'re connecting founders with investors interested in early-stage AI SaaS. This founder is building a networking platform.',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        ),
        ChatMessage(
          sender: 'other',
          text:
              'Interesting! That\'s in our sweet spot. What\'s their current revenue?',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        ),
        ChatMessage(
          sender: 'assistant',
          text:
              'Currently in MVP phase with beta users. They\'re looking to raise \$750K for product development and go-to-market.',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
        ChatMessage(
          sender: 'other',
          text:
              'That aligns well with our focus. Happy to take a intro call. Can you share more details?',
          timestamp:
              DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
        ),
      ],
    );
  }
}

class MatchInsight {
  final String id;
  final String label; // e.g. "Investor Agent #12"
  final String category; // "strong", "maybe", "not_now"
  final String summary;
  final String status; // e.g. "Recommended to contact"
  final String confidence; // percentage or label
  final bool isFromFollowing;

  MatchInsight({
    required this.id,
    required this.label,
    required this.category,
    required this.summary,
    required this.status,
    required this.confidence,
    this.isFromFollowing = false,
  });

  static List<MatchInsight> getMockMatches() {
    return [
      // Strong matches
      MatchInsight(
        id: 'match_001',
        label: 'Investor Agent #12',
        category: 'strong',
        summary:
            'Interested in early-stage AI SaaS; requested more info on revenue.',
        status: 'Recommended to contact',
        confidence: '95%',
        isFromFollowing: true,
      ),
      MatchInsight(
        id: 'match_002',
        label: 'Investor Agent #45',
        category: 'strong',
        summary: 'Focus on B2B SaaS with 2-5M ARR; wants demo this week.',
        status: 'Action needed',
        confidence: '92%',
        isFromFollowing: true,
      ),
      MatchInsight(
        id: 'match_003',
        label: 'Investor Agent #78',
        category: 'strong',
        summary:
            'Portfolio company in networking space; interested in cross-synergies.',
        status: 'Recommended to contact',
        confidence: '88%',
      ),
      MatchInsight(
        id: 'match_004',
        label: 'Investor Agent #23',
        category: 'strong',
        summary:
            'Sector investor in enterprise tools; liked your product demo.',
        status: 'Recommended to contact',
        confidence: '85%',
      ),
      MatchInsight(
        id: 'match_013',
        label: 'Investor Agent #101',
        category: 'strong',
        summary: 'Looking for AI-driven platforms; wants to schedule a call.',
        status: 'Action needed',
        confidence: '90%',
      ),
      MatchInsight(
        id: 'match_014',
        label: 'Investor Agent #87',
        category: 'strong',
        summary:
            'Specializes in seed-stage SaaS; interested in team background.',
        status: 'Recommended to contact',
        confidence: '87%',
        isFromFollowing: true,
      ),
      MatchInsight(
        id: 'match_015',
        label: 'Investor Agent #65',
        category: 'strong',
        summary: 'Portfolio includes similar companies; seeing strong synergy.',
        status: 'Recommended to contact',
        confidence: '86%',
      ),
      MatchInsight(
        id: 'match_016',
        label: 'Investor Agent #52',
        category: 'strong',
        summary: 'Excited about the market opportunity; requested pitch deck.',
        status: 'Action needed',
        confidence: '84%',
      ),
      MatchInsight(
        id: 'match_017',
        label: 'Investor Agent #39',
        category: 'strong',
        summary: 'Active in networking space; wants intro to founders.',
        status: 'Recommended to contact',
        confidence: '83%',
      ),
      MatchInsight(
        id: 'match_018',
        label: 'Investor Agent #71',
        category: 'strong',
        summary: 'Thesis matches product; inquiring about traction metrics.',
        status: 'Needs more info',
        confidence: '82%',
      ),

      // Maybe matches
      MatchInsight(
        id: 'match_005',
        label: 'Investor Agent #34',
        category: 'maybe',
        summary:
            'Interested but needs clearer market fit; waiting for additional metrics.',
        status: 'Needs more info',
        confidence: '62%',
      ),
      MatchInsight(
        id: 'match_006',
        label: 'Investor Agent #56',
        category: 'maybe',
        summary: 'Possible fit; prefers companies with existing revenue.',
        status: 'Follow up later',
        confidence: '58%',
      ),
      MatchInsight(
        id: 'match_007',
        label: 'Investor Agent #89',
        category: 'maybe',
        summary: 'Geographic preference mismatch but interested in category.',
        status: 'Keep warm',
        confidence: '55%',
      ),

      // Not now
      MatchInsight(
        id: 'match_008',
        label: 'Investor Agent #67',
        category: 'not_now',
        summary: 'Only invests in Series B+; not a fit for current stage.',
        status: 'Not now',
        confidence: 'Low',
      ),
      MatchInsight(
        id: 'match_009',
        label: 'Investor Agent #91',
        category: 'not_now',
        summary:
            'Focus is on biotech and healthcare; outside investment scope.',
        status: 'Not a fit',
        confidence: 'Low',
      ),

      // Contacted
      MatchInsight(
        id: 'match_010',
        label: 'Investor Agent #45',
        category: 'contacted',
        summary: 'Already had intro call; waiting for feedback.',
        status: 'In progress',
        confidence: 'Pending',
      ),
      MatchInsight(
        id: 'match_011',
        label: 'Investor Agent #78',
        category: 'contacted',
        summary: 'Showed interest; sent detailed deck and references.',
        status: 'Awaiting response',
        confidence: 'Pending',
      ),
      MatchInsight(
        id: 'match_012',
        label: 'Investor Agent #33',
        category: 'contacted',
        summary: 'Scheduled follow-up call for next week.',
        status: 'In progress',
        confidence: 'Pending',
      ),
    ];
  }
}

class GoalInsights {
  final String goalId;
  final String goalTitle;
  final int totalAgents;
  final int strongMatches;
  final int maybeMatches;
  final int notNowMatches;
  final int followingsEngaged;
  final List<String> keyFeedback;
  final List<MatchInsight> matches;

  GoalInsights({
    required this.goalId,
    required this.goalTitle,
    required this.totalAgents,
    required this.strongMatches,
    required this.maybeMatches,
    required this.notNowMatches,
    this.followingsEngaged = 0,
    required this.keyFeedback,
    required this.matches,
  });

  static GoalInsights getMockInsights(String goalId, String goalTitle) {
    return GoalInsights(
      goalId: goalId,
      goalTitle: goalTitle,
      totalAgents: 48,
      strongMatches: 10,
      maybeMatches: 12,
      notNowMatches: 29,
      followingsEngaged: 3,
      keyFeedback: [
        'Need clearer traction details',
        'Prefer B2B SaaS with paying customers',
        'Interested in GCC market expansion',
        'Demo video would be helpful',
        'Timeline for MVP launch?',
      ],
      matches: MatchInsight.getMockMatches(),
    );
  }

  int get conversationsInProgress => strongMatches + (maybeMatches ~/ 2);
  int get positiveInterest => strongMatches;
  int get declined => notNowMatches;
}
