import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/like_provider.dart';
import '../utils/app_colors.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'ticket_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
    required this.username,
    required this.name,
    required this.email,
  });

  final String username;
  final String name;
  final String email;

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _ticketKey = GlobalKey<_TicketPlaceholderScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const ExploreScreen(),
      TicketPlaceholderScreen(key: _ticketKey),
      HomeScreen(
        onOpenFavorites: () {
          _ticketKey.currentState?.showFavorites();
          setState(() => _currentIndex = 1);
        },
      ),
      ProfileScreen(
        username: widget.username,
        name: widget.name,
        email: widget.email,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: AppColors.successLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Jelajah',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_num_outlined),
            selectedIcon: Icon(Icons.confirmation_num_rounded),
            label: 'Tiket Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco_rounded),
            label: 'Dampak',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HALAMAN TIKET SAYA (Tiket Aktif + Favorit)
// ============================================================
class TicketPlaceholderScreen extends StatefulWidget {
  const TicketPlaceholderScreen({super.key});

  @override
  State<TicketPlaceholderScreen> createState() =>
      _TicketPlaceholderScreenState();
}

class _TicketPlaceholderScreenState extends State<TicketPlaceholderScreen> {
  int _tab = 0;

  void showFavorites() => setState(() => _tab = 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tiket Saya',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: Row(
              children: [
                _TabBtn(
                  label: 'Tiket Aktif',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _TabBtn(
                  label: 'Favorit',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _tab == 0 ? const _TicketList() : const _FavoriteList(),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.mutedText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ===== TAB 1: TIKET AKTIF =====
class _TicketList extends StatelessWidget {
  const _TicketList();

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.checkoutItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.confirmation_num_outlined,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada tiket aktif',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Claim surprise box dari halaman Jelajah untuk melihat tiketmu di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              '${cart.checkoutItems.length} tiket aktif',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.mutedText,
                  ),
            ),
            const SizedBox(height: 12),
            ...cart.checkoutItems.map(
              (product) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.successLight,
                    child: const Icon(
                      Icons.confirmation_num_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${product.storeName}\nSiap diambil sesuai jadwal',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TicketScreen(product: product),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ===== TAB 2: FAVORIT =====
class _FavoriteList extends StatelessWidget {
  const _FavoriteList();

  @override
  Widget build(BuildContext context) {
    return Consumer<LikeProvider>(
      builder: (context, likeProvider, _) {
        final likedIds = likeProvider.likedProductIds();

        if (likedIds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada favorit',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap ikon ❤️ di produk untuk menyimpannya di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              '${likedIds.length} produk favorit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.mutedText,
                  ),
            ),
            const SizedBox(height: 12),
            ...likedIds.map((id) {
              final product = _findProduct(id);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: AppColors.successLight,
                        child: const Icon(
                          Icons.fastfood,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(product.storeName),
                  trailing: IconButton(
                    onPressed: () => likeProvider.toggleLike(product.id),
                    icon: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Product _findProduct(String id) {
    final all = [
      Product(
        id: 'box-001',
        name: 'Surprise Box Roti & Pastry',
        storeName: 'Kopi Senja',
        distance: 0.8,
        originalPrice: 75000,
        discountPrice: 25000,
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600',
        stock: 5,
        pickupStart: DateTime.now().add(const Duration(minutes: 45)),
        pickupEnd: DateTime.now().add(const Duration(hours: 2)),
        rating: 4.8,
        description: '',
        itemsInBag: const [],
      ),
      Product(
        id: 'box-002',
        name: 'Paket Nasi Ayam Hemat',
        storeName: 'Dapur Ibu Rina',
        distance: 1.2,
        originalPrice: 55000,
        discountPrice: 18000,
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',
        stock: 8,
        pickupStart: DateTime.now().add(const Duration(hours: 1)),
        pickupEnd: DateTime.now().add(const Duration(hours: 3)),
        rating: 4.6,
        description: '',
        itemsInBag: const [],
      ),
      Product(
        id: 'box-003',
        name: 'Fruit Bowl Segar',
        storeName: 'Green Market',
        distance: 1.8,
        originalPrice: 45000,
        discountPrice: 15000,
        imageUrl:
            'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=600',
        stock: 3,
        pickupStart: DateTime.now().add(const Duration(minutes: 30)),
        pickupEnd: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
        rating: 4.9,
        description: '',
        itemsInBag: const [],
      ),
    ];
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => all.first,
    );
  }
}
