import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class IGDBService {
  // TODO: Twitch'ten aldığın anahtarları buraya yapıştır
  final String clientId = 'ql5t20hvmi3dzxbulljsbt6vijalre';
  final String clientSecret = 'sf4vfs49k2wb5ub2gl02nqcapa4psz';
  
  String? _accessToken;

  // 1. Twitch'ten Bilet (Token) Alma
  Future<void> _authenticate() async {
    if (_accessToken != null) return; // Zaten biletimiz varsa tekrar alma

    final url = Uri.parse(
        'https://id.twitch.tv/oauth2/token?client_id=$clientId&client_secret=$clientSecret&grant_type=client_credentials');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('IGDB Kimlik Doğrulaması Başarısız!');
    }
  }

  // 2. Popüler Oyunları Çekme (Top Rated)
  Future<List<Game>> getTopGames() async {
    await _authenticate(); // Önce kimliği doğrula

    final url = Uri.parse('https://api.igdb.com/v4/games');
    final response = await http.post(
      url,
      headers: {
        'Client-ID': clientId,
        'Authorization': 'Bearer $_accessToken',
        'Accept': 'application/json',
      },
      // IGDB'nin kendi sorgu dili (APICal). 
      // İsim ve kapak istiyoruz. En az 200 oy alan ve puanı en yüksek 18 oyunu çekiyoruz.
      body: 'fields name, cover.url; where rating_count > 200; sort rating desc; limit 18;',
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Oyunlar yüklenirken hata oluştu');
    }
  }
}