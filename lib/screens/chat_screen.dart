import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:learn_inc/services/api_service.dart';
import 'package:learn_inc/providers/user_provider.dart';
import 'package:learn_inc/file_upload_helper.dart';
import 'package:learn_inc/services/file_summary_helper.dart';

class ChatScreen extends StatefulWidget {
  final bool isDayMode;

  const ChatScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final FileSummaryHelper _fileSummaryHelper = FileSummaryHelper();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;
  bool isFilePickerOpen = false; // To prevent duplicate file picker calls

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  Future<void> _addWelcomeMessage() async {
    setState(() {
      messages.add({
        "sender": "bot",
        "message": "Hi! How can Sashimi assist you today?"
      });
    });
  }

  Future<void> sendMessage() async {
    if (_chatController.text.isNotEmpty) {
      final userMessage = _chatController.text.trim();
      setState(() {
        messages.add({"sender": "user", "message": userMessage});
        isLoading = true;
      });
      _scrollToBottom();

      _chatController.clear();

      try {
        final response = await _apiService.callChatbot(userMessage);
        setState(() {
          messages.add({"sender": "bot", "message": response});
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          messages.add({
            "sender": "bot",
            "message": "An error occurred. Please try again later."
          });
          isLoading = false;
        });
      }

      _scrollToBottom();
    }
  }

  Future<void> _handleFileUpload(BuildContext context) async {
    if (isFilePickerOpen) return; // Prevent duplicate calls

    setState(() {
      isFilePickerOpen = true; // Lock the file picker
    });

    try {
      final filePath = await FileUploadHelper.pickFile();

      if (filePath != null) {
        setState(() {
          messages.add({
            "sender": "user",
            "message": "Selected file: ${filePath.split('/').last}"
          });
        });

        // Process the file to generate flashcards
        final flashcards = await _fileSummaryHelper.pickFileAndGenerateFlashcards();

        if (flashcards != null && flashcards.isNotEmpty) {
          setState(() {
            messages.add({
              "sender": "bot",
              "message": "Here are the key points:\n${flashcards.join('\n')}"
            });
          });
        } else {
          setState(() {
            messages.add({
              "sender": "bot",
              "message": "Couldn't process the file. Please try again with another file."
            });
          });
        }
      } else {
        setState(() {
          messages.add({
            "sender": "bot",
            "message": "No file was selected."
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "bot",
          "message": "An error occurred during file upload: $e"
        });
      });
    } finally {
      setState(() {
        isFilePickerOpen = false; // Unlock the file picker
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isDayMode = widget.isDayMode;
    final userProfileImage = userProvider.user?.profileImage ?? 'assets/default_avatar.png';

    return Scaffold(
      backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        title: const Text("Sashimi"),
        iconTheme: IconThemeData(
          color: isDayMode ? Colors.black : Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["sender"] == "user";

                return Row(
                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      CircleAvatar(
                        backgroundImage: const AssetImage('assets/octopus.png'),
                        radius: 20,
                      ),
                    Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isUser
                            ? (isDayMode ? Colors.blueAccent : Colors.grey[600])
                            : (isDayMode ? Colors.white : Colors.grey[700]),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        message["message"]!,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : (isDayMode ? Colors.black : Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            color: isDayMode ? Colors.white : Colors.grey[800],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file,
                      color: isDayMode ? Colors.black : Colors.white),
                  onPressed: () => _handleFileUpload(context),
                ),
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: TextStyle(color: isDayMode ? Colors.black : Colors.white),
                    decoration: InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(
                          color: isDayMode ? Colors.black45 : Colors.white70),
                      filled: true,
                      fillColor: isDayMode ? Colors.grey[100] : Colors.grey[700],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,
                      color: isDayMode ? const Color(0xFF4DD0E1) : Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
