import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  late final List<Product> _products = [
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
        description:
            'Kombinasi roti dan pastry pilihan yang masih sangat lezat untuk dinikmati hari ini.',
        itemsInBag: ['Croissant butter', 'Roti cokelat', 'Donat gula']),
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
        description:
            'Menu rumahan hangat yang dibuat segar dan siap menjadi makan malam praktis.',
        itemsInBag: ['Nasi putih', 'Ayam bumbu', 'Tumis sayur']),
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
        description: 'Buah potong segar dengan pilihan musiman dari toko lokal.',
        itemsInBag: ['Melon', 'Semangka', 'Pepaya']),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.toLowerCase();
    return _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(query) ||
          product.storeName.toLowerCase().contains(query);
      final matchesFilter = switch (_selectedFilter) {
        'Ending Soon' =>
          product.pickupEnd.difference(DateTime.now()).inHours < 2,
        '<1.5km' => product.distance < 1.5,
        '<25rb' => product.discountPrice < 25000,
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _openDetail(Product product) => Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mau makan apa hari ini?',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(height: 5),
                            Row(children: [
                              Icon(Icons.location_on_rounded,
                                  color: Colors.white70, size: 16),
                              SizedBox(width: 4),
                              Text('Jakarta Selatan',
                                  style: TextStyle(color: Colors.white70))
                            ]),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_none_rounded,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari makanan atau toko...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.primary),
                      suffixIcon: _searchController.text.isEmpty
                          ? const Icon(Icons.tune_rounded,
                              color: AppColors.mutedText)
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                              icon: const Icon(Icons.close_rounded)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Semua', 'Ending Soon', '<1.5km', '<25rb']
                    .map((filter) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (_) =>
                                setState(() => _selectedFilter = filter))))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 25),
                const SizedBox(width: 9),
                const Expanded(
                    child: Text('Penyelamatan Kilat Hari Ini!',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800))),
                CountdownTimer(
                    endTime: DateTime.now().add(const Duration(minutes: 45)),
                    compact: true)
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 23, 20, 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rekomendasi untukmu',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text('${_filteredProducts.length} box',
                      style: const TextStyle(color: AppColors.mutedText))
                ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
                children: _filteredProducts
                    .map((product) => ProductCard(
                        product: product,
                        onTap: () => _openDetail(product),
                        onSave: () {
                          context.read<CartProvider>().addToCart(product);
                          _openDetail(product);
                        }))
                    .toList()),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}