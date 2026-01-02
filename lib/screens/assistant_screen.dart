import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/assistant_alert.dart';
import '../utils/theme.dart';
import 'attention_alerts_screen.dart';
import 'ai_profile_screen.dart';
import 'profile_screen.dart';
import '../modules/networking/screens/my_space_screen.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final List<ChatMessage> _messages = [];
  final List<AssistantAlert> _alerts = [];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      // Add user message
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: true,
        text: text.trim(),
        timestamp: DateTime.now(),
      ));

      // Add placeholder assistant response
      _messages.add(ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_assistant',
        isUser: false,
        text:
            'This is a placeholder assistant response for: "$text". In the real app this will call the backend.',
        timestamp: DateTime.now(),
      ));
    });

    _textController.clear();
    _scrollToBottom();
  }

  void _handleQuickAction(String prompt) {
    _handleSendMessage(prompt);
  }

  void _handleAlertAction(AssistantAlert alert) {
    if (alert.actionPrompt != null) {
      _handleSendMessage(alert.actionPrompt!);
      setState(() {
        _alerts.removeWhere((a) => a.id == alert.id);
      });
    }
  }

  void _dismissAlert(String alertId) {
    setState(() {
      _alerts.removeWhere((a) => a.id == alertId);
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasConversation = _messages.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Assistant',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Alerts/Attention button
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AttentionAlertsScreen(
                        alerts: _alerts,
                        onAlertAction: _handleAlertAction,
                        onDismissAlert: (alertId) {
                          setState(() {
                            _dismissAlert(alertId);
                          });
                        },
                      ),
                    ),
                  ).then((_) {
                    // Refresh state when returning
                    setState(() {});
                  });
                },
              ),
              if (_alerts.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_alerts.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // My Space button
          IconButton(
            icon: const Icon(
              Icons.people_outline,
              color: AppTheme.textPrimary,
            ),
            tooltip: 'My Space',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySpaceScreen(),
                ),
              );
            },
          ),
          // Profile button
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppTheme.textPrimary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child:
                  hasConversation ? _buildChatView() : _buildEmptyStateView(),
            ),

            // Bottom input bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateView() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          // Greeting
          const Text(
            'Hi Founder 👋',
            style: TextStyle(
              fontSize: 24,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Where should we start?',
            style: TextStyle(
              fontSize: 32,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 40),
          // Quick action chips
          _buildQuickActionChip(
            icon: Icons.people_outline,
            label: 'Find people for my goal',
            onTap: () => _handleQuickAction(
              'Help me find the right people for my current goal. Ask me clarifying questions if needed.',
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionChip(
            icon: Icons.search,
            label: 'Search & connect',
            onTap: () => _handleQuickAction(
              'I want to search and connect with people aligned to my goals. Ask me what I\'m looking for.',
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionChip(
            icon: Icons.thumb_up_outlined,
            label: 'Review matches & suggestions',
            onTap: () => _handleQuickAction(
              'Show me my latest matches, recommendations, and anything that needs my approval.',
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionChip(
            icon: Icons.edit_outlined,
            label: 'Refine my profile',
            onTap: () => _handleQuickAction(
              'Help me refine my public founder profile and what I am currently looking for.',
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionChip(
            icon: Icons.calendar_today_outlined,
            label: 'Plan my next event',
            onTap: () => _handleQuickAction(
              'Help me plan which events or circles I should attend next, based on my goals.',
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionChip(
            icon: Icons.lightbulb_outline,
            label: 'Get strategic advice',
            onTap: () => _handleQuickAction(
              'I need strategic advice on my current goal and next steps.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              radius: 16,
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              radius: 16,
              child: const Text(
                'F',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Ask Assistant',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 15),
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleSendMessage,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.mic_none,
                      color: Colors.grey[600],
                      size: 22,
                    ),
                    onPressed: () {
                      // Mic functionality - not implemented yet
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                _handleSendMessage(_textController.text);
              },
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
