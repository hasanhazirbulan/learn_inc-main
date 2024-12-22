import 'package:flutter/material.dart';

class FlashcardScreen extends StatefulWidget {
  final List<String> flashcards;

  const FlashcardScreen({super.key, required this.flashcards});

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with TickerProviderStateMixin {
  List<String> cardContent = [];
  Offset _position = Offset.zero; // Kartın pozisyonu
  int currentCardIndex = 0; // Şu anki kart indeksi
  double cardHeight = 200;
  double cardWidth = 300;

  @override
  void initState() {
    super.initState();
    cardContent = widget.flashcards; // Flashcard listesini al
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta; // Kartı sürüklerken pozisyonu güncelle
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_position.dx.abs() > 150) {
      // Kart belirli bir mesafenin ötesine sürüklenirse
      setState(() {
        _position = Offset.zero; // Pozisyonu sıfırla
        cardContent.removeAt(currentCardIndex); // Şu anki kartı listeden kaldır
      });
    } else {
      // Sürükleme yeterli değilse, kartı geri yerine getir
      setState(() {
        _position = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flashcards"),
      ),
      body: Center(
        child: cardContent.isEmpty
            ? Text(
          "Tüm flashcard'lar bitti!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        )
            : Stack(
          children: cardContent.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;

            return AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              left: _position.dx,
              top: _position.dy,
              child: GestureDetector(
                onPanUpdate: _onDragUpdate, // Sürükleme işlemi
                onPanEnd: _onDragEnd, // Sürükleme bitişi
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: cardWidth,
                  height: cardHeight,
                  margin: EdgeInsets.only(top: index * 15.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xffFF9A8B),
                        Color(0xffFF6A88),
                        Color(0xffFF99AC),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
