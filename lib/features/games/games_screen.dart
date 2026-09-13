import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/game.dart';
import '../../core/services/igdb_service.dart';
import 'game_detail_screen.dart';


class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Discover Games',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
            onPressed: () {
              // TODO: Filtreleme menüsü eklenecek
            },
          )
        ],
      ),
      // AppBar'ın altındaki body kısmını komple bunula değiştiriyoruz:
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChips(),
          const SizedBox(height: 12),
          
          Expanded(
            child: FutureBuilder<List<Game>>(
              future: IGDBService().getTopGames(), // Servisi çağırdık
              builder: (context, snapshot) {
                // Yükleniyorsa dönen animasyon göster
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                }
                
                // Hata varsa ekrana yaz
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }

                // Veri başarıyla geldiyse grid içine diz
                final games = snapshot.data!;
                
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
  return _buildGameCard(context, games[index]); // context'i içeri yolladık
},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Yatay Filtreleme Seçenekleri
  Widget _buildFilterChips() {
    final filters = ['Top Rated', 'Most Played', 'New Releases', 'Coming Soon'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == 'Top Rated'; // Prototip için sadece ilkini seçili yapıyoruz
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (bool value) {},
              backgroundColor: AppColors.surfaceDark,
              selectedColor: AppColors.primaryBlue.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryBlue : AppColors.surfaceDarker,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Oyun Kapağı Tasarımı
  // Güncellenmiş Oyun Kapağı Tasarımı
  // Başlıktaki parametreye BuildContext context eklendi
  Widget _buildGameCard(BuildContext context, Game game) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context, // Artık bu context tanınıyor
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
  }
}