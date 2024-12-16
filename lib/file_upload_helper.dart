import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:learn_inc/screens/dashboard_screen.dart';

class FileUploadHelper {
  static Future<void> showFilePicker(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      _showFilePopup(context, filePath);
    }
  }

  static void _showFilePopup(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('File Selected'),
        content: Text('Selected file path:\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
