import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../services/flashcard_generator.dart';

class FlashyScreen extends StatefulWidget {
  final bool isDayMode;

  const FlashyScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _FlashyScreenState createState() => _FlashyScreenState();
}

class _FlashyScreenState extends State<FlashyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlashcardGenerator _flashcardGenerator = FlashcardGenerator();

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
                        'userId': currentUser.uid,
                        'showAnswer': false,
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

  /// Flashcardları dosyadan ekleme
  Future<void> _addFlashcardsFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      List<Map<String, String>> flashcards =
      await _flashcardGenerator.processFileAndGenerateFlashcards(filePath);

      if (flashcards.isNotEmpty) {
        final currentUser = _auth.currentUser;

        for (var card in flashcards) {
          await _firestore.collection('flashcards').add({
            'title': 'Generated Flashcard',
            'question': card['question'],
            'answer': card['answer'],
            'color': Colors.blue.value, // Varsayılan renk
            'userId': currentUser?.uid,
            'showAnswer': false,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcards successfully added!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No flashcards were generated.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
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
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _addFlashcardsFromFile,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('flashcards')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
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
