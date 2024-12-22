import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/api_service.dart';

class FileSummaryHelper {
  final ApiService _apiService = ApiService();

  /// PDF seç, metni çıkar ve key points oluştur
  Future<List<String>?> pickFileAndGenerateFlashcards() async {
    try {
      // Kullanıcıdan PDF dosyası seçmesini ister
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // Sadece PDF dosyalarına izin ver
      );

      if (result != null) {
        // Dosyayı oluştur
        File file = File(result.files.single.path!);

        // PDF'den metin çıkarma
        String extractedText = await _extractTextFromPDF(file);

        // Eğer metin çıkarılamadıysa veya boşsa uyarı döndür
        if (extractedText.isEmpty) {
          return ["No text could be extracted from the PDF. Please use a valid file."];
        }

        // API'ye metni gönder ve key points al
        List<String> flashcards = await _apiService.getKeyPoints(extractedText);

        // Eğer flashcards boşsa kullanıcıyı bilgilendir
        if (flashcards.isEmpty) {
          return ["No key points could be generated. Please try another file."];
        }

        return flashcards; // Flashcards'ı döndür
      } else {
        // Dosya seçilmezse kullanıcıyı bilgilendir
        return ["No file was selected."];
      }
    } catch (e) {
      // Genel hata yönetimi
      print("Hata: $e");
      return ["An error occurred while processing the file: $e"];
    }
  }

  /// PDF'den metin çıkarma işlemi
  Future<String> _extractTextFromPDF(File file) async {
    try {
      // PDF belgesini yükle
      final PdfDocument pdfDocument = PdfDocument(inputBytes: file.readAsBytesSync());

      // PDF'den metni çıkar
      String text = PdfTextExtractor(pdfDocument).extractText();

      // Belleği temizle
      pdfDocument.dispose();

      return text;
    } catch (e) {
      print("PDF text extraction error: $e");
      return ""; // Hata durumunda boş metin döndür
    }
  }
}
