import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Activity',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.surfaceDarker, height: 1.0), // İnce alt çizgi
        ),
      ),
      // Akış listesi
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: 4, // Prototip için 4 adet statik akış kartı
        itemBuilder: (context, index) {
          // İnceleme (Review) ve Loglama (Log) durumlarını karışık gösteriyoruz
          final activities = [
            _buildReviewActivity('Kerem', 'Outer Wilds', 'A masterpiece of exploration. Every discovery feels earned and the soundtrack is phenomenal.', 5, '2h ago'),
            _buildLogActivity('Ömer', 'Hollow Knight', 'Playing', '5h ago'),
            _buildReviewActivity('Erman', 'Elden Ring', 'Tough but fair. The open world is incredible.', 4, '1d ago'),
            _buildLogActivity('Kerem', 'Celeste', 'Played', '2d ago'),
          ];
          return activities[index];
        },
      ),
    );
  }

  // İnceleme (Review) Kartı Şablonu
  Widget _buildReviewActivity(String username, String gameName, String review, int rating, String time) {
    return _buildBaseActivityCard(
      username: username,
      action: 'reviewed',
      gameName: gameName,
      time: time,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) => Icon(
              Icons.star,
              size: 16,
              color: index < rating ? AppColors.statusWishlist : AppColors.surfaceDarker,
            )),
          ),
          const SizedBox(height: 8),
          Text(review, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  // Log (Oyun Ekleme) Kartı Şablonu
  Widget _buildLogActivity(String username, String gameName, String status, String time) {
    Color statusColor = status == 'Playing' ? AppColors.statusPlaying : AppColors.statusPlayed;
    
    return _buildBaseActivityCard(
      username: username,
      action: 'logged',
      gameName: gameName,
      time: time,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Akış Kartlarının Ana İskeleti (Avatar, İsim, Tarih, Kapak)
  Widget _buildBaseActivityCard({
    required String username,
    required String action,
    required String gameName,
    required String time,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceDarker),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil Resmi
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://picsum.photos/seed/$username/40/40'),
          ),
          const SizedBox(width: 12),
          
          // Orta Kısım: Kim ne yaptı + İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          children: [
                            TextSpan(text: username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' $action '),
                            TextSpan(text: gameName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                content, // Yukarıdan gelen Review veya Log detayı
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Sağ Kısım: Oyun Kapağı
          Container(
            width: 45,
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/seed/$gameName/45/65'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}