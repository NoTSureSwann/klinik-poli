import 'package:dio/dio.dart';

class ChatMessage {
  final String role;
  final String content;
  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toMap() => {'role': role, 'content': content};
}

class ChatbotService {
  static const String _apiKey = 'YOUR_GROQ_API_KEY'; // TODO: Ganti dengan API Key Anda
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  static const String _systemPrompt = '''Firebase has multiple services to help me integrate AI into my application. Tell me more about how Firebase AI Logic can be used to integrate AI into my application. Use my current project for context. Be concise and limit your response to 300 words or less.
```graphql
type User @table {
email: String!
}

type Document @table {
title: String!
content: String!
embeddingVector: Vector @col(size: 768)
summary: String
tags: String
user: User!
}

type Collection @table {
name: String!
user: User!
}

type DocCollection @table(key: ["document", "collection"]) {
document: Document!
collection: Collection!
}

type QueryHistory @table {
question: String!
response: String!
user: User!
document: Document!
}
```

You are an AI assistant integrated into a Klinik (Clinic) management application. 
The app manages: Poli (Clinic Departments), Jadwal Poli (Doctor Schedules), Antrian (Patient Queue System), Pegawai (Staff/Doctors), and Pasien (Patients).
Help users with questions about the clinic system, appointment scheduling, patient management, and general health queries.
Be professional, empathetic, and concise. Respond in the same language the user writes (Indonesian or English).''';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 60),
  ));

  final List<ChatMessage> _history = [];

  List<ChatMessage> get history => List.unmodifiable(_history);

  Future<String> sendMessage(String userMessage) async {
    _history.add(ChatMessage(role: 'user', content: userMessage));

    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ..._history.map((m) => m.toMap()),
    ];

    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          'model': _model,
          'messages': messages,
          'temperature': 1,
          'max_completion_tokens': 1024,
          'top_p': 1,
          'stream': false,
          'stop': null,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      final content = response.data['choices'][0]['message']['content'] as String;
      _history.add(ChatMessage(role: 'assistant', content: content));
      return content;
    } on DioException catch (e) {
      final errMsg = e.response?.data?.toString() ?? e.message ?? 'Terjadi kesalahan koneksi';
      throw Exception('Groq API Error: $errMsg');
    }
  }

  void clearHistory() {
    _history.clear();
  }
}
