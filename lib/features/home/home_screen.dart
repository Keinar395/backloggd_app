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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              
              const GameCarouselSection(title: 'Recently Trending'),
              const SizedBox(height: 24),
              
              // Yeni eklediğimiz Popüler İncelemeler kısmı
              const PopularReviewsSection(),
              const SizedBox(height: 24),
              
              const GameCarouselSection(title: 'Coming Soon'),
              const SizedBox(height: 24),
              const GameCarouselSection(title: 'Recently Anticipated'),
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Karşılama Metni (Ekrana sığması için Wrap kullanıyoruz)
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Text('Welcome back ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage('https://picsum.photos/seed/keinar/20/20'), // Örnek avatar
            ),
            SizedBox(width: 6),
            Text('Keinar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(', your collection awaits...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 32),

        // 2. İstatistikler ve Derecelendirme Grafiği
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sol Taraf: İstatistikler Izgarası
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Played', '138'),
                        _buildStatItem('Playing', '5'),
                        _buildStatItem('Reviews', '17'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Backlog', '0'),
                        _buildStatItem('Wishlist', '0'),
                        _buildStatItem('Lists', '0'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Profile Stats', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              
              // Sağ Taraf: Bar Grafiği
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildRatingsChart(),
                    const SizedBox(height: 8),
                    const Text('Game Ratings', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sitedeki ince fontlu ve sade istatistik tasarımı
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
      ],
    );
  }

  // Masaüstündeki o meşhur pembe grafik
  Widget _buildRatingsChart() {
    // 1-5 yıldız arası 10 bar için rastgele yükseklikler (resimdeki görünüme benzer)
    final List<double> heights = [4, 6, 8, 12, 18, 14, 30, 40, 10, 6]; 
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((h) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 8, // Barların genişliği
          height: h, // Barların yüksekliği
          decoration: BoxDecoration(
            color: const Color(0xFFE24379), // Backloggd'nin kendi grafik pembesi
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

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

// Güncellenmiş Yatay Oyun Listesi (Artık rastgele resim çekiyor)
class GameCarouselSection extends StatelessWidget {
  final String title;

  const GameCarouselSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        SizedBox(
          height: 150, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: 6, 
            itemBuilder: (context, index) {
              return Container(
                width: 105, 
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarker,
                  borderRadius: BorderRadius.circular(8),
                  // Rastgele oyun kapakları hissi vermesi için Picsum'dan resim çekiyoruz
                  image: DecorationImage(
                    image: NetworkImage('https://picsum.photos/seed/${title.length + index}/105/150'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Yeni: Popüler İncelemeler Bölümü
class PopularReviewsSection extends StatelessWidget {
  const PopularReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Popular Reviews',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        // Şimdilik 2 tane alt alta inceleme kartı gösterelim
        _buildReviewCard('Körkütük Fan', '10/10 masterclass in storytelling. The gameplay loop is addictive and the soundtrack is beautiful.', 5),
        const SizedBox(height: 8),
        _buildReviewCard('IndieGamer', 'A bit repetitive towards the end, but the art style kept me engaged throughout.', 4),
      ],
    );
  }

  Widget _buildReviewCard(String username, String reviewText, int stars) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İnceleme yapılan oyunun küçük kapağı
          Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/$username/50/70'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Kullanıcı bilgisi ve yorum
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(username, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5, 
                        (index) => Icon(
                          Icons.star, 
                          size: 14, 
                          color: index < stars ? AppColors.statusWishlist : AppColors.surfaceDarker
                        )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  reviewText,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis, // Çok uzunsa sonuna ... koyar
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}