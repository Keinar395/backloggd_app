import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Kayıt Olma Fonksiyonu
  Future<String?> signUp({
    required String email, 
    required String password, 
    required String username
  }) async {
    try {
      // 1. Supabase Auth ile kullanıcıyı oluştur
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      final User? user = res.user;
      
      if (user != null) {
        // 2. Kullanıcı başarıyla oluştuysa, kendi oluşturduğumuz 'profiles' tablosuna kaydet
        await _supabase.from('profiles').insert({
          'id': user.id,
          'username': username,
        });
        return null; // null dönmesi "Hata yok, işlem başarılı" anlamına gelir
      }
    } on AuthException catch (e) {
      return e.message; // Şifre kısa, e-posta geçersiz vb. Supabase hataları
    } catch (e) {
      return 'An unexpected error occurred.';
    }
    return 'Sign up failed.';
  }

  // Giriş Yapma Fonksiyonu
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Çıkış Yapma
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Giriş yapmış mevcut kullanıcıyı getir
  User? get currentUser => _supabase.auth.currentUser;
}