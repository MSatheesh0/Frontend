import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/theme.dart';
import '../services/networking_service.dart';

class EventAssistantScreen extends StatefulWidget {
  final Event event;

  const EventAssistantScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventAssistantScreen> createState() => _EventAssistantScreenState();
}

class _EventAssistantScreenState extends State<EventAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final NetworkingService _networkingService = NetworkingService();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleFAQTap(String question) {
    _sendMessage(question);
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: true,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _textController.clear();

    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      // Call real backend API
      final conversationHistory = _messages.map((msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
        'timestamp': msg.timestamp.toIso8601String(),
      }).toList();

      final response = await _networkingService.askEventAssistant(
        eventId: widget.event.id,
        question: text,
        conversationHistory: conversationHistory,
      );

      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: false,
        text: response['answer'] ?? 'Sorry, I couldn\'t process that question.',
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(assistantMessage);
        _isLoading = false;
      });

      // Auto-scroll to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('❌ Event Assistant error: $e');
      
      // Fallback to static response on error
      final assistantReply = getEventAssistantReply(text, widget.event);
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: false,
        text: assistantReply,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(assistantMessage);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Assistant',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Text(
              'Ask anything about this event',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // FAQ Chips
          if (_messages.isEmpty) _buildFAQChips(),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildChatBubble(message);
                    },
                  ),
          ),

          // Input box
          _buildInputBox(),
        ],
      ),
    );
  }

  Widget _buildFAQChips() {
    final faqQuestions = [
      "What can I expect at this event?",
      "How do I get maximum value from this event?",
      "Is this event relevant to my goal?",
      "Who typically attends?",
      "What is the stall pricing?",
      "Should I join this event circle?",
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggested questions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: faqQuestions.map((question) {
              return ActionChip(
                label: Text(question),
                onPressed: () => _handleFAQTap(question),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
              );
            }).toList(),
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
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Start a conversation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Tap a suggested question or type your own',
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

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppConstants.radiusMd),
                  topRight: const Radius.circular(AppConstants.radiusMd),
                  bottomLeft: Radius.circular(
                    message.isUser ? AppConstants.radiusMd : 4,
                  ),
                  bottomRight: Radius.circular(
                    message.isUser ? 4 : AppConstants.radiusMd,
                  ),
                ),
                border: message.isUser
                    ? null
                    : Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: message.isUser ? Colors.white : AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppConstants.spacingMd,
        right: AppConstants.spacingMd,
        top: AppConstants.spacingMd,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppConstants.spacingMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask about this event...',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}

// Chat message model
class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
  });
}

// Assistant reply logic (MVP - static responses)
String getEventAssistantReply(String question, Event event) {
  final q = question.toLowerCase();

  if (q.contains('expect') || q.contains('what can i')) {
    return '''At ${event.name}, you can expect:

• ${event.description}
• Networking opportunities with like-minded professionals
• Expert talks and panel discussions
• Interactive workshops and demos
• Meet potential collaborators and investors

The event runs on ${_formatDate(event.dateTime)} at ${event.location}.''';
  }

  if (q.contains('maximum value') || q.contains('get the most')) {
    return '''To get maximum value from ${event.name}:

1. **Prepare beforehand**: Review the attendee list and identify key people to meet
2. **Set clear goals**: Know what you want to achieve (funding, partnerships, learning)
3. **Engage actively**: Ask questions, participate in discussions
4. **Follow up**: Connect with people you meet within 24-48 hours
5. **Use your assistant**: Create a goal for this event to help match you with relevant attendees

Pro tip: Join the event circle to let your assistant work in this context!''';
  }

  if (q.contains('relevant') || q.contains('my goal')) {
    if (event.matchReason != null) {
      return '''Yes! This event is highly relevant to your goal. Here's why:

✨ ${event.matchReason}

Match score: ${event.matchPercentage}%

${event.matchPercentage! >= 85 ? 'This is one of our top recommendations for you. ' : ''}Your assistant identified ${event.name} based on your active goals and network.

I recommend joining the event circle so your assistant can:
• Find relevant attendees
• Suggest people to connect with
• Help you prepare talking points''';
    } else {
      return '''${event.name} could be relevant depending on your active goals.

The event focuses on: ${event.description}

To get a personalized relevance score, make sure you have an active goal set. Your assistant will then analyze the event and show you specific match reasons.''';
    }
  }

  if (q.contains('who attends') ||
      q.contains('attendees') ||
      q.contains('typically attends')) {
    return '''${event.name} typically attracts:

• Startup founders and entrepreneurs
• Angel investors and VCs
• Tech professionals and engineers
• Business development leaders
• Marketing and growth experts

Based on your network, approximately 5-15 people from your circles have attended similar events.

Join the event circle to see who else is attending and get matched with relevant people!''';
  }

  if (q.contains('stall pricing') ||
      q.contains('booth') ||
      q.contains('sponsor')) {
    return '''Stall pricing for ${event.name}:

**Standard Booth**: \$2,500 - \$5,000
**Premium Booth**: \$8,000 - \$15,000
**Platinum Sponsorship**: \$25,000+

Pricing varies based on:
• Location (corner booths cost more)
• Size and amenities
• Sponsorship tier
• Early bird discounts

Note: Exact pricing is subject to availability. For detailed sponsorship packages, contact the event organizers directly.''';
  }

  if (q.contains('join') ||
      q.contains('should i join') ||
      q.contains('circle')) {
    return '''Yes, I recommend joining the ${event.name} circle! Here's why:

**Benefits of joining:**
✅ Your assistant can match you with relevant attendees before the event
✅ Create event-specific goals (e.g., "Find 3 potential investors")
✅ Get updates and reminders
✅ Connect with other circle members
✅ Access event-specific networking features

${event.matchPercentage != null && event.matchPercentage! >= 85 ? '**This event has a ${event.matchPercentage}% match with your goals** - that\'s a strong indicator you should attend!' : ''}

Tap "Join Circle" on the event details screen to get started!''';
  }

  // Default response
  return '''Great question! Based on ${event.name}:

${event.description}

The event is happening on ${_formatDate(event.dateTime)} at ${event.location}.

${event.matchReason != null ? '\n✨ ${event.matchReason}\n' : ''}
You can ask me about:
• What to expect at the event
• How to get maximum value
• Whether it's relevant to your goals
• Who typically attends
• Stall pricing
• Whether you should join

How else can I help you with this event?''';
}

String _formatDate(DateTime date) {
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
