import 'package:flutter/material.dart';
import 'package:learn_inc/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final bool isDayMode;

  const ChatScreen({super.key, required this.isDayMode});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  Future<void> _addWelcomeMessage() async {
    setState(() {
      messages.add({
        "sender": "bot",
        "message": "Hi!  How can SashimiBot assist you today?"
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
            "message": "An error occurred. Please try again later. "
          });
          isLoading = false;
        });
      }

      _scrollToBottom();
    }
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
    final isDayMode = widget.isDayMode;

    return Scaffold(
      backgroundColor: isDayMode ? Color(0xFFE0F7FA) : Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? Color(0xff4DD0E1) : Color(0xFF37474F),
        title: Text(
          "SashimiBot",
          style: TextStyle(
            color: isDayMode ? Colors.black87 : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDayMode ? Colors.black87 : Colors.white,
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

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isUser
                          ? (isDayMode ? Colors.lightBlueAccent : Colors.blueGrey)
                          : (isDayMode ? Colors.white : Colors.grey[700]),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                        bottomLeft: isUser ? Radius.circular(12.0) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : Radius.circular(12.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDayMode
                              ? Colors.grey.withOpacity(0.3)
                              : Colors.black54,
                          blurRadius: 4.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message["message"]!,
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : (isDayMode ? Colors.black87 : Colors.white),
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircularProgressIndicator(
                    color: isDayMode ? Colors.blue : Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "SashimiBot is typing...",
                    style: TextStyle(
                      color: isDayMode ? Colors.black87 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            color: isDayMode ? Colors.white : Color(0xFF37474F),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: TextStyle(
                      color: isDayMode ? Colors.black87 : Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "Type a message to SashimiBot...",
                      hintStyle: TextStyle(
                        color: isDayMode ? Colors.grey[600] : Colors.grey[300],
                      ),
                      filled: true,
                      fillColor: isDayMode ? Colors.grey[100] : Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: sendMessage,
                  child: CircleAvatar(
                    backgroundColor: isDayMode ? Color(0xff4DD0E1) : Color(0xFF607D8B),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
