import 'package:flutter/material.dart';
import 'package:learn_inc/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService(); // API servis bağlantısı
  final TextEditingController _chatController = TextEditingController();
  List<Map<String, String>> messages = []; // Sohbet mesajlarını tutar
  bool isLoading = false;

  Future<void> sendMessage() async {
    if (_chatController.text.isNotEmpty) {
      setState(() {
        messages.add({"sender": "user", "message": _chatController.text});
        isLoading = true;
      });

      try {
        final response = await _apiService.callChatbot(_chatController.text);
        setState(() {
          messages.add({"sender": "bot", "message": response});
          isLoading = false;
          _chatController.clear();
        });
      } catch (e) {
        setState(() {
          messages.add({"sender": "bot", "message": "Bir hata oluştu: $e"});
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message["sender"] == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message["sender"] == "user"
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      message["message"]!,
                      style: TextStyle(
                        color: message["sender"] == "user"
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading) CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "Bir mesaj yaz...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
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
