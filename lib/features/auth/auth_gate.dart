import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../main_layout/main_layout_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Supabase'in anlık oturum durumunu dinleyen widget
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Durum henüz kontrol ediliyorsa siyah bir yükleme ekranı göster
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
          );
        }

        // Oturum (session) varsa, kullanıcı giriş yapmıştır
        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          return const MainLayoutScreen(); // İçeri al
        }
        
        return const LoginScreen(); // Oturum yoksa Login'e at
      },
    );
  }
}