import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learn_inc/services/api_service.dart';

class FlashcardScreen extends StatefulWidget {
  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final ApiService apiService = ApiService();
  String documentContent = ""; // Yüklenen dokümanın içeriği
  String summary = ""; // Özet
  List<String> flashcards = []; // Flashcard listesi

  Future<void> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'], // Örnek: Sadece metin dosyalarına izin veriyoruz
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        setState(() {
          documentContent = content;
        });
      }
    } catch (e) {
      setState(() {
        documentContent = "Hata: $e";
      });
    }
  }

  Future<void> summarizeAndGenerateFlashcards() async {
    try {
      // 1. Doküman özeti alın
      final generatedSummary = await apiService.summarizeDocument(documentContent);
      setState(() {
        summary = generatedSummary;
      });

      // 2. Özete göre flashcard oluştur
      final generatedFlashcards = await apiService.generateFlashcards(generatedSummary);
      setState(() {
        flashcards = generatedFlashcards;
      });
    } catch (e) {
      setState(() {
        summary = "Hata: $e";
        flashcards = ["Flashcard oluşturulamadı: $e"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dokümandan Flashcard Oluşturma")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: pickDocument,
                child: Text("Doküman Yükle"),
              ),
              SizedBox(height: 16),
              Text(
                "Yüklenen Doküman İçeriği:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(documentContent.isEmpty ? "Henüz bir doküman yüklenmedi." : documentContent),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: summarizeAndGenerateFlashcards,
                child: Text("Flashcard Oluştur"),
              ),
              SizedBox(height: 16),
              Text(
                "Özet:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(summary.isEmpty ? "Henüz bir özet oluşturulmadı." : summary),
              SizedBox(height: 16),
              Text(
                "Flashcards:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (var card in flashcards) Text("- $card"),
            ],
          ),
        ),
      ),
    );
  }
}
