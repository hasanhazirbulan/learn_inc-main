import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FlashyScreen extends StatefulWidget {
  final bool isDayMode;

  const FlashyScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _FlashyScreenState createState() => _FlashyScreenState();
}

class _FlashyScreenState extends State<FlashyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  Color selectedColor = Colors.blue;

  @override
  void dispose() {
    titleController.dispose();
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  /// Kart ekleme veya düzenleme
  void _addOrEditFlashcard({String? cardId, Map<String, dynamic>? existingCard}) async {
    if (existingCard != null) {
      titleController.text = existingCard['title'];
      questionController.text = existingCard['question'];
      answerController.text = existingCard['answer'];
      selectedColor = Color(existingCard['color']);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
              ),
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Soru'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Cevap'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Kart Rengi:"),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      _buildColorCircle(Colors.blue),
                      _buildColorCircle(Colors.green),
                      _buildColorCircle(Colors.orange),
                      _buildColorCircle(Colors.red),
                      _buildColorCircle(Colors.purple),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      questionController.text.isNotEmpty &&
                      answerController.text.isNotEmpty) {
                    final currentUser = _auth.currentUser;
                    if (currentUser != null) {
                      final cardData = {
                        'title': titleController.text,
                        'question': questionController.text,
                        'answer': answerController.text,
                        'color': selectedColor.value,
                        'userId': currentUser.uid, // Kullanıcıya özel ID
                        'showAnswer': false, // Cevabın görünürlük durumu
                      };

                      if (cardId != null) {
                        // Kartı güncelle
                        await _firestore.collection('flashcards').doc(cardId).update(cardData);
                      } else {
                        // Yeni kart ekle
                        await _firestore.collection('flashcards').add(cardData);
                      }

                      titleController.clear();
                      questionController.clear();
                      answerController.clear();
                      Navigator.pop(context); // Modal'ı kapat
                    }
                  }
                },
                child: Text(existingCard == null ? "Kartı Ekle" : "Kartı Güncelle"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: selectedColor == color
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDayMode = widget.isDayMode;

    return Scaffold(
      backgroundColor: isDayMode ? Color(0xFFE0F7FA) : Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? Color(0xFF4DD0E1) : Color(0xFF37474F),
        title: const Text("Flashy"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditFlashcard(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('flashcards')
            .where('userId', isEqualTo: _auth.currentUser?.uid) // Sadece giriş yapan kullanıcıya özel kartlar
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Henüz flashcard oluşturulmadı!",
                style: TextStyle(
                  fontSize: 18,
                  color: isDayMode ? Colors.black : Colors.white,
                ),
              ),
            );
          }

          final flashcards = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final card = flashcards[index].data() as Map<String, dynamic>;
              final cardId = flashcards[index].id;

              return GestureDetector(
                onTap: () async {
                  // Cevabı göstermek için veritabanında `showAnswer` alanını güncelleriz.
                  await _firestore
                      .collection('flashcards')
                      .doc(cardId)
                      .update({'showAnswer': !(card['showAnswer'] ?? false)});
                },
                onLongPress: () {
                  _addOrEditFlashcard(cardId: cardId, existingCard: card);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Color(card['color']),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Soru: ${card['question']}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      if (card['showAnswer'] ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            "Cevap: ${card['answer']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
