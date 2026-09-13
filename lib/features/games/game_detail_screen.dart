import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/game.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // Üst Kısım: Büyük Kapak ve Geri Dönüş Butonu
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Arka plan için bulanıklaştırılmış veya büyük kapak
                  Image.network(
                    game.coverUrl,
                    fit: BoxFit.cover,
                  ),
                  // Üstüne koyu bir gradyan (yazıların okunması için)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.backgroundDark],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İçerik Kısmı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Oyun Adı
                  Text(
                    game.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hızlı Loglama Durum Butonları (Played, Playing, Wishlist)
                  const Text(
                    'Log Status',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusButtons(context),
                  const SizedBox(height: 24),

                  // Puanlama ve İnceleme Alanı Başlığı
                  const Text(
                    'Your Review & Rating',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // İnceleme Kutusu (Placeholder)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceDarker),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Write a review...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        SizedBox(height: 32),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Save Review',
                            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Durum Seçme Butonları (Played, Playing, Backlog, Wishlist)
  Widget _buildStatusButtons(BuildContext context) {
    final statuses = [
      {'label': 'Played', 'color': AppColors.statusPlayed},
      {'label': 'Playing', 'color': AppColors.statusPlaying},
      {'label': 'Wishlist', 'color': AppColors.statusWishlist},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        final color = status['color'] as Color;
        final label = status['label'] as String;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () {
                // TODO: Supabase 'user_logs' tablosuna kayıt atılacak
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${game.name} -> $label olarak işaretlendi!')),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}