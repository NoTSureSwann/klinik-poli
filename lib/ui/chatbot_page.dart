import 'package:flutter/material.dart';
import '../service/ai_assistant_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _msgCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  final AIAssistantService _aiService = AIAssistantService();

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _msgCtrl.clear();

    final response = await _aiService.getDiagnosis(text);

    setState(() {
      _messages.add({"role": "ai", "content": response});
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Symptom Checker", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6C63FF),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    child: Text(msg["content"] ?? ""),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text("AI sedang berpikir...")
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: InputDecoration(
                      hintText: "Ceritakan gejala Anda...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Color(0xFF6C63FF),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
