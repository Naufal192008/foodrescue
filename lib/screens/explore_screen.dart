import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../admin/services/admin_data_service.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/countdown_timer.dart';
import 'nutrition_analysis_screen.dart';
import 'product_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getFoods();
    if (mounted) {
      setState(() {
        if (data.isNotEmpty) {
          AdminDataService().replaceProducts(
            data.map((e) => Product.fromJson(e)),
          );
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filteredProducts(List<Product> products) {
    final query = _searchController.text.toLowerCase();
    return products.where((product) {
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
    final catalog = context.watch<AdminDataService>();
    final filteredProducts = _filteredProducts(catalog.products);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProducts,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildFlashDrop(),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'DAMPAK EKOLOGIS',
                      value: '14.8',
                      suffix: 'kg',
                      caption: 'CO2e terhindar',
                      color: AppColors.primaryDark,
                      icon: Icons.eco_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _MetricCard(
                      title: 'EFISIENSI PORTOFOLIO',
                      value: 'Rp 148.500',
                      caption: 'Penghematan bulan ini',
                      color: Colors.white,
                      icon: Icons.account_balance_wallet_outlined,
                      darkText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.bolt_rounded,
                      color: AppColors.secondary, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Peluang Penyelamatan Aktif',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  Text('${filteredProducts.length} BATCH\nTERDEKAT',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Tidak ada makanan tersedia')),
                )
              else
                ...filteredProducts.map((product) => _ExploreProductCard(
                      product: product,
                      onTap: () => _openDetail(product),
                      onSave: () {
                        context.read<CartProvider>().addToCart(product);
                        _openDetail(product);
                      },
                    )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NutritionAnalysisScreen(
              product: filteredProducts.isEmpty ? null : filteredProducts.first,
            ),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Analisis nutrisi dengan Gemini',
        child: const Icon(Icons.auto_awesome_rounded),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Color(0x12000000), blurRadius: 8)
            ],
          ),
          child: Image.asset('assets/logo.jpeg', fit: BoxFit.contain),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RESCUE OS',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800)),
              Row(children: [
                Text('Jelajah',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                SizedBox(width: 8),
                Icon(Icons.near_me_rounded, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text('SCBD Jakarta · ...',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ],
          ),
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded)),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.successLight,
          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
        ),
      ],
    );
  }

  Widget _buildFlashDrop() {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 12, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            Color(0xFF079447),
            AppColors.secondary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33005B27), blurRadius: 12, offset: Offset(0, 5))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Pill(label: '● LIVE ARBITRASE PANGAN', color: Colors.white24),
          const Spacer(),
          _Pill(label: 'TAHAP 3 (-65%)', color: AppColors.secondary),
        ]),
        const SizedBox(height: 13),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Flash Drop Batch\nSore Ini',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          height: 1.08,
                          fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('Penurunan harga otomatis setiap 30\nmenit',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 11, height: 1.35)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CountdownTimer(
                endTime: DateTime.now().add(const Duration(minutes: 45)),
                compact: true),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
              color: Colors.black12, borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [
            Icon(Icons.eco_outlined, color: Colors.white, size: 16),
            SizedBox(width: 7),
            Expanded(
                child: Text('1.420 porsi surplus terselamatkan hari ini',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildFilters() {
    final filters = ['Semua (18)', 'Artisan Bakery', 'JAPANESE'];
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.asMap().entries.map((entry) {
          final selected = entry.key == 0 && _selectedFilter == 'Semua';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = 'Semua'),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.title,
      required this.value,
      required this.caption,
      required this.color,
      required this.icon,
      this.suffix,
      this.darkText = false});
  final String title;
  final String value;
  final String caption;
  final String? suffix;
  final Color color;
  final IconData icon;
  final bool darkText;

  @override
  Widget build(BuildContext context) => Container(
        height: 138,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: darkText ? Border.all(color: const Color(0xFFE5E9E5)) : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(title,
                    style: TextStyle(
                        color: darkText ? AppColors.secondary : Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w800))),
            Icon(icon,
                color: darkText ? AppColors.secondary : Colors.white, size: 16),
          ]),
          const Spacer(),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Flexible(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: darkText ? AppColors.text : Colors.white,
                        fontSize: value.length > 6 ? 19 : 31,
                        fontWeight: FontWeight.w900))),
            if (suffix != null)
              Text(' $suffix',
                  style: TextStyle(
                      color: darkText ? AppColors.text : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
          ]),
          Text(caption,
              style: TextStyle(
                  color: darkText ? AppColors.mutedText : Colors.white70,
                  fontSize: 10)),
          const SizedBox(height: 7),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: .7,
                  minHeight: 3,
                  color: darkText ? AppColors.primary : Colors.white,
                  backgroundColor:
                      darkText ? const Color(0xFFE7ECE7) : Colors.white24)),
        ]),
      );
}

