import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/like_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/countdown_timer.dart';
import 'nutrition_analysis_screen.dart';
import 'ticket_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});
  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedPaymentMethod = 'GoPay';
  String _selectedPickupMethod = 'courier';
  static const _priceResetDuration = Duration(minutes: 2, seconds: 9);
  Timer? _priceTimer;
  Duration _priceResetRemaining = _priceResetDuration;
  late int _currentPrice;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.product.discountPrice;
    _priceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_priceResetRemaining.inSeconds <= 1) {
        final minimumPrice = 10000;
        final priceDrop = (_currentPrice * .1).round().clamp(5000, 15000);
        setState(() {
          _currentPrice =
              (_currentPrice - priceDrop).clamp(minimumPrice, _currentPrice);
          _priceResetRemaining = _priceResetDuration;
        });
      } else {
        setState(() {
          _priceResetRemaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    super.dispose();
  }

  String _currency(int value) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      ).format(value);

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _claim(BuildContext context) async {
    final addressController = TextEditingController();
    final address = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_selectedPickupMethod == 'courier'
            ? 'Alamat pengantaran'
            : 'Lokasi pengambilan'),
        content: TextField(
          controller: addressController,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Alamat lengkap',
            hintText: _selectedPickupMethod == 'courier'
                ? 'Contoh: Jl. Melati No. 24, Jakarta Selatan'
                : 'Contoh: Nama dan lokasi toko yang dipilih',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final value = addressController.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Lanjut Bayar'),
          ),
        ],
      ),
    );
    addressController.dispose();
    if (!mounted || address == null) return;
    final claimedProduct =
        widget.product.copyWith(discountPrice: _currentPrice);
    context.read<CartProvider>().addToCart(claimedProduct);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TicketScreen(
          product: claimedProduct,
          address: address,
          paymentMethod: _selectedPaymentMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final serviceFee = 2000;
    final pricedProduct = product.copyWith(discountPrice: _currentPrice);
    final total = _currentPrice + serviceFee;
    final imageUrl = product.imageUrl.trim().isNotEmpty
        ? product.imageUrl
        : 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=900';
    final discount = product.originalPrice == 0
        ? 0
        : ((1 - product.discountPrice / product.originalPrice) * 100).round();
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 120),
          children: [
            _DetailHeader(product: product),
            const SizedBox(height: 8),
            _DetailHero(
                product: product, imageUrl: imageUrl, discount: discount),
            const SizedBox(height: 10),
            _DetailSection(
              icon: Icons.show_chart_rounded,
              eyebrow: 'MEKANISME FINANSIAL SURPLUS',
              title: 'Algoritma Penurunan\nHarga Dinamis',
              child: Column(children: [
                Container(
                  height: 165,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F0),
                      borderRadius: BorderRadius.circular(14)),
                  child: Column(children: [
                    const Expanded(
                      child: CustomPaint(
                        painter: _PriceGraphPainter(),
                        child: SizedBox.expand(),
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GraphPrice(
                              label: '17:00 WIB · AWAL',
                              value: _currency(product.originalPrice)),
                          _GraphPrice(
                              label: '● SEKARANG',
                              value: _currency(_currentPrice),
                              active: true),
                          const _GraphPrice(
                              label: '21:00 WIB · FINAL', value: 'Rp 35.000'),
                        ]),
                  ]),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F0),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.timer_outlined,
                        color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'RESET NILAI BERIKUTNYA\n${_formatDuration(_priceResetRemaining)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800))),
                    Text(
                        'Risiko Kehabisan\nPeluang: ${product.stock * 10}% Diambil',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            _DetailSection(
              icon: Icons.psychology_rounded,
              eyebrow: 'AI PORTION & NUTRITION MATCH',
              title: 'Akurasi 98%',
              dark: true,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Ideal untuk 1 porsi makan malam berprotein tinggi atau pemulihan energi setelah aktivitas harian.',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11, height: 1.4)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _GreenMetric(
                          label: 'KALORI',
                          value: '540',
                          suffix: 'Kkal / porsi'),
                      const SizedBox(width: 7),
                      _GreenMetric(
                          label: 'PROTEIN',
                          value: '34g',
                          suffix: 'Salmon & Edamame'),
                      const SizedBox(width: 7),
                      _GreenMetric(
                          label: 'KARBOHIDRAT',
                          value: '62g',
                          suffix: 'Nasi Jepang & Sayur'),
                    ]),
                    const SizedBox(height: 10),
                    const Row(children: [
                      Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 17),
                      SizedBox(width: 6),
                      Text(
                          'Memenuhi 45% kebutuhan protein harian dewasa aktif.',
                          style: TextStyle(color: Colors.white, fontSize: 10))
                    ]),
                  ]),
            ),
            const SizedBox(height: 10),
            _DetailSection(
              icon: Icons.shield_outlined,
              eyebrow: 'Protokol Keamanan\nPangan',
              headerTrailing: 'LOG HACCP #SS-\n91042',
              title: '',
              child: Column(children: [
                _SafetyRow(
                    icon: Icons.schedule_outlined,
                    title: 'WAKTU PRODUKSI / MASAK',
                    value:
                        '${DateFormat('HH:mm').format(product.pickupStart)} WIB (Sore)',
                    trailing: 'Batch 03'),
                _SafetyRow(
                    icon: Icons.event_available_outlined,
                    title: 'BATAS AMAN KONSUMSI',
                    value:
                        'Sebelum ${DateFormat('HH:mm').format(product.pickupEnd)} WIB',
                    trailing: 'Terpantau'),
                _SafetyRow(
                    icon: Icons.ac_unit_outlined,
                    title: 'PENYIMPANAN & CARA SANTAP',
                    value:
                        'Disimpan chiller steril 4°C terjaga standar HACCP & ISO-22000.',
                    trailing: ''),
              ]),
            ),
            const SizedBox(height: 10),
            _DetailSection(
              eyebrow: 'PILIHAN METODE PENGAMBILAN',
              title: '',
              child: Column(children: [
                Row(children: [
                  Expanded(
                      child: _PickupChoice(
                          icon: Icons.local_shipping_outlined,
                          title: 'Kurir Khusus\n(Diantar)',
                          subtitle:
                              'Armada Eco-Fleet\nInsulated 4°C · (+Rp\n8.000, Bayar QRIS)',
                          selected: _selectedPickupMethod == 'courier',
                          onTap: () => setState(
                              () => _selectedPickupMethod = 'courier'))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _PickupChoice(
                          icon: Icons.storefront_outlined,
                          title: 'Self Pick-up (Ambil Sendiri)',
                          subtitle:
                              'Kasir Sushi Sei Plaza\nSenayan (Gratis\nOngkir)',
                          selected: _selectedPickupMethod == 'pickup',
                          onTap: () => setState(
                              () => _selectedPickupMethod = 'pickup'))),
                ]),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F0),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Row(children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 16),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                          'Kurir Eco-Fleet siap antar dalam 25 menit setelah pesanan terkonfirmasi.',
                          style: TextStyle(
                              color: AppColors.mutedText, fontSize: 9)),
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            _PriceSummary(
                product: pricedProduct,
                total: total,
                discount: discount,
                onClaim: () => _claim(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NutritionAnalysisScreen(product: product),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Analisis nutrisi dengan Gemini',
        child: const Icon(Icons.auto_awesome_rounded),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(18)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
      );
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RESCUE OS',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800)),
            Text('Detail Penyelamatan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ]),
        ),
        const Icon(Icons.near_me_rounded, color: AppColors.primary, size: 15),
        const SizedBox(width: 4),
        Text(product.distance < 1.5 ? 'SCBD Jakarta · ...' : 'Jakarta Selatan',
            style: const TextStyle(fontSize: 9)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
      ]);
}

