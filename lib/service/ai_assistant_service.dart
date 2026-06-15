import 'package:dio/dio.dart';

class AIAssistantService {
  // Ganti dengan API Key Groq Anda
  static const String _apiKey = "YOUR_GROQ_API_KEY"; 
  static const String _baseUrl = "https://api.groq.com/openai/v1/chat/completions";

  Future<String> getDiagnosis(String symptoms) async {
    if (_apiKey == "YOUR_GROQ_API_KEY") {
      return "Sistem AI sedang offline. Harap masukkan API Key Groq yang valid di file ai_assistant_service.dart.";
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        _baseUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_apiKey",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "model": "llama3-8b-8192", // atau mixtral-8x7b-32768
          "messages": [
            {
              "role": "system",
              "content": "Anda adalah asisten medis virtual untuk Poliklinik Sehat. Tugas Anda menganalisis gejala yang diberikan pasien, memberikan kemungkinan diagnosis, saran penanganan awal, dan merekomendasikan ke Poli/Spesialis mana mereka harus mendaftar (misal: Poli Umum, Poli Gigi, Poli Penyakit Dalam, Poli Anak, dll). Jawab dalam bahasa Indonesia yang profesional dan ramah."
            },
            {
              "role": "user",
              "content": symptoms
            }
          ],
          "temperature": 0.7,
        },
      );

      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      } else {
        return "Gagal mendapatkan respons dari server AI.";
      }
    } catch (e) {
      return "Terjadi kesalahan saat menghubungi server AI: $e";
    }
  }
}
