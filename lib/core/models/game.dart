class Game {
  final int id;
  final String name;
  final String coverUrl;

  Game({
    required this.id,
    required this.name,
    required this.coverUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    // IGDB kapak URL'leri varsayılan olarak "t_thumb" (çok küçük) gelir. 
    // Bunu "t_cover_big" ile değiştirip yüksek çözünürlüklü kapaklar alıyoruz.
    String url = 'https://picsum.photos/seed/${json['id']}/150/210'; // Hata olursa yedek görsel
    
    if (json['cover'] != null && json['cover']['url'] != null) {
      String rawUrl = json['cover']['url'] as String;
      url = 'https:${rawUrl.replaceAll('t_thumb', 't_cover_big')}';
    }

    return Game(
      id: json['id'],
      name: json['name'],
      coverUrl: url,
    );
  }
}