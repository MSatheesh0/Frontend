import '../models/my_spaces.dart';
import '../models/goal.dart';

// Placeholder model for matches
class Match {
  final String id;
  final String name;
  final String source; // 'network_code' or 'circle'
  final String sourceId;
  final int matchScore; // 0-100
  final String matchReason;

  Match({
    required this.id,
    required this.name,
    required this.source,
    required this.sourceId,
    required this.matchScore,
    required this.matchReason,
  });
}

/// Task execution service that searches My Spaces for matches
///
/// Search priority:
/// 1. Network Code Groups (user-curated, higher trust)
/// 2. Circles (event/context-based, broader reach)
/// 3. (Future) Public circles with user confirmation
class TaskExecutionService {
  /// Find matches for a task across all of user's spaces
  ///
  /// Priority:
  /// - Network Codes first (curated, high-trust)
  /// - Then Circles (broader context)
  /// - Merge and rank by relevance
  Future<List<Match>> findMatchesInMySpaces(Goal task) async {
    final matches = <Match>[];

    // Step 1: Search Network Code Groups first
    final networkCodeMatches = await _findMatchesInNetworkCodes(task);
    matches.addAll(networkCodeMatches);

    // Step 2: Search Circles next
    final circleMatches = await _findMatchesInCircles(task);
    matches.addAll(circleMatches);

    // Step 3: Merge, deduplicate, and rank by match score
    final rankedMatches = _rankAndDeduplicateMatches(matches);

    // Step 4: Check if we have enough quality matches
    if (rankedMatches.length < 5 || rankedMatches.first.matchScore < 70) {
      // TODO: Ask user if they want to expand search to wider public circles
      // For MVP, just log or return what we have
      print('Low match quality or count. Consider expanding search.');
    }

    return rankedMatches;
  }

  /// Search user's Network Code Groups
  /// These are curated groups, so matches here are higher trust
  Future<List<Match>> _findMatchesInNetworkCodes(Goal task) async {
    // TODO: Implement actual search logic
    // For now, return mock matches

    await Future.delayed(
        const Duration(milliseconds: 300)); // Simulate API call

    // Mock: Analyze task tags/description and match against Network Code members
    final matches = <Match>[];

    // Example: If task mentions "investors", search Network Codes for investor profiles
    if (_taskMentionsKeyword(task, ['investor', 'funding', 'capital'])) {
      matches.add(Match(
        id: 'match_nc_1',
        name: 'Sarah Chen',
        source: 'network_code',
        sourceId: 'nc_2', // "My Investors" group
        matchScore: 95,
        matchReason: 'Angel investor in your "My Investors" group',
      ));
      matches.add(Match(
        id: 'match_nc_2',
        name: 'Michael Roberts',
        source: 'network_code',
        sourceId: 'nc_2',
        matchScore: 88,
        matchReason: 'Early-stage VC in your curated network',
      ));
    }

    // Example: If task mentions "AI", search relevant groups
    if (_taskMentionsKeyword(
        task, ['ai', 'artificial intelligence', 'machine learning'])) {
      matches.add(Match(
        id: 'match_nc_3',
        name: 'David Kim',
        source: 'network_code',
        sourceId: 'nc_3', // "AI Founders Group"
        matchScore: 92,
        matchReason: 'AI founder in your "AI Founders Group"',
      ));
    }

    return matches;
  }

  /// Search user's Circles (events, interests, etc.)
  /// Broader reach than Network Codes
  Future<List<Match>> _findMatchesInCircles(Goal task) async {
    // TODO: Implement actual search logic
    // For now, return mock matches

    await Future.delayed(
        const Duration(milliseconds: 400)); // Simulate API call

    final matches = <Match>[];

    // Example: Search event circles
    if (_taskMentionsKeyword(task, ['investor', 'funding'])) {
      matches.add(Match(
        id: 'match_circle_1',
        name: 'Jennifer Wu',
        source: 'circle',
        sourceId: 'circle_event_1', // TechCrunch Disrupt
        matchScore: 82,
        matchReason: 'Investor attending TechCrunch Disrupt 2025',
      ));
      matches.add(Match(
        id: 'match_circle_2',
        name: 'Alex Thompson',
        source: 'circle',
        sourceId: 'circle_event_1',
        matchScore: 78,
        matchReason: 'VC partner in TechCrunch Disrupt circle',
      ));
    }

    // Example: Search interest circles
    if (_taskMentionsKeyword(task, ['saas', 'growth', 'b2b'])) {
      matches.add(Match(
        id: 'match_circle_3',
        name: 'Emma Davis',
        source: 'circle',
        sourceId: 'circle_interest_1', // SaaS Growth Circle
        matchScore: 85,
        matchReason: 'SaaS expert in Growth Circle',
      ));
    }

    return matches;
  }

  /// Merge matches, remove duplicates, and sort by score
  List<Match> _rankAndDeduplicateMatches(List<Match> matches) {
    // Remove duplicates by ID (in case same person appears in multiple spaces)
    final uniqueMatches = <String, Match>{};
    for (final match in matches) {
      if (!uniqueMatches.containsKey(match.id) ||
          uniqueMatches[match.id]!.matchScore < match.matchScore) {
        uniqueMatches[match.id] = match;
      }
    }

    // Sort by match score (highest first)
    final ranked = uniqueMatches.values.toList();
    ranked.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return ranked;
  }

  /// Helper: Check if task mentions any of the given keywords
  bool _taskMentionsKeyword(Goal task, List<String> keywords) {
    final searchText = '${task.title} ${task.description}'.toLowerCase();
    return keywords
        .any((keyword) => searchText.contains(keyword.toLowerCase()));
  }

  /// Get all user's Network Code Groups
  /// TODO: Connect to real data provider
  Future<List<NetworkCodeGroup>> getUserNetworkCodes() async {
    // Mock data for now
    return [
      NetworkCodeGroup(
        id: 'nc_1',
        name: 'TN Summit Network Code',
        code: 'TNSMT2025',
        memberCount: 47,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      NetworkCodeGroup(
        id: 'nc_2',
        name: 'My Investors',
        code: 'INVSTR',
        memberCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  /// Get all user's joined Circles
  /// TODO: Connect to real data provider
  Future<List<Circle>> getUserCircles() async {
    // Mock data for now
    return [
      Circle(
        id: 'circle_event_1',
        name: 'TechCrunch Disrupt 2025',
        type: CircleType.event,
        memberCount: 234,
        joinedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Circle(
        id: 'circle_interest_1',
        name: 'SaaS Growth Circle',
        type: CircleType.interest,
        memberCount: 156,
        joinedAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }
}