class _DetailHero extends StatelessWidget {
  const _DetailHero(
      {required this.product, required this.imageUrl, required this.discount});
  final Product product;
  final String imageUrl;
  final int discount;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 270,
          child: Stack(fit: StackFit.expand, children: [
            Image.network(imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: AppColors.successLight,
                    child: const Icon(Icons.fastfood,
                        size: 64, color: AppColors.primary))),
            DecoratedBox(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                  Colors.black26,
                  Colors.transparent,
                  Colors.black87
                ]))),
            Positioned(
                top: 12,
                left: 12,
                child: product.stock <= 3
                    ? const _BlinkingDetailStockPill()
                    : const _DetailPill(
                        label: '● BATCH TERSEDIA', color: AppColors.secondary)),
            Positioned(
                top: 12,
                right: 12,
                child: Row(children: [
                  _HeroIcon(icon: Icons.bookmark_border_rounded),
                  const SizedBox(width: 7),
                  _HeroIcon(icon: Icons.share_outlined),
                ])),
            Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${product.category.toUpperCase()} · ${product.storeName.toUpperCase()}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800)),
                      Text(product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.1,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.white, size: 15),
                        SizedBox(width: 4),
                        Text('4.9 (${product.likes + 328} ulasan)',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 10),
                        Text('Display fresh dinner batch',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 9))
                      ]),
                    ])),
          ]),
        ),
      );
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 17, color: AppColors.text),
      );
}

class _BlinkingDetailStockPill extends StatefulWidget {
  const _BlinkingDetailStockPill();

  @override
  State<_BlinkingDetailStockPill> createState() =>
      _BlinkingDetailStockPillState();
}

class _BlinkingDetailStockPillState extends State<_BlinkingDetailStockPill>
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
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Opacity(
              opacity: .3 + (_pulseController.value * .7),
              child: const Icon(Icons.circle, color: Colors.white, size: 9),
            ),
            const SizedBox(width: 4),
            const Text(
              'SISA 3 PORSI · DISKON SPESIAL',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800),
            ),
          ]),
        ),
      );
}

class _DetailSection extends StatelessWidget {
  const _DetailSection(
      {this.icon,
      required this.eyebrow,
      required this.title,
      required this.child,
      this.dark = false,
      this.headerTrailing});
  final IconData? icon;
  final String eyebrow;
  final String title;
  final Widget child;
  final bool dark;
  final String? headerTrailing;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: dark ? AppColors.primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[
              Icon(icon,
                  color: dark ? Colors.white : AppColors.primary, size: 17),
              const SizedBox(width: 7)
            ],
            Expanded(
                child: Text(eyebrow,
                    style: TextStyle(
                        color: dark ? Colors.white : AppColors.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.w800))),
            if (headerTrailing != null)
              Text(headerTrailing!,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 7,
                      fontWeight: FontWeight.w700)),
            if (dark)
              const _DetailPill(label: 'Akurasi 98%', color: Colors.white24),
          ]),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(title,
                style: TextStyle(
                    color: dark ? Colors.white : AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800))
          ],
          const SizedBox(height: 10),
          child,
        ]),
      );
}

class _GraphPrice extends StatelessWidget {
  const _GraphPrice(
      {required this.label, required this.value, this.active = false});
  final String label;
  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                color: active ? AppColors.secondary : AppColors.mutedText,
                fontSize: 7,
                fontWeight: FontWeight.w700)),
        Text(value,
            style: TextStyle(
                color: active ? AppColors.primary : AppColors.mutedText,
                fontSize: 10,
                fontWeight: FontWeight.w700))
      ]);
}

class _GreenMetric extends StatelessWidget {
  const _GreenMetric(
      {required this.label, required this.value, required this.suffix});
  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white12, borderRadius: BorderRadius.circular(10)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 7,
                    fontWeight: FontWeight.w700)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900)),
            Text(suffix,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 7))
          ])));
}

class _SafetyRow extends StatelessWidget {
  const _SafetyRow(
      {required this.icon,
      required this.title,
      required this.value,
      required this.trailing});
  final IconData icon;
  final String title;
  final String value;
  final String trailing;

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
          color: const Color(0xFFF0F3F0),
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 17),
        const SizedBox(width: 8),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 7,
                  fontWeight: FontWeight.w700)),
          Text(value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))
        ])),
        if (trailing == 'Terpantau')
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10)),
              child: const Text('Terpantau',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w800)))
        else if (trailing.isNotEmpty)
          Text(trailing,
              style: const TextStyle(color: AppColors.mutedText, fontSize: 8))
      ]));
}

class _PickupChoice extends StatelessWidget {
  const _PickupChoice(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.selected,
      required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color:
                    selected ? AppColors.primaryDark : const Color(0xFFF0F3F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFE1E7E1))),
            child: Row(children: [
              Icon(icon,
                  color: selected ? Colors.white : AppColors.text, size: 19),
              const SizedBox(width: 6),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: selected ? Colors.white : AppColors.text,
                            fontSize: 9,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color:
                                selected ? Colors.white70 : AppColors.mutedText,
                            fontSize: 8,
                            height: 1.2)),
                  ]))
            ])),
      );
}

class _PriceSummary extends StatelessWidget {
  const _PriceSummary(
      {required this.product,
      required this.total,
      required this.discount,
      required this.onClaim});
  final Product product;
  final int total;
  final int discount;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('HARGA PENYELAMATAN',
            style: TextStyle(
                color: AppColors.mutedText,
                fontSize: 8,
                fontWeight: FontWeight.w800)),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(product.discountPrice),
              style: const TextStyle(
                  color: Color(0xFFB94826),
                  fontSize: 31,
                  fontWeight: FontWeight.w900)),
          const SizedBox(width: 10),
          if (discount > 0)
            Text('-$discount% OFF',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800))
        ]),
        const SizedBox(height: 8),
        SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
                onPressed: onClaim,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('AMANKAN SEKARANG'),
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800)))),
        const SizedBox(height: 5),
        const Center(
            child: Text('Jaminan Keamanan Pangan 100% · Proteksi E-sorow',
                style: TextStyle(color: AppColors.mutedText, fontSize: 8)))
      ]));
}

class _PriceGraphPainter extends CustomPainter {
  const _PriceGraphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final accent = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(10, 35)
      ..lineTo(size.width * .25, 35)
      ..lineTo(size.width * .42, size.height * .68)
      ..lineTo(size.width * .62, size.height * .68)
      ..lineTo(size.width * .78, size.height * .9)
      ..lineTo(size.width - 10, size.height * .9);
    canvas.drawPath(path, line);
    canvas.drawCircle(Offset(size.width * .62, size.height * .68), 5, accent);
    canvas.drawLine(const Offset(10, 35), Offset(size.width * .25, 35), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
