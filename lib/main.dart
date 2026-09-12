import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/main_layout/main_layout_screen.dart';

void main() {
  runApp(const BackloggdApp());
}

class BackloggdApp extends StatelessWidget {
  const BackloggdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backloggd',
      debugShowCheckedModeBanner: false, // Sağ üstteki debug yazısını kaldırır
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          surface: AppColors.surfaceDark,
        ),
        fontFamily: 'Roboto', // Şimdilik varsayılan font, sonra Inter'e geçebiliriz
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
        ),
      ),
      home: const MainLayoutScreen(), // Şimdilik geçici bir ekran
    );
  }
}

// Alt barı yapana kadar siyah ekran görmemek için geçici bir sayfa
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Backloggd Prototipine Hoş Geldin!',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
      ),
    );
  }
}