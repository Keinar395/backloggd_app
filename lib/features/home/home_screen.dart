import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<Map<String, dynamic>> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = _fetchHomeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Kullanıcı ve log verilerini çeken fonksiyon
  Future<Map<String, dynamic>> _fetchHomeData() async {
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
        .eq('user_id', user.id);

    return {
      'username': profileData['username'] ?? 'Unknown',
      'logs': logsData as List<dynamic>,
    };
  }

  // Arama tuşuna basıldığında çalışacak fonksiyon
  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    
    // Aramayı tetikleyip yeni ekrana geçiş yapıyoruz
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(query: query),
      ),
    );
    
    _searchController.clear();
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceDarker,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search, // Klavyede "Ara" butonu çıkartır
            onSubmitted: _onSearchSubmitted, // Enter'a basılınca tetiklenir
            decoration: const InputDecoration(
              hintText: 'Search games, users, lists...',
              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        // Sağ üstteki gereksiz profil ikonu kaldırıldı
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE94264)));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!;
          final String username = data['username'];
          final List<dynamic> logs = data['logs'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dinamik Karşılama Ekranı
                  _buildWelcomeSection(username, logs),
                  const SizedBox(height: 24),
                  
                  // Mock verilerle kalan alt bölümler
                  const GameCarouselSection(title: 'Recently Trending'),
                  const SizedBox(height: 24),
                  const PopularReviewsSection(),
                  const SizedBox(height: 24),
                  const GameCarouselSection(title: 'Coming Soon'),
                  const SizedBox(height: 24),
                  const GameCarouselSection(title: 'Recently Anticipated'),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Dinamik istatistikleri ve ismi işleyen bölüm
  Widget _buildWelcomeSection(String username, List<dynamic> logs) {
    // Veritabanından gelen listeyi durumlara göre filtreleyip sayısını alıyoruz
    final playedCount = logs.where((l) => l['status'] == 'Played').length;
    final playingCount = logs.where((l) => l['status'] == 'Playing').length;
    final backlogCount = logs.where((l) => l['status'] == 'Backlog').length;
    final wishlistCount = logs.where((l) => l['status'] == 'Wishlist').length;
    final reviewCount = logs.where((l) => l['review_text'] != null && l['review_text'].toString().trim().isNotEmpty).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Welcome back ', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            CircleAvatar(
              radius: 10,
              backgroundImage: NetworkImage('https://picsum.photos/seed/$username/20/20'), 
            ),
            const SizedBox(width: 6),
            Text(username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const Text(', your collection awaits...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 32),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Played', playedCount.toString()),
                        _buildStatItem('Playing', playingCount.toString()),
                        _buildStatItem('Reviews', reviewCount.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Backlog', backlogCount.toString()),
                        _buildStatItem('Wishlist', wishlistCount.toString()),
                        _buildStatItem('Lists', '0'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Profile Stats', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildRatingsChart() {
    final List<double> heights = [4, 6, 8, 12, 18, 14, 30, 40, 10, 6]; 
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: heights.map((h) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 8, 
          height: h, 
          decoration: BoxDecoration(
            color: const Color(0xFFE94264), // Orijinal pembeye güncelledim
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}

// ----------------------------------------------------
// Mock (Statik) Bölümler Aşağıda Aynen Korunmuştur
// ----------------------------------------------------

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