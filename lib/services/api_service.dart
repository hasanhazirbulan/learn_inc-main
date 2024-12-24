import 'dart:convert';
import 'package:http/http.dart' as http;
// Buraya kendi Google Generative Language (PaLM) API anahtarınızı koyun:
final String apiKey = 'AIzaSyC5gpQ5AHZDwHoJNOigtVDrRh3qgkh45RU';

// gemini-1.5-flash-latest yerine text-bison-001 gibi başka bir model kullanıyorsanız,
// endpoint ve model adını güncelleyin:
final String endpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

class ApiService {

  /// 1) Chatbot API Çağrısı
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



  /// 3) Flashcard Oluşturma (GenerateFlashcards) API Çağrısı
  /// Generate Flashcards API Call
  Future<List<String>> generateFlashcards(String text) async {
    try {
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
                  "text": """Generate flashcards in the following format:
**Front:** [Question]
**Back:** [Answer]

Based on this text:

$text"""
                }
              ]
            }
          ]
        }),
      );

      print("Flashcards API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Split the result into lines and filter out empty lines
        final lines = result
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList();

        return lines;
      } else {
        throw Exception(
            'Flashcard oluşturulamadı: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error in generateFlashcards: $e");
      rethrow;
    }
  }

  /// Summarize Document API Call
  Future<String> summarizeDocument(String document) async {
    try {
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
                  "text": "Summarize the following document, focusing on key concepts and important information:\n\n$document"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      } else {
        throw Exception(
            'Summary creation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error in summarizeDocument: $e");
      rethrow;
    }
  }

  /// Get Key Points API Call
  Future<List<String>> getKeyPoints(String document) async {
    try {
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
                  "text": "Extract the most important key points from this document:\n\n$document"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['candidates'][0]['content']['parts'][0]['text'] as String;

        return result
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim())
            .toList();
      } else {
        throw Exception(
            'Key points extraction failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error in getKeyPoints: $e");
      rethrow;
    }
  }
}

  /// 4) Key Points API Çağrısı
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

      // Yine satır satır ayırıp boşlukları atıyoruz:
      return result
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
    } else {
      throw Exception(
          'Key points çıkarılamadı: ${response.statusCode} - ${response.body}');
    }
  }

  /// 5) Tek Adımda Flashcard Üretmek İçin (Özet + KeyPoints vs.)
  /// Burada ister `getKeyPoints`, ister `summarizeDocument` + `generateFlashcards`
  /// gibi işlemler yapabilirsiniz. Örneğin:
  Future<List<String>> generateFlashcardsFromDocument(String document) async {
    try {
      // Örnek olarak: Key Points çıkarıp direkt geri dönelim
      final keyPoints = await getKeyPoints(document);
      return keyPoints;
    } catch (e) {
      throw Exception('Flashcard oluşturma işlemi başarısız: $e');
    }
  }

