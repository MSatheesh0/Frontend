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
    return [];
  }
}
