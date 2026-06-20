import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harmfilter_flutter/widgets/hf_button.dart';
import 'package:harmfilter_flutter/widgets/hf_card.dart';
import 'package:harmfilter_flutter/widgets/hf_input.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  final List<String> _quickReplies = [
    "Suggest a rewrite",
    "Why is this harmful?",
    "How can I express disagreement?",
    "Teach me about empathy",
  ];

  void _handleSend() {
    if (_textController.text.trim().isEmpty) return;

    final userMessage = {
      'id': DateTime.now().toString(),
      'role': 'user',
      'content': _textController.text,
      'timestamp': DateTime.now(),
    };

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    final input = _textController.text;
    _textController.clear();
    _scrollToBottom();

    // Mock response delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      final responseContent = _getMockResponse(input);
      final botMessage = {
        'id': DateTime.now().toString(),
        'role': 'assistant',
        'content': responseContent,
        'timestamp': DateTime.now(),
      };

      setState(() {
        _messages.add(botMessage);
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _getMockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('rewrite') || lower.contains('rephrase')) {
      return "I'd be happy to help you rephrase that! Could you share the text you'd like to improve? I'll suggest more constructive ways to express the same idea.";
    }
    if (lower.contains('harmful') || lower.contains('why')) {
      return "Language can be harmful when it: 1) Dehumanizes groups of people, 2) Incites violence or exclusion, 3) Reinforces harmful stereotypes, or 4) Dismisses others' humanity. Would you like specific examples?";
    }
    if (lower.contains('disagree') || lower.contains('argument')) {
      return "You can disagree strongly while being respectful! Try: 1) Focus on actions, not character ('I disagree with this approach' vs 'You're an idiot'), 2) Use 'I' statements ('I see it differently'), 3) Acknowledge their perspective first ('I understand where you're coming from, but...'), 4) Suggest alternatives instead of just criticizing.";
    }
    if (lower.contains('empathy') || lower.contains('compassion')) {
      return "Empathy is about understanding others' feelings and perspectives, even when we disagree. Try to: 1) Consider their experiences and context, 2) Separate the person from their actions, 3) Ask questions to understand better, 4) Recognize our shared humanity. Remember: empathy doesn't mean agreement!";
    }
    return "That's a great question! I'm here to help you communicate with more compassion. Could you tell me more about what you're trying to express or what situation you're facing?";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: HFCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(LucideIcons.bot, color: HFTheme.accent),
                  const SizedBox(width: 8),
                  Text('Compassion Coach', style: GoogleFonts.inter(color: HFTheme.primaryTextColor(context), fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text('LIVE', style: GoogleFonts.inter(color: HFTheme.secondaryTextColor(context), fontSize: 10)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: (_messages.isEmpty ? 1 : _messages.length) + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_messages.isEmpty && index == 0) {
                      return Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: Text(
                      'How can I help you reframe this conversation?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: HFTheme.primaryTextColor(context), fontSize: 18),
                    ),
                  );
                }

                final adjustedIndex = _messages.isEmpty ? index - 1 : index;
                if (adjustedIndex == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[adjustedIndex];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? HFTheme.accent : theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isUser ? HFTheme.accent : theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['content'],
                          style: TextStyle(color: isUser ? Colors.white : HFTheme.primaryTextColor(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(msg['timestamp']),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isUser ? Colors.white70 : HFTheme.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _quickReplies
                  .map(
                    (reply) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: theme.cardColor,
                        side: BorderSide(color: theme.dividerColor),
                        label: Text(reply, style: GoogleFonts.inter(color: HFTheme.primaryTextColor(context), fontSize: 11)),
                        onPressed: () {
                          _textController.text = reply;
                          _textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _textController.text.length),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: HFInput(
                    controller: _textController,
                    label: 'Message',
                    hint: 'Describe what you want to say...',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 52,
                  child: HFButton(
                    label: '',
                    icon: LucideIcons.send,
                    onPressed: _isTyping ? null : _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.cardColor,
              child: Icon(LucideIcons.bot, size: 16, color: HFTheme.accent),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 4,
                    height: 4,
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Typing...',
                    style: TextStyle(fontSize: 12, color: HFTheme.secondaryTextColor(context)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
