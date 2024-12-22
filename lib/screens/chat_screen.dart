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

  // We store messages as a list of Maps. Each Map can have:
  // {
  //   "sender": "user" or "bot",
  //   "messageType": "text" or "flashcards",
  //   "message": String? (for text messages),
  //   "flashcardsList": List<String>? (for flashcards)
  // }
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;
  bool isFilePickerOpen = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  /// Adds an initial welcome message from the bot
  Future<void> _addWelcomeMessage() async {
    setState(() {
      messages.add({
        "sender": "bot",
        "messageType": "text",
        "message": "Hi! How can Sashimi assist you today?"
      });
    });
  }

  /// Sends a normal text message to the chatbot, gets the response, then displays it
  Future<void> sendMessage() async {
    if (_chatController.text.isNotEmpty) {
      final userMessage = _chatController.text.trim();

      // Add user message
      setState(() {
        messages.add({
          "sender": "user",
          "messageType": "text",
          "message": userMessage
        });
        isLoading = true;
      });
      _scrollToBottom();
      _chatController.clear();

      // Call the chatbot API
      try {
        final response = await _apiService.callChatbot(userMessage);

        setState(() {
          messages.add({
            "sender": "bot",
            "messageType": "text",
            "message": response
          });
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          messages.add({
            "sender": "bot",
            "messageType": "text",
            "message": "An error occurred. Please try again later."
          });
          isLoading = false;
        });
      }

      _scrollToBottom();
    }
  }

  /// Handle file upload (PDF), show the file name, then generate flashcards
  Future<void> _handleFileUpload(BuildContext context) async {
    if (isFilePickerOpen) return;
    setState(() => isFilePickerOpen = true);

    try {
      // 1) Let user pick a file
      final filePath = await FileUploadHelper.pickFile();

      if (filePath != null) {
        // Extract just the file name from the path
        final fileName = filePath.split('/').last;

        // Show the user a chat bubble indicating which file was selected
        setState(() {
          messages.add({
            "sender": "user",
            "messageType": "text",
            "message": "Selected file: $fileName"
          });
        });

        // 2) Actually process the file to generate flashcards
        final flashcards = await _fileSummaryHelper.pickFileAndGenerateFlashcards();

        // If we got a result from pickFileAndGenerateFlashcards
        if (flashcards != null) {
          if (flashcards.length == 1 &&
              (flashcards[0].contains("No file was selected.") ||
                  flashcards[0].contains("No text could be extracted") ||
                  flashcards[0].contains("error occurred"))) {
            // If there's an error or empty result
            setState(() {
              messages.add({
                "sender": "bot",
                "messageType": "text",
                "message": flashcards[0],
              });
            });
          } else {
            // We have valid flashcards
            setState(() {
              messages.add({
                "sender": "bot",
                "messageType": "flashcards",
                "flashcardsList": flashcards,
              });
            });
          }
        } else {
          // Possibly user canceled inside pickFileAndGenerateFlashcards() or some error
          setState(() {
            messages.add({
              "sender": "bot",
              "messageType": "text",
              "message": "No file was selected or an unexpected error occurred."
            });
          });
        }
      } else {
        // user canceled from the FilePicker
        setState(() {
          messages.add({
            "sender": "bot",
            "messageType": "text",
            "message": "No file was selected."
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "sender": "bot",
          "messageType": "text",
          "message": "An error occurred during file upload: $e"
        });
      });
    } finally {
      setState(() => isFilePickerOpen = false);
      _scrollToBottom();
    }
  }

  /// Scrolls the ListView to the bottom whenever new messages come in
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isDayMode = widget.isDayMode;

    return Scaffold(
      backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        title: const Text("Chat Assistant"),
        iconTheme: IconThemeData(
          color: isDayMode ? Colors.black : Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = (message["sender"] == "user");
                final messageType = message["messageType"];

                // If the message is a list of flashcards
                if (messageType == "flashcards") {
                  final flashcardsList = message["flashcardsList"] as List<String>? ?? [];
                  // Show each flashcard in a rectangular Card
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: flashcardsList.map((flashcard) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12.0,
                        ),
                        child: Card(
                          color: isDayMode ? Colors.white : Colors.grey[700],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              flashcard,
                              style: TextStyle(
                                color: isDayMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                // Otherwise, it's a normal text message
                else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    child: Row(
                      mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            backgroundImage:
                            const AssetImage('assets/octopus.png'),
                            radius: 20,
                          ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? (isDayMode ? Colors.blueAccent : Colors.grey[600])
                                  : (isDayMode ? Colors.white : Colors.grey[700]),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12.0),
                                topRight: const Radius.circular(12.0),
                                bottomLeft: isUser
                                    ? const Radius.circular(12.0)
                                    : Radius.zero,
                                bottomRight: isUser
                                    ? Radius.zero
                                    : const Radius.circular(12.0),
                              ),
                            ),
                            child: Text(
                              message["message"] ?? "",
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : (isDayMode ? Colors.black : Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // Input Bar
          Container(
            color: isDayMode ? Colors.white : Colors.grey[800],
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // File Upload Button
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: isDayMode ? Colors.black : Colors.white,
                  ),
                  onPressed: () => _handleFileUpload(context),
                ),
                const SizedBox(width: 8.0),
                // Chat text input
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: TextStyle(
                      color: isDayMode ? Colors.black : Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "Send a message...",
                      hintStyle: TextStyle(
                        color: isDayMode ? Colors.black45 : Colors.white70,
                      ),
                      filled: true,
                      fillColor:
                      isDayMode ? Colors.grey[100] : Colors.grey[700],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Send Message Button
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: isDayMode ? const Color(0xFF4DD0E1) : Colors.blue,
                  ),
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
