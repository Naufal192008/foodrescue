import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/like_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/countdown_timer.dart';
import 'ticket_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _paymentMethod = 'GoPay';
  String _deliveryMethod = 'Ambil sendiri';

  Product get product => widget.product;

  String _currency(int value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);

  Future<void> _claim(BuildContext context) async {
    context.read<CartProvider>().addToCart(product);
    final uri = switch (_paymentMethod) {
      'GoPay' => Uri.parse('gopay://home'),
      'OVO' => Uri.parse('ovo://home'),
      'ShopeePay' => Uri.parse('shopeepay://'),
      _ => null,
    };
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted && _paymentMethod == 'QRIS') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QRIS akan ditampilkan pada tahap pembayaran.')),
      );
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TicketScreen(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceFee = 2000;
    final deliveryFee = _deliveryMethod == 'Ambil sendiri'
      ? 0
      : 5000 + (product.distance * 2500).round();
    final total = product.discountPrice + serviceFee + deliveryFee;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            actions: [
              Consumer<LikeProvider>(
                builder: (context, likeProvider, _) {
                  final liked = likeProvider.isLiked(product.id);
                  return IconButton(
                    onPressed: () {
                      final nowLiked = likeProvider.toggleLike(product.id);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              nowLiked
                                  ? '❤️ Ditambahkan ke favorit'
                                  : '💔 Dihapus dari favorit',
                            ),
                            duration: const Duration(seconds: 1),
                            backgroundColor: nowLiked
                                ? AppColors.danger
                                : AppColors.mutedText,
                          ),
                        );
                    },
                    icon: Icon(
                      liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: liked ? AppColors.danger : Colors.white,
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.successLight,
                      child: const Icon(
                        Icons.fastfood,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 18,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          _currency(product.discountPrice),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 5),
                      Text(product.storeName),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.mutedText,
                      ),
                      const SizedBox(width: 3),
                      Text('${product.distance.toStringAsFixed(1)} km'),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star_rounded,
                          color: AppColors.secondary,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${product.rating} / 5.0',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Tentang Surprise Box Ini',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Potensi Isi Box Kamu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...product.itemsInBag.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          Text(item),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Waktu Pengambilan',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${DateFormat('HH:mm').format(product.pickupStart)} - ${DateFormat('HH:mm').format(product.pickupEnd)}',
                              ),
                              const SizedBox(height: 5),
                              CountdownTimer(endTime: product.pickupEnd),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Rincian Pembayaran',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _PriceRow(
                    label: 'Harga Normal',
                    value: _currency(product.originalPrice),
                  ),
                  _PriceRow(
                    label: 'Diskon',
                    value: '- ${_currency(product.savings)}',
                    valueColor: AppColors.primary,
                  ),
                  _PriceRow(
                    label: 'Biaya Layanan',
                    value: _currency(serviceFee),
                  ),
                  const Divider(height: 22),
                  _PriceRow(
                    label: 'Total',
                    value: _currency(total),
                    bold: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  RadioGroup<String>(
                    groupValue: _paymentMethod,
                    onChanged: (value) => setState(() => _paymentMethod = value!),
                    child: Column(
                      children: [
                        ...['GoPay', 'OVO', 'ShopeePay', 'QRIS'].map(
                          (method) => RadioListTile<String>(
                            value: method,
                            contentPadding: EdgeInsets.zero,
                            title: Text(method),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Cara Menerima Pesanan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  RadioGroup<String>(
                    groupValue: _deliveryMethod,
                    onChanged: (value) => setState(() => _deliveryMethod = value!),
                    child: Column(
                      children: [
                        ...['Ambil sendiri', 'Antar dengan Gojek', 'Antar dengan Grab'].map(
                          (method) => RadioListTile<String>(
                            value: method,
                            contentPadding: EdgeInsets.zero,
                            title: Text(method),
                            subtitle: method == 'Ambil sendiri'
                                ? null
                                : Text('Ongkir ${_currency(5000 + (product.distance * 2500).round())}'),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PriceRow(label: 'Biaya antar', value: _currency(deliveryFee)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 12),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Bayar',
                      style: TextStyle(color: AppColors.mutedText),
                    ),
                    Text(
                      _currency(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () => _claim(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Claim Surprise Box Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: bold ? AppColors.text : AppColors.mutedText,
                fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
}