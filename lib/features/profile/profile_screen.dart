import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          // Çıkış Yapma Butonu
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.statusPlayed),
            onPressed: () async {
              await authService.signOut();
              // Çıkış yapınca AuthGate otomatik olarak bizi Login'e atacaktır.
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildFavoriteGames(),
            const SizedBox(height: 24),
            _buildProfileStats(),
          ],
        ),
      ),
    );
  }

  // Üst Kısım: Avatar, İsim ve Bio
  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage('https://picsum.photos/seed/ege/80/80'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ege', 
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 4),
        const Text(
          '@egeaydin', 
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14)
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: const BorderSide(color: AppColors.surfaceDarker),
          ),
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  // Favori Oyunlar Bölümü (Backloggd Tarzı Yan Yana 4 Oyun)
  Widget _buildFavoriteGames() {
    // Prototipte tanıdık hissettirmesi için statik kapak isimleri
    final favoriteGames = ['Warframe', 'Minecraft', 'GTASanAndreas', 'RDR2'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Favorite Games', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: favoriteGames.map((gameName) {
              return Container(
                width: 75,
                height: 105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: NetworkImage('https://picsum.photos/seed/$gameName/75/105'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Alt İstatistikler
  Widget _buildProfileStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDarker),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Games', '138'),
              _buildStatItem('Reviews', '17'),
              _buildStatItem('Lists', '3'),
              _buildStatItem('Followers', '42'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}