class _ExploreProductCard extends StatefulWidget {
  const _ExploreProductCard(
      {required this.product, required this.onTap, required this.onSave});
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onSave;

  @override
  State<_ExploreProductCard> createState() => _ExploreProductCardState();
}

class _ExploreProductCardState extends State<_ExploreProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final format =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final product = widget.product;
    final discount = product.originalPrice == 0
        ? 0
        : ((1 - product.discountPrice / product.originalPrice) * 100).round();
    final stock = product.id == 'P001' ? 3 : product.stock;
    final imageUrl = product.imageUrl.trim().isNotEmpty
        ? product.imageUrl
        : switch (product.id) {
            'P002' =>
              'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=900',
            'P003' =>
              'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=900',
            'P004' =>
              'https://images.unsplash.com/photo-1547592180-85f173990554?w=900',
            'P005' =>
              'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=900',
            _ =>
              'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=900',
          };
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 178,
            width: double.infinity,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: AppColors.successLight,
                      child: const Icon(Icons.fastfood,
                          size: 48, color: AppColors.primary))),
              Positioned(
                top: 12,
                left: 12,
                child: _BlinkingStockPill(stock: stock),
              ),
              const Positioned(
                top: 12,
                right: 12,
                child: _Pill(
                    label: 'SIAP KIRIM 15 MENIT', color: AppColors.primary),
              ),
              Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.storeName.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 4)
                                ])),
                        Text(product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 5)
                                ])),
                      ])),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0F3F0),
                    borderRadius: BorderRadius.circular(14)),
                child: Column(children: [
                  Row(children: [
                    const Expanded(
                      child: Text('DINAMIKA NILAI\nWAKTU',
                          style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 8,
                              fontWeight: FontWeight.w800)),
                    ),
                    Text('Turun ke Rp 28.000 dlm 35\nmenit',
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 8,
                            fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                        value: .72,
                        minHeight: 6,
                        color: AppColors.secondary,
                        backgroundColor: Color(0xFFD9DFD9)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(format.format(product.originalPrice),
                            style: const TextStyle(
                                color: AppColors.mutedText, fontSize: 9)),
                        Text(
                            '${format.format(product.discountPrice)} (Sekarang)',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)),
                        const Text('Rp 28.000',
                            style: TextStyle(
                                color: AppColors.mutedText, fontSize: 9)),
                      ]),
                ]),
              ),
              const SizedBox(height: 10),
              Row(children: [
                _InfoChip(
                    icon: Icons.schedule_outlined, label: 'Sebelum 22:00 ...'),
                const SizedBox(width: 8),
                _InfoChip(
                    icon: Icons.pedal_bike_outlined,
                    label: 'Kurir internal siap'),
              ]),
              const SizedBox(height: 10),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(format.format(product.originalPrice),
                      style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough)),
                  Text(format.format(product.discountPrice),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                ]),
                const SizedBox(width: 7),
                if (discount > 0)
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFDCCF),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text('-$discount%',
                          style: const TextStyle(
                              color: Color(0xFF9B4527),
                              fontSize: 10,
                              fontWeight: FontWeight.w800))),
                const Spacer(),
                FilledButton(
                    onPressed: widget.onSave,
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11)),
                    child: const Text('AMANKAN  →',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _BlinkingStockPill extends StatelessWidget {
  const _BlinkingStockPill({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_ExploreProductCardState>();
    return AnimatedBuilder(
      animation: state?._pulseController ?? const AlwaysStoppedAnimation(1),
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Opacity(
            opacity: .35 + ((state?._pulseController.value ?? 1) * .65),
            child: const Icon(Icons.circle, color: Color(0xFFFF7357), size: 10),
          ),
          const SizedBox(width: 4),
          Text('TERSISA $stock PORSI',
              style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 9,
                  fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          decoration: BoxDecoration(
              color: const Color(0xFFF0F3F0),
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Icon(icon, color: AppColors.mutedText, size: 14),
            const SizedBox(width: 5),
            Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.mutedText, fontSize: 9))),
          ]),
        ),
      );
}
