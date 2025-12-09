// Example usage of Task Execution Service with My Spaces
//
// This demonstrates how the assistant uses Network Codes first,
// then Circles, to find matches for user tasks.

import '../services/task_execution_service.dart';
import '../models/goal.dart';

void exampleTaskExecution() async {
  final taskService = TaskExecutionService();

  // Example 1: User creates a task to find investors
  final investorTask = Goal(
    id: 'task_1',
    title: 'Find investors for pre-seed round',
    description:
        'Looking for angel investors or early-stage VCs interested in AI/SaaS',
    tags: ['investor', 'funding', 'pre-seed'],
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(days: 30)),
    status: GoalStatus.active,
    progress: 0,
  );

  print('=== Finding matches for: ${investorTask.title} ===\n');

  // Execute task - searches Network Codes first, then Circles
  final matches = await taskService.findMatchesInMySpaces(investorTask);

  print('Found ${matches.length} matches:\n');

  for (final match in matches) {
    print('${match.name}');
    print('  Score: ${match.matchScore}%');
    print(
        '  Source: ${match.source == "network_code" ? "Network Code (curated)" : "Circle"}');
    print('  Reason: ${match.matchReason}');
    print('');
  }

  // Example 2: User creates a task to find AI co-founders
  final cofounderTask = Goal(
    id: 'task_2',
    title: 'Find technical co-founder',
    description: 'Looking for AI/ML engineer to join as co-founder',
    tags: ['cofounder', 'ai', 'technical'],
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(days: 60)),
    status: GoalStatus.active,
    progress: 0,
  );

  print('=== Finding matches for: ${cofounderTask.title} ===\n');

  final cofounderMatches =
      await taskService.findMatchesInMySpaces(cofounderTask);

  print('Found ${cofounderMatches.length} matches:\n');

  for (final match in cofounderMatches) {
    print('${match.name}');
    print('  Score: ${match.matchScore}%');
    print(
        '  Source: ${match.source == "network_code" ? "Network Code (curated)" : "Circle"}');
    print('  Reason: ${match.matchReason}');
    print('');
  }
}

/*
Expected Output:

=== Finding matches for: Find investors for pre-seed round ===

Found 4 matches:

Sarah Chen
  Score: 95%
  Source: Network Code (curated)
  Reason: Angel investor in your "My Investors" group

Michael Roberts
  Score: 88%
  Source: Network Code (curated)
  Reason: Early-stage VC in your curated network

Emma Davis
  Score: 85%
  Source: Circle
  Reason: SaaS expert in Growth Circle

Jennifer Wu
  Score: 82%
  Source: Circle
  Reason: Investor attending TechCrunch Disrupt 2025

Alex Thompson
  Score: 78%
  Source: Circle
  Reason: VC partner in TechCrunch Disrupt circle

=== Priority Order Explanation ===

1. Network Code matches appear first (higher trust, curated by user)
   - Sarah Chen (95%) from "My Investors"
   - Michael Roberts (88%) from "My Investors"

2. Circle matches appear next (broader reach, event/context-based)
   - Jennifer Wu (82%) from TechCrunch Disrupt event
   - Alex Thompson (78%) from TechCrunch Disrupt event
   - Emma Davis (85%) from SaaS Growth Circle

3. All results are merged and sorted by match score
   - Duplicates removed (if same person in multiple spaces)
   - Highest scores first

4. If low match quality or count:
   - Assistant can suggest expanding search to public circles
   - User maintains control over search scope
*/
