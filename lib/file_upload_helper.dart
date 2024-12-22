import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadHelper {
  /// Picks a single file and returns the file path.
  static Future<String?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // or FileType.custom + allowedExtensions = ['pdf']
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
      return null; // No file selected
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Opens the file picker and shows a popup with the selected file path.
  static Future<void> showFilePicker(BuildContext context) async {
    try {
      final filePath = await pickFile();

      if (filePath != null) {
        _showFilePopup(context, filePath);
      } else {
        _showErrorPopup(context, 'No file selected.');
      }
    } catch (e) {
      _showErrorPopup(context, 'An error occurred while picking the file: $e');
    }
  }

  static void _showFilePopup(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Selected'),
        content: Text('Selected file path:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showErrorPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
