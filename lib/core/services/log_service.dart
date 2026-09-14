import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game.dart';

class LogService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Oyunu kaydetme (veya durumunu güncelleme) fonksiyonu
  // Oyunu kaydetme (Durum, Favori, Puan ve İnceleme ile birlikte)
  Future<void> logGame({
    required Game game, 
    required String status,
    bool isFavorite = false,
    int? rating,
    String? reviewText,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    
    if (userId == null) {
      throw Exception('Giriş yapmış bir kullanıcı bulunamadı!');
    }

    await _supabase.from('user_logs').upsert({
      'user_id': userId,
      'game_id': game.id,
      'game_name': game.name,
      'cover_url': game.coverUrl,
      'status': status,
      'is_favorite': isFavorite, // Yeni
      'rating': rating,           // Yeni
      'review_text': reviewText,  // Yeni
    }, onConflict: 'user_id, game_id');
  }
}