import 'dart:convert';
import 'package:http/http.dart' as http;

// Buraya kendi Google Generative Language (PaLM) API anahtarınızı koyun:
final String apiKey = 'AIzaSyC5gpQ5AHZDwHoJNOigtVDrRh3qgkh45RU';

// gemini-1.5-flash-latest yerine text-bison-001 gibi başka bir model kullanıyorsanız,
// endpoint ve model adını güncelleyin:
final String endpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent';

class ApiService {
  /// Chatbot API Çağrısı
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
      throw Exception('API çağrısı başarısız: ${response.statusCode} - ${response.body}');
    }
  }

  /// Quiz Soruları Üretme API Çağrısı
  Future<List<QuizQuestion>> generateQuizQuestions(String text) async {
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
                  "text": """Generate multiple-choice questions with 4 options each from the following text. Format each question as:

**1. Question text?**
a) First option
b) Second option
c) Third option
d) Fourth option

$text"""
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Updated regex pattern to correctly capture all parts of the question
        final RegExp questionRegExp = RegExp(
          r'\*\*\d+\.\s+(.*?)\*\*\s*\n\s*a\)\s*(.*?)\s*\n\s*b\)\s*(.*?)\s*\n\s*c\)\s*(.*?)\s*\n\s*d\)\s*(.*?)(?=\n\s*\*\*|\s*$)',
          dotAll: true,
        );

        final matches = questionRegExp.allMatches(result);
        List<QuizQuestion> questions = [];

        for (var match in matches) {
          if (match.groupCount >= 5) {
            String question = match.group(1)?.trim() ?? '';
            List<String> options = [
              match.group(2)?.trim() ?? '',
              match.group(3)?.trim() ?? '',
              match.group(4)?.trim() ?? '',
              match.group(5)?.trim() ?? '',
            ];

            // Validate that we have all required data
            if (question.isNotEmpty && options.every((option) => option.isNotEmpty)) {
              // For this example, we'll set the first option as the correct answer
              // In a real application, you might want to have the API specify the correct answer
              questions.add(QuizQuestion(
                question: question,
                options: options,
                answer: options[0],
              ));
            }
          }
        }

        if (questions.isEmpty) {
          throw Exception('No valid questions could be parsed from the API response');
        }

        return questions;
      } else {
        throw Exception('Failed to generate quiz: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error in generateQuizQuestions: $e");
      rethrow;
    }
  }



  List<QuizQuestion> _parseQuizQuestions(String text) {
    final RegExp questionRegExp = RegExp(
      r"\*\*(\d+)\.\s*(.*?)\n(a|b|c|d)\)\s*(.*?)\n", // Match question and options
      dotAll: true,
    );

    final matches = questionRegExp.allMatches(text);
    List<QuizQuestion> questions = [];

    for (var match in matches) {
      String question = match.group(2)?.trim() ?? '';
      List<String> options = [
        match.group(3)?.trim() ?? '',
        match.group(4)?.trim() ?? '',
        match.group(5)?.trim() ?? '',
        match.group(6)?.trim() ?? '',
      ];
      String answer = match.group(1)?.trim() ?? '';

      questions.add(QuizQuestion(
        question: question,
        options: options,
        answer: answer,
      ));
    }

    return questions;
  }




  /// Flashcard Oluşturma API Çağrısı
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

  /// Belgeyi Özetleme API Çağrısı
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
        throw Exception('Summary creation failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error in summarizeDocument: $e");
      rethrow;
    }
  }

  /// Anahtar Noktaları Çekme API Çağrısı
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

// models/quiz_question.dart
class QuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'answer': answer,
  };
}


class Quiz {
  List<QuizQuestion> questions;

  Quiz({
    required this.questions,
  });

  factory Quiz.fromJson(String jsonString) {
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final List<QuizQuestion> questions = [];
    for (var questionJson in jsonMap['questions']) {
      questions.add(QuizQuestion.fromJson(questionJson));
    }
    return Quiz(questions: questions);
  }
}
