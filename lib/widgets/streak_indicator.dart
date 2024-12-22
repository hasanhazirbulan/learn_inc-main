import 'package:flutter/material.dart';

class StreakIndicator extends StatelessWidget {
  final int streakDays;
  final bool isDayMode;

  const StreakIndicator({
    Key? key,
    required this.streakDays,
    required this.isDayMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Streak Icon
        Image.asset(
          'assets/streak_icon.png',
          height: 50,
          color: isDayMode ? null : Colors.white70, // Adjust color for night mode
        ),
        const SizedBox(height: 8),
        // Streak Text
        Text(
          '$streakDays Days Streak',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDayMode ? Colors.grey[800] : Colors.white70,
          ),
        ),
      ],
    );
  }
}
