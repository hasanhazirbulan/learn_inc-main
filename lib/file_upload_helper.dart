import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileUploadHelper {
  /// Picks a single file and returns the file path.
  static Future<String?> pickFile() async {
    try {
      // Open the file picker to select a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Allow any file type
        allowMultiple: false, // Single file selection
      );

      // Check if a file was selected
      if (result != null && result.files.single.path != null) {
        return result.files.single.path; // Return the file path
      }
      return null; // No file selected
    } catch (e) {
      // Print the error and return null
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Opens the file picker and shows a popup with the selected file path.
  static Future<void> showFilePicker(BuildContext context) async {
    try {
      // Pick a file
      final filePath = await pickFile();

      if (filePath != null) {
        // Show the selected file in a popup
        _showFilePopup(context, filePath);
      } else {
        // Show an error message if no file was selected
        _showErrorPopup(context, 'No file selected.');
      }
    } catch (e) {
      // Handle any errors that occur
      _showErrorPopup(context, 'An error occurred while picking the file: $e');
    }
  }

  /// Displays a popup with the selected file's path.
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

  /// Displays an error popup if something goes wrong.
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
