import 'package:flutter/material.dart';

import 'ui/home_screen.dart';

final class MoodistApp extends StatelessWidget {
  const MoodistApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B8C7B),
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Moodist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF101512),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A211D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        sliderTheme: const SliderThemeData(
          trackHeight: 3,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
