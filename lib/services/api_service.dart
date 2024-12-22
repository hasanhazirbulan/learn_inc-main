import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = 'AIzaSyC5gpQ5AHZDwHoJNOigtVDrRh3qgkh45RU'; // Doğru API anahtarınızı kullanın
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

  // Chatbot API Çağrısı
  Future<String> callChatbot(String userMessage) async {
    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userMessage}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
          'API çağrısı başarısız: ${response.statusCode} - ${response.body}');
    }
  }

  // Doküman Özetleme API Çağrısı
  Future<String> summarizeDocument(String document) async {
    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "Summarize the following document:\n\n$document"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception(
          'Özet oluşturulamadı: ${response.statusCode} - ${response.body}');
    }
  }

  // Flashcard Oluşturma API Çağrısı
  Future<List<String>> generateFlashcards(String text) async {
    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "Generate flashcards based on the following text:\n\n$text"
              }
            ]
          }
        ]
      }),
    );

    print("API Response: ${response.body}"); // API yanıtını yazdır

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['candidates'][0]['content']['parts'][0]['text'];
      return result.split('\n').where((line) => line.trim().isNotEmpty).toList();
    } else {
      throw Exception(
          'Flashcard oluşturulamadı: ${response.statusCode} - ${response.body}');
    }
  }


  // Key Points API Çağrısı
  Future<List<String>> getKeyPoints(String document) async {
    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": "Extract key points from the following document:\n\n$document"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data['candidates'][0]['content']['parts'][0]['text'];
      return result.split('\n').where((line) => line.trim().isNotEmpty).toList();
    } else {
      throw Exception(
          'Key points çıkarılamadı: ${response.statusCode} - ${response.body}');
    }
  }

  // Flashcard için özetleme ve ayrıştırma işlemi
  Future<List<String>> generateFlashcardsFromDocument(String document) async {
    try {
      // Key points API'si ile key points çıkarma
      List<String> keyPoints = await getKeyPoints(document);

      // Key points listesini döndür
      return keyPoints;
    } catch (e) {
      throw Exception('Flashcard oluşturma işlemi başarısız: $e');
    }
  }
}
