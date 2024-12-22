import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/api_service.dart';

class FileSummaryHelper {
  final ApiService _apiService = ApiService();

  /// 1) Pick a PDF
  /// 2) Extract its text
  /// 3) Summarize it
  /// 4) Generate flashcards from that summary
  Future<List<String>?> pickFileAndGenerateFlashcards() async {
    try {
      // Ask user to pick a PDF
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      // If user picked a file
      if (result != null) {
        File file = File(result.files.single.path!);

        // 1) Extract raw text
        String extractedText = await _extractTextFromPDF(file);
        if (extractedText.isEmpty) {
          return [
            "No text could be extracted from the PDF. Please use a valid file."
          ];
        }

        // 2) Summarize the extracted text
        final summary = await _apiService.summarizeDocument(extractedText);
        if (summary.isEmpty) {
          return ["The summary is empty. Please try another file."];
        }

        // 3) Generate flashcards from the summary
        final flashcards = await _apiService.generateFlashcards(summary);
        if (flashcards.isEmpty) {
          return [
            "No flashcards could be generated. Please try another file."
          ];
        }

        return flashcards;
      } else {
        // User canceled
        return ["No file was selected."];
      }
    } catch (e) {
      print("Error while processing file: $e");
      return ["An error occurred while processing the file: $e"];
    }
  }

  /// Extract text from PDF
  Future<String> _extractTextFromPDF(File file) async {
    try {
      final pdfDocument = PdfDocument(inputBytes: file.readAsBytesSync());
      String text = PdfTextExtractor(pdfDocument).extractText();
      pdfDocument.dispose();
      return text;
    } catch (e) {
      print("PDF text extraction error: $e");
      return "";
    }
  }
}
