import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/game.dart';
import '../../core/services/igdb_service.dart';
import '../games/game_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text('Search: "$query"', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Game>>(
        future: IGDBService().searchGames(query), // Yazdığımız servisi çağırdık
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE94264)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final games = snapshot.data!;
          
          if (games.isEmpty) {
            return const Center(child: Text('No games found.', style: TextStyle(color: AppColors.textSecondary)));
          }

          // Sonuçları Games sayfasındaki gibi ızgara halinde basıyoruz
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return InkWell(
                onTap: () {
                  // Oyuna tıklanınca Detay Sayfasına git
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameDetailScreen(game: game),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDarker,
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(game.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}