import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color backloggdPink = const Color(0xFFE94264);
  
  // Hangi ana sekmede olduğumuzu tutan değişken
  String _activeTab = 'Profile'; 
  
  // Veriyi her sekme değişiminde tekrar çekmemek için hafızaya alıyoruz
  late Future<Map<String, dynamic>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  Future<Map<String, dynamic>> _fetchProfileData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) throw Exception('User not logged in');

    final profileData = await supabase
        .from('profiles')
        .select('username')
        .eq('id', user.id)
        .single();

    final logsData = await supabase
        .from('user_logs')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return {
      'username': profileData['username'] ?? 'Unknown',
      'logs': logsData as List<dynamic>,
    };
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Backloggd', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings page coming soon!')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: backloggdPink));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!;
          final String username = data['username'];
          final List<dynamic> allLogs = data['logs'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, username),
                _buildNavigationTabs(),
                const Divider(color: AppColors.surfaceDarker, height: 1),
                
                // Seçili sekmeye göre alt içeriği yüklüyoruz
                _buildTabContent(allLogs),
              ],
            ),
          );
        },
      ),
    );
  }

  // Dinamik Sekme İçeriği Yükleyici
  Widget _buildTabContent(List<dynamic> allLogs) {
    switch (_activeTab) {
      case 'Profile':
        return _buildProfileTabContent(allLogs);
      case 'Games':
        return _GamesTabContent(logs: allLogs); // Oyunlar için özel Stateful yapı
      default:
        // Journal, Activity, Reviews vs. için Mock Görünüm
        return _buildMockTabContent(_activeTab);
    }
  }

  // 1. Profil Sekmesinin Orijinal İçeriği (Eski kodlar buraya taşındı)
  Widget _buildProfileTabContent(List<dynamic> allLogs) {
    final playedLogs = allLogs.where((log) => log['status'] == 'Played').toList();
    final wishlistLogs = allLogs.where((log) => log['status'] == 'Wishlist').toList();
    final favoriteLogs = allLogs.where((log) => log['is_favorite'] == true).toList();
    final reviewedLogs = allLogs.where((log) => log['review_text'] != null && log['review_text'].toString().trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBioAndRatings(),
          const SizedBox(height: 32),
          
          Center(child: Text('Favorite Games', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
          const SizedBox(height: 16),
          _buildFavoriteGames(favoriteLogs),
          const SizedBox(height: 40),

          _buildBigStats(
            gamesPlayed: allLogs.length.toString(),
            playedThisYear: playedLogs.length.toString(),
            backloggd: wishlistLogs.length.toString(),
          ),
          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recently Reviewed', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('View All', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          _buildRecentlyReviewed(reviewedLogs),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Diğer Sekmeler İçin Hazırlık (Mock) Görünümü
  Widget _buildMockTabContent(String tabName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 16.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.construction, color: AppColors.textSecondary.withOpacity(0.5), size: 48),
            const SizedBox(height: 16),
            Text(
              '$tabName content is under construction.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String username) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network('https://picsum.photos/seed/$username/90/90', width: 90, height: 90, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity, 
                  child: OutlinedButton(
                    onPressed: () {}, // Edit Profile mantığı aynı bırakıldı, kalabalık etmesin diye kısalttım (önceki kodunla değiştirebilirsin)
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.surfaceDarker),
                      backgroundColor: AppColors.surfaceDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tıklanabilir Navigasyon Sekmeleri
  Widget _buildNavigationTabs() {
    final tabs = ['Profile', 'Games', 'Journal', 'Activity', 'Reviews', 'Lists', 'Friends', 'Likes'];
    return Container(
      width: double.infinity,
      color: AppColors.surfaceDark,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: tabs.map((tab) {
            final isActive = tab == _activeTab;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _activeTab = tab; // Tıklanan sekmeyi aktif yap ve ekranı yenile
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isActive ? backloggdPink : Colors.transparent, width: 2)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Önceki yardımcı widget'lar (Bio, Stats, Favorite, Recent) olduğu gibi korundu ---
  // 3. Bio ve Kişisel Puan Grafiği
  Widget _buildBioAndRatings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bio', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        const Text('Nothing here yet...', style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic)),
        const SizedBox(height: 24),
        
        const Text('Personal Ratings', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildRatingBar(10), _buildRatingBar(15), _buildRatingBar(20),
            _buildRatingBar(35), _buildRatingBar(80), _buildRatingBar(45),
            _buildRatingBar(90), _buildRatingBar(60), _buildRatingBar(25), _buildRatingBar(10),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('1★', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            Text('5★', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildRatingBar(double height) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        height: height,
        color: backloggdPink,
      ),
    );
  }

  // 4. Gerçek Favori Oyunlar 
  Widget _buildFavoriteGames(List<dynamic> logs) {
    final displayLogs = logs.take(4).toList();
    if (displayLogs.isEmpty) return const Center(child: Text('No favorites yet.', style: TextStyle(color: AppColors.textSecondary)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: displayLogs.map((log) {
          return Container(
            width: 100,
            height: 140,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.surfaceDarker),
              image: DecorationImage(
                image: NetworkImage(log['cover_url']),
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 5. Devasa İstatistik Rakamları
  Widget _buildBigStats({required String gamesPlayed, required String playedThisYear, required String backloggd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBigStatItem(gamesPlayed, 'Games Played'),
        _buildBigStatItem(playedThisYear, 'Played in 2026'),
        _buildBigStatItem(backloggd, 'Games Backloggd'),
      ],
    );
  }

  Widget _buildBigStatItem(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // 6. Gerçek Son İncelemeler
  Widget _buildRecentlyReviewed(List<dynamic> logs) {
    if (logs.isEmpty) return const Text('No recent reviews.', style: TextStyle(color: AppColors.textSecondary));

    final reviewLog = logs.first;
    final int rating = reviewLog['rating'] ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceDarker),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Oyun Kapağı
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(reviewLog['cover_url'], width: 60, height: 85, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          // İnceleme Detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reviewLog['game_name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Gerçek Yıldız Puanı
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < rating ? Icons.star : Icons.star_border, 
                        color: index < rating ? backloggdPink : AppColors.textSecondary, 
                        size: 14
                      )),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(reviewLog['status'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                // Gerçek İnceleme Metni
                Text(
                  reviewLog['review_text'],
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// GAMES SEKMESİ ÖZEL İÇERİĞİ (Alt filtrelerle birlikte)
// ----------------------------------------------------------------------
class _GamesTabContent extends StatefulWidget {
  final List<dynamic> logs;
  const _GamesTabContent({required this.logs});

  @override
  State<_GamesTabContent> createState() => _GamesTabContentState();
}

class _GamesTabContentState extends State<_GamesTabContent> {
  String _activeFilter = 'Played'; // Varsayılan filtre
  final List<String> _filters = ['Played', 'Playing', 'Backlog', 'Wishlist'];

  @override
  Widget build(BuildContext context) {
    // Seçili filtreye göre oyunları ayıkla
    final filteredLogs = widget.logs.where((log) {
      if (_activeFilter == 'Backlog') return log['status'] == 'Backlog'; // Eğer DB'de Backlog kullanmıyorsan boş gelir, sorun değil
      return log['status'] == _activeFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alt Filtre Menüsü (Played, Playing vs.)
          Row(
            children: _filters.map((filter) {
              final isActive = _activeFilter == filter;
              return GestureDetector(
                onTap: () => setState(() => _activeFilter = filter),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // Izgara (Grid) Oyun Görünümü
          if (filteredLogs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Center(child: Text('No games in this list yet.', style: TextStyle(color: AppColors.textSecondary))),
            )
          else
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // Scroll işlemini dıştaki ana sayfa hallediyor
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // Telefondaki grid için 4'lü yapı
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredLogs.length,
              itemBuilder: (context, index) {
                final log = filteredLogs[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.surfaceDarker),
                    image: DecorationImage(
                      image: NetworkImage(log['cover_url']),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}