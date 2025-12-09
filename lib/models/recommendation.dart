enum RecommendationType {
  matchNda, // e.g. "Assistant found a match that requires NDA — approve to continue."
  missingPitchInfo, // e.g. "Pitch deck seems to be missing traction metrics."
  missingBusinessInfo, // e.g. "Investor asked for your last 6 months turnover."
  missedOpportunities, // e.g. "You missed 35 opps due to missing ISO."
  eventSuggestion, // e.g. "AI in Manufacturing event next week — plan your visit."
  profileImprovement, // e.g. "Improve your LinkedIn/profile headline."
  generalAdvice, // generic assistant suggestion
}

class Recommendation {
  final String id;
  final RecommendationType type;
  final String title; // short primary text
  final String? subtitle; // optional secondary explanation
  final String? goalId; // optional link to a specific goal
  final String?
      matchId; // optional link to a specific assistant conversation/match
  final String? payload; // optional JSON/string for additional context

  Recommendation({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.goalId,
    this.matchId,
    this.payload,
  });

  // Mock recommendations for dashboard
  static List<Recommendation> getMockRecommendations() {
    return [
      Recommendation(
        id: '1',
        type: RecommendationType.matchNda,
        title: 'Assistant found a promising match that requires NDA approval',
        subtitle: 'Approve to let your assistant continue the conversation.',
        matchId: 'match_001',
      ),
      Recommendation(
        id: '2',
        type: RecommendationType.missedOpportunities,
        title: 'You missed 35 opportunities due to missing ISO certification',
        subtitle: 'Fix this to unlock larger enterprise / government deals.',
      ),
      Recommendation(
        id: '3',
        type: RecommendationType.missingPitchInfo,
        title: 'Your pitch deck is missing traction metrics',
        subtitle: 'Investors asked about revenue and active users.',
        goalId: 'goal_123',
      ),
      Recommendation(
        id: '4',
        type: RecommendationType.eventSuggestion,
        title: 'AI in Manufacturing event next week',
        subtitle: 'Attending can improve your visibility in target sector.',
        payload:
            '{"eventName": "AI in Manufacturing Summit", "date": "2025-11-27", "location": "San Francisco"}',
      ),
      Recommendation(
        id: '5',
        type: RecommendationType.missingBusinessInfo,
        title: 'Investor asked for your last 6 months turnover',
        subtitle: 'Provide this info to move forward with the conversation.',
        matchId: 'match_045',
      ),
    ];
  }
}
