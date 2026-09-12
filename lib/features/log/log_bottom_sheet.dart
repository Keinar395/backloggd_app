import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LogBottomSheet extends StatelessWidget {
  const LogBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Klavyenin ekranı itmesi için alt kısımdaki boşluğu (viewInsets) hesaplıyoruz
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPadding + 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar yer kaplasın
        children: [
          // En üstteki küçük kaydırma çubuğu (Drag handle)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceDarker,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Başlık
          const Text(
            'Log a Game',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Arama Çubuğu
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
            ),
            child: const TextField(
              autofocus: true, // Menü açılınca klavye otomatik gelsin
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a game name...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.primaryBlue),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Örnek Arama Sonucu ve Durum Butonları (Prototip için statik)
          _buildMockSearchResult(),
        ],
      ),
    );
  }

  Widget _buildMockSearchResult() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Oyun Bilgisi
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  'https://picsum.photos/seed/hotlinemiami/50/70', // Temsili kapak
                  width: 40,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hotline Miami', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('2012 • Dennaton Games', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Loglama Durum Butonları
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip('Played', AppColors.statusPlayed, Icons.check_circle),
              _buildStatusChip('Playing', AppColors.statusPlaying, Icons.sports_esports),
              _buildStatusChip('Backlog', AppColors.statusBacklog, Icons.schedule),
              _buildStatusChip('Wishlist', AppColors.statusWishlist, Icons.card_giftcard),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color, IconData icon) {
    return InkWell(
      onTap: () {}, // Gerçek uygulamada burada API isteği atılacak
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}