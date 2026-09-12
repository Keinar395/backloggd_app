import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceDarker,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search games, users, lists...',
              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
          )
        ],
      ),
      // Tüm sayfanın aşağı kaydırılabilir olması için
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              
              // Tekrar kullanılabilir (reusable) yatay liste widget'larımız
              const GameCarouselSection(title: 'Recently Trending'),
              const SizedBox(height: 24),
              
              // TODO: Buraya Popular Reviews ve Latest News eklenecek
              
              const GameCarouselSection(title: 'Coming Soon'),
              const SizedBox(height: 24),
              const GameCarouselSection(title: 'Recently Anticipated'),
              const SizedBox(height: 24),
              const GameCarouselSection(title: 'Sleeper Hits'),
              const SizedBox(height: 40), // En altta biraz boşluk bırakalım
            ],
          ),
        ),
      ),
    );
  }

  // Karşılama Kartı Widget'ı
  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceDarker, width: 1),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.statusPlayed,
              child: Text('EA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, Ege',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStatBadge('248', 'Games'),
                      const SizedBox(width: 12),
                      _buildStatBadge('42', 'Reviews'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Karşılama kartının içindeki ufak istatistik rozetleri
  Widget _buildStatBadge(String number, String label) {
    return Row(
      children: [
        Text(number, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

// Yana kaydırılabilir oyun listesi (Reusable Component)
class GameCarouselSection extends StatelessWidget {
  final String title;

  const GameCarouselSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık ve "See More" kısmı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                'More',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Yatay kaydırılabilir liste
        SizedBox(
          height: 150, // Oyun kapaklarının yüksekliği
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: 6, // Şimdilik sahte 6 oyun
            itemBuilder: (context, index) {
              return Container(
                width: 105, // Oyun kapaklarının genişliği (Backloggd oranlarına yakın)
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarker,
                  borderRadius: BorderRadius.circular(8),
                ),
                // İleride buraya ağdan (network) görsel çeken kod gelecek
                child: const Center(
                  child: Icon(Icons.image_not_supported, color: AppColors.textSecondary, size: 32),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}