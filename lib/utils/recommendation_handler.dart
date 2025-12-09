import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../screens/assistant_chat_screen.dart';
import '../screens/assistant_conversation_screen.dart';

/// Handles navigation and actions for recommendations
void handleRecommendationTap(BuildContext context, Recommendation rec) {
  switch (rec.type) {
    case RecommendationType.matchNda:
      // Navigate to assistant conversation related to the match
      if (rec.matchId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AssistantConversationScreen(
              matchId: rec.matchId!,
              matchLabel: 'Match #${rec.matchId!.split('_').last}',
            ),
          ),
        );
      } else {
        // Fallback: open chat with context
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AssistantChatScreen(
              initialPrompt: 'Show me matches that require NDA approval.',
            ),
          ),
        );
      }
      break;

    case RecommendationType.eventSuggestion:
      // Open AssistantChatScreen with a pre-filled prompt to plan the event
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssistantChatScreen(
            initialPrompt:
                'Help me plan my visit to the ${rec.title}. How do I get the most out of it?',
          ),
        ),
      );
      break;

    case RecommendationType.missingPitchInfo:
      // Navigate to Profile/Pitch edit screen or open assistant chat
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AssistantChatScreen(
            initialPrompt:
                'Help me improve my pitch deck by adding the missing traction metrics that investors are asking for.',
          ),
        ),
      );
      break;

    case RecommendationType.missingBusinessInfo:
      // Show dialog to collect missing info or open assistant chat
      _showBusinessInfoDialog(context, rec);
      break;

    case RecommendationType.missedOpportunities:
      // Open AssistantChatScreen with guidance
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AssistantChatScreen(
            initialPrompt:
                'Explain how I can start the process to get ISO certification and what steps I should take first.',
          ),
        ),
      );
      break;

    case RecommendationType.profileImprovement:
      // Open AssistantChatScreen for profile improvement
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AssistantChatScreen(
            initialPrompt:
                'Rewrite my headline and profile summary to better match my current goals and attract the right connections.',
          ),
        ),
      );
      break;

    case RecommendationType.generalAdvice:
      // Default: open AssistantChatScreen with recommendation title
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssistantChatScreen(
            initialPrompt: rec.title,
          ),
        ),
      );
      break;
  }
}

void _showBusinessInfoDialog(BuildContext context, Recommendation rec) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Provide Information'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Your response',
              hintText: 'e.g., \$250K in last 6 months',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Save the response
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Information saved. Assistant will follow up.'),
              ),
            );
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}
