import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../log/log_bottom_sheet.dart';
import '../games/games_screen.dart';
import '../activity/activity_screen.dart';
import '../profile/profile_screen.dart';


class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  // Sayfa değiştikçe gösterilecek ekranlar listesi
  final List<Widget> _screens = [
    const HomeScreen(),
    const GamesScreen(),
    // Ortadaki FAB için boş bir index bırakıyoruz (index 2)
    const SizedBox.shrink(), 
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sayfa içeriği
      body: _screens[_currentIndex],
      
      // Merkezdeki Log Butonu (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Bottom Sheet'i tetikleyen kod
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Klavye açıldığında yukarı kayabilmesi için gerekli
            backgroundColor: Colors.transparent, // Köşelerin yuvarlak görünmesi için
            builder: (context) => const LogBottomSheet(),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      // FAB'ı alt barın tam ortasına oturtma
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Alt Bar
      bottomNavigationBar: Theme(
        // Tıklama animasyonu (splash) rengini şeffaf yaparak daha modern bir his veriyoruz
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Ortadaki (index 2) log tuşuna basılınca sayfa değişmemesi için kontrol
            if (index != 2) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: AppColors.surfaceDark,
          type: BottomNavigationBarType.fixed, // İkonların hareket etmemesi için
          selectedItemColor: Colors.white,
          unselectedItemColor: AppColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Games'),
            // FAB'ın altındaki boşluk için görünmez bir item
            BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: 'Log'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Activity'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}