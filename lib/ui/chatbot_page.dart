import 'dart:ui';
import 'package:flutter/material.dart';
import '../service/chatbot_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> with TickerProviderStateMixin {
  final ChatbotService _service = ChatbotService();
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatBubble> _bubbles = [];
  bool _isTyping = false;
  late AnimationController _typingAnimCtrl;

  // ────────── Color palette ──────────
  static const _accent1   = Color(0xFF6C63FF);
  static const _accent2   = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _typingAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Welcome bubble
    _bubbles.add(_ChatBubble(
      isUser: false,
      text: '👋 Halo! Saya **Asisten Klinik AI** yang siap membantu Anda.\n\nSaya dapat menjawab pertanyaan seputar:\n• 🏥 Jadwal & Poli\n• 🔢 Sistem Antrian\n• 👨‍⚕️ Dokter & Pegawai\n• 🩺 Info Kesehatan Umum\n\nSilakan tanyakan apa saja!',
    ));
  }

  @override
  void dispose() {
    _typingAnimCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _bubbles.add(_ChatBubble(isUser: true, text: text));
      _isTyping = true;
      _inputCtrl.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _service.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _bubbles.add(_ChatBubble(isUser: false, text: reply));
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bubbles.add(_ChatBubble(
          isUser: false,
          text: '⚠️ Maaf, terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}',
          isError: true,
        ));
        _isTyping = false;
      });
    }
    _scrollToBottom();
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(theme)),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_accent1, _accent2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asisten Klinik AI',
                  style: TextStyle(color: theme.textTheme.titleLarge?.color, fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.5), blurRadius: 6)]),
                  ),
                  const SizedBox(width: 4),
                  Text('Online • llama-3.3-70b',
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_sweep_rounded, color: theme.iconTheme.color),
          tooltip: 'Hapus percakapan',
          onPressed: () {
            _service.clearHistory();
            setState(() {
              _bubbles.clear();
              _bubbles.add(_ChatBubble(isUser: false, text: '🔄 Percakapan telah direset. Ada yang bisa saya bantu?'));
            });
          },
        ),
      ],
    );
  }

  Widget _buildMessageList(ThemeData theme) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _bubbles.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _bubbles.length && _isTyping) {
          return _buildTypingIndicator(theme);
        }
        return _buildBubble(_bubbles[index], theme);
      },
    );
  }

  Widget _buildBubble(_ChatBubble bubble, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final botBgColor = isDark ? const Color(0xFF1E2340) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Align(
      alignment: bubble.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: bubble.isUser ? 60 : 0,
          right: bubble.isUser ? 0 : 60,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(bubble.isUser ? 20 : 4),
            bottomRight: Radius.circular(bubble.isUser ? 4 : 20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubble.isError
                    ? Colors.redAccent.withValues(alpha: 0.2)
                    : bubble.isUser
                        ? _accent1.withValues(alpha: 0.85)
                        : botBgColor.withValues(alpha: 0.9),
                border: Border.all(
                  color: bubble.isUser
                      ? _accent1.withValues(alpha: 0.4)
                      : _accent2.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!bubble.isUser) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.smart_toy_rounded, size: 14, color: _accent2.withValues(alpha: 0.8)),
                        const SizedBox(width: 4),
                        Text('AI Assistant',
                            style: TextStyle(color: _accent2.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  _buildFormattedText(bubble.text, bubble.isUser, textColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text, bool isUser, Color botTextColor) {
    // Simple bold formatting support for **text**
    final parts = text.split('**');
    List<TextSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i.isOdd ? FontWeight.bold : FontWeight.normal,
          color: isUser ? Colors.white : botTextColor,
          fontSize: 14.5,
          height: 1.5,
        ),
      ));
    }
    return SelectableText.rich(TextSpan(children: spans));
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final botBgColor = isDark ? const Color(0xFF1E2340) : Colors.white;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: botBgColor.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20),
            bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: _accent2.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _buildDot(i)),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimCtrl,
      builder: (context, child) {
        final offset = ((_typingAnimCtrl.value + index * 0.33) % 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8 + (offset * 4),
          decoration: BoxDecoration(
            color: _accent2.withValues(alpha: 0.4 + offset * 0.6),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor?.withValues(alpha: 0.8),
            border: Border(top: BorderSide(color: _accent1.withValues(alpha: 0.2))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: _accent1.withValues(alpha: 0.3)),
                  ),
                  child: TextField(
                    controller: _inputCtrl,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 15),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ketik pesan Anda...',
                      hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendMessage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isTyping
                          ? [Colors.grey.shade700, Colors.grey.shade600]
                          : [_accent1, _accent2],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: _isTyping ? [] : [
                      BoxShadow(color: _accent1.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(
                    _isTyping ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble {
  final bool isUser;
  final String text;
  final bool isError;
  _ChatBubble({required this.isUser, required this.text, this.isError = false});
}
