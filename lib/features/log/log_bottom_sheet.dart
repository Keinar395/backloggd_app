import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/game.dart';
import '../../core/services/igdb_service.dart';
import '../../core/services/log_service.dart';

class LogBottomSheet extends StatefulWidget {
  const LogBottomSheet({super.key});

  @override
  State<LogBottomSheet> createState() => _LogBottomSheetState();
}

class _LogBottomSheetState extends State<LogBottomSheet> {
  final Color backloggdPink = const Color(0xFFE94264);

  // --- Arama (Search) State Değişkenleri ---
  final TextEditingController _searchController = TextEditingController();
  List<Game> _searchResults = [];
  bool _isSearching = false;
  String _searchError = '';

  // --- Loglama (Review) State Değişkenleri ---
  Game? _selectedGame; // Seçili oyun yoksa Arama ekranı, varsa Log ekranı gösterilir
  String _selectedStatus = 'Played';
  int _rating = 0;
  bool _isFavorite = false;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  // 1. Oyun Arama Fonksiyonu
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isSearching = true;
      _searchError = '';
    });

    try {
      final results = await IGDBService().searchGames(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchError = 'Arama başarısız oldu. Tekrar deneyin.';
        _isSearching = false;
      });
    }
  }

  // 2. Veritabanına Kaydetme Fonksiyonu
  Future<void> _saveLog() async {
    if (_selectedGame == null) return;
    setState(() => _isSaving = true);

    try {
      await LogService().logGame(
        game: _selectedGame!,
        status: _selectedStatus,
        isFavorite: _isFavorite,
        rating: _rating,
        reviewText: _reviewController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // İşlem bitince pencereyi kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedGame!.name} logged!'), backgroundColor: backloggdPink),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hata oluştu!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    // Ekranın %85'ini kaplayacak şekilde sınırlandırıyoruz ki liste rahatça kaysın
    final maxHeight = MediaQuery.of(context).size.height * 0.85; 

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPadding + 16),
        decoration: const BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Üstteki gri kaydırma çubuğu
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.surfaceDarker, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),

            // İçerik: Eğer oyun seçildiyse Log ekranını, seçilmediyse Arama ekranını göster
            Expanded(
              child: _selectedGame == null ? _buildSearchView() : _buildLogView(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // BÖLÜM 1: ARAMA ARAYÜZÜ (SEARCH VIEW)
  // ==========================================
  Widget _buildSearchView() {
    return Column(
      children: [
        const Text('Log a Game', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Arama Kutusu
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceDarker),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch, // Klavyeden Enter'a basınca ara
            decoration: const InputDecoration(
              hintText: 'Type a game name...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Arama Sonuçları Listesi
        Expanded(
          child: _isSearching
              ? Center(child: CircularProgressIndicator(color: backloggdPink))
              : _searchError.isNotEmpty
                  ? Center(child: Text(_searchError, style: const TextStyle(color: Colors.red)))
                  : _searchResults.isEmpty
                      ? const Center(child: Text('Search for a game to log.', style: TextStyle(color: AppColors.textSecondary)))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final game = _searchResults[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(game.coverUrl, width: 40, height: 56, fit: BoxFit.cover),
                              ),
                              title: Text(game.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              onTap: () {
                                // Oyuna tıklanınca state'i güncelle ve Log ekranına geç
                                setState(() {
                                  _selectedGame = game;
                                });
                              },
                            );
                          },
                        ),
        ),
      ],
    );
  }

  // ==========================================
  // BÖLÜM 2: LOGLAMA ARAYÜZÜ (LOG VIEW - Resim 3 Klonu)
  // ==========================================
  Widget _buildLogView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Geri Dönüş ve Başlık
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
              onPressed: () => setState(() => _selectedGame = null), // Aramaya geri dön
            ),
            Expanded(
              child: Text(
                _selectedGame!.name,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SOL KOLON: Kapak, Durum Butonları ve Kalp
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(_selectedGame!.coverUrl, width: 90, height: 130, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 12),
                      
                      // Durum Butonları (Sitedeki dikey liste mantığı)
                      _buildStatusButton('Played', AppColors.statusPlayed, Icons.check_circle),
                      _buildStatusButton('Playing', AppColors.statusPlaying, Icons.sports_esports),
                      _buildStatusButton('Backlog', AppColors.statusBacklog, Icons.schedule),
                      _buildStatusButton('Wishlist', AppColors.statusWishlist, Icons.card_giftcard),
                      
                      const SizedBox(height: 12),
                      // Like (Favori) Kalp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Like ', style: TextStyle(color: Colors.white, fontSize: 12)),
                          GestureDetector(
                            onTap: () => setState(() => _isFavorite = !_isFavorite),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? backloggdPink : AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // SAĞ KOLON: Puanlama ve İnceleme Metni
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rating', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => _rating = index + 1),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: index < _rating ? backloggdPink : AppColors.textSecondary,
                              size: 28,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      const Text('Review', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceDarker),
                        ),
                        child: TextField(
                          controller: _reviewController,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'What did you think...',
                            hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // İptal ve Kaydet Butonları (Sağ Alta Hizalı)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveLog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backloggdPink, // Orijinal Sitedeki Pembe Kaydet Butonu
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            child: _isSaving 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Create Log', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Dikey Durum Butonu Tasarımı (Sitedeki gibi dar ve alt alta)
  Widget _buildStatusButton(String label, Color color, IconData icon) {
    final isSelected = _selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? color.withOpacity(0.5) : AppColors.surfaceDarker),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? color : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              label, 
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary, 
                fontSize: 11, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              )
            ),
          ],
        ),
      ),
    );
  }
}