import 'package:flutter/material.dart';
import 'dart:math';

class LearnScreen extends StatefulWidget {
  final bool isDayMode;

  const LearnScreen({Key? key, required this.isDayMode}) : super(key: key);

  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // Rastgele bilgiler için bir liste
  final List<String> _facts = [
    "Python, dünyadaki en popüler programlama dillerinden biridir.",
    "Flutter, Google tarafından geliştirilen açık kaynaklı bir UI SDK'sıdır.",
    "Django, güçlü bir Python web çerçevesidir.",
    "Java, 1995 yılında Sun Microsystems tarafından geliştirilmiştir.",
    "Veri yapıları, yazılım geliştirmede temel taşlardan biridir.",
    "Algoritma analizi, yazılım performansını artırmak için gereklidir.",
    "Ahtapotların 3 kalbi vardır!",
    "Dünya üzerinde bilinen en uzun ömürlü canlı bir denizanasıdır.",
    "Bir insan hayatı boyunca ortalama 25 yılını uyuyarak geçirir.",
    "Venüs’te bir gün, bir yıldan daha uzundur.",
    "Kediler 100 farklı ses çıkarabilirken, köpekler sadece 10 ses çıkarabilir.",
    "Bir flamingonun rengi, yediği yiyeceklerden kaynaklanır.",
    "Dünyadaki karıncaların toplam ağırlığı, insanların toplam ağırlığına eşittir.",
    "Bir insan 3 saniyeden kısa sürede gülümseyebilir ama bu anı bir ömür boyu hatırlayabilir."
  ];

  // Şu anki rastgele bilgi
  String _currentFact = "";

  @override
  void initState() {
    super.initState();
    // İlk bilgiyi rastgele seç
    _generateRandomFact();
  }

  // Rastgele bir bilgi seçer
  void _generateRandomFact() {
    setState(() {
      _currentFact = _facts[Random().nextInt(_facts.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDayMode = widget.isDayMode;

    return Scaffold(
      backgroundColor: isDayMode ? const Color(0xFFE0F7FA) : const Color(0xFF263238),
      appBar: AppBar(
        backgroundColor: isDayMode ? const Color(0xFF4DD0E1) : const Color(0xFF37474F),
        title: const Text("Did you know that?"),
        iconTheme: IconThemeData(
          color: isDayMode ? Colors.black : Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rastgele bilgi gösterimi
            Text(
              _currentFact,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDayMode ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            // Yeni bilgi üretme düğmesi
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDayMode ? Colors.blue : Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _generateRandomFact,
              child: const Text(
                "Show me a new one",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
