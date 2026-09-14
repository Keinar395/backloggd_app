import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/game.dart';
import '../../core/services/log_service.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({super.key, required this.game});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  // Backloggd Pembe Rengi
  final Color backloggdPink = const Color(0xFFE94264);
  
  // Ekrandaki verileri tutacağımız değişkenler
  bool _isFavorite = false;
  int _rating = 0;
  String _selectedStatus = 'Played'; // Varsayılan durum
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // Veritabanına Kaydetme Fonksiyonu
  Future<void> _saveLog() async {
    try {
      await LogService().logGame(
        game: widget.game,
        status: _selectedStatus,
        isFavorite: _isFavorite,
        rating: _rating,
        reviewText: _reviewController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.game.name} log saved successfully!'),
            backgroundColor: backloggdPink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // Üst Kısım: Büyük Kapak ve Favori Butonu
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Favori (Kalp) Butonu
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? backloggdPink : Colors.white,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.game.coverUrl,
                    fit: BoxFit.cover,
                  ),
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
                  Text(
                    widget.game.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Log Status',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusButtons(),
                  const SizedBox(height: 32),

                  const Text(
                    'Your Review & Rating',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  // İnceleme ve Puanlama Kutusu
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceDarker),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Yıldız Puanlama
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rating = index + 1; // 1 ile 5 arası puan
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(
                                  index < _rating ? Icons.star : Icons.star_border,
                                  color: index < _rating ? backloggdPink : AppColors.textSecondary,
                                  size: 32,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16),
                        
                        // Metin Girişi
                        TextField(
                          controller: _reviewController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Write a review...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Kaydetme Butonu
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _saveLog,
                            child: Text(
                              'Save Log',
                              style: TextStyle(color: backloggdPink, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Alt kısımdan boşluk
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Durum Seçme Butonları (Stateful yapıya uygun güncellendi)
  Widget _buildStatusButtons() {
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
        final isSelected = _selectedStatus == label;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = label;
                });
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                side: BorderSide(color: isSelected ? color : AppColors.surfaceDarker, width: isSelected ? 2 : 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textSecondary, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                  fontSize: 13
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}