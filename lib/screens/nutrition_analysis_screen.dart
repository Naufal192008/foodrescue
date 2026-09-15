import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../utils/app_colors.dart';

class NutritionAnalysisScreen extends StatelessWidget {
  const NutritionAnalysisScreen({super.key, this.product});

  final Product? product;

  @override
  Widget build(BuildContext context) {
    final foodName = product?.name ?? 'Sourdough Loaf & Almond Croissant';
    final imageUrl = product?.imageUrl.trim().isNotEmpty == true
        ? product!.imageUrl
        : 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=900';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildStatusRow(),
            const SizedBox(height: 12),
            Text('Analisis Presisi Gizi & Olah Ulang',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    )),
            const SizedBox(height: 4),
            const Text(
              'Optimalkan nutrisi makanan surplus dan perpanjang\nsiklus konsumsi bahan premium.',
              style: TextStyle(color: AppColors.mutedText, fontSize: 11),
            ),
            const SizedBox(height: 16),
            _buildSpectrumCard(),
            const SizedBox(height: 8),
            _buildQuestionBar(),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text('Item Dalam Analisis',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ),
                _Tag(label: 'ID: #REC-9824', color: const Color(0xFFF0F2EF)),
              ],
            ),
            const SizedBox(height: 10),
            _buildFoodSummary(foodName, imageUrl),
            const SizedBox(height: 10),
            _buildNutritionCard(),
            const SizedBox(height: 10),
            _buildAllergyCard(),
            const SizedBox(height: 20),
            const Text('Rekomendasi Metabolisme AI',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            _buildAiRecommendation(),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: AppColors.secondary, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Ide Olah Ulang Cerdas',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ),
                Text('LIHAT\nSEMUA',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 10),
            _RecipeCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=900',
              title: 'Crispy Salmon Onigiri',
              subtitle:
                  'Panggang cepat suwiran salmon sisa di wajan tanpa minyak hingga garing aromatik.',
              action: 'MASAK SEKARANG',
            ),
            _RecipeCard(
              imageUrl:
                  'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=900',
              title: 'Salmon Teriyaki Fried Rice with Quinoa',
              subtitle:
                  'Tumis sisa nasi donburi dan potongan salmon dengan sayur serta teriyaki ringan.',
              action: 'LIHAT RESEP',
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border_rounded, size: 17),
              label: const Text('SIMPAN RESEP & LOG MAKRO KE PROFIL'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                textStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 7),
            const Center(
              child: Text(
                  'Setiap penyelamatan makanan mengurangi hingga 1.8 kg jejak karbon setara.',
                  style: TextStyle(color: AppColors.mutedText, fontSize: 9)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.auto_awesome_rounded),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RESCUE OS',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800)),
              Text('AI Nutrisi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const Icon(Icons.notifications_none_rounded),
        const SizedBox(width: 10),
        const CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.successLight,
          child: Icon(Icons.person_rounded, color: AppColors.primary, size: 19),
        ),
      ]);

  Widget _buildStatusRow() => Row(children: [
        const _StatusPill(
            icon: Icons.eco_rounded, label: 'NUTRISI TERJAGA', value: 'v3.2'),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('• Algoritma\n   FoodRescue',
              style: TextStyle(fontSize: 9, color: AppColors.mutedText)),
        ),
        _Tag(label: '⚡ LATENSI\n   42MS', color: const Color(0xFFD5F6D5)),
      ]);

  Widget _buildSpectrumCard() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFE9F6EF),
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: const Color(0xFF89F29B),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.biotech_outlined,
                color: AppColors.primaryDark),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PEMINDAIAN SPEKTRUM',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text('Pindai Label / Foto Makanan',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                Text('Deteksi komposisi gizi dan kesegaran seketika',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 9)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, size: 18),
        ]),
      );

  Widget _buildQuestionBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E9E4)),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.psychology_outlined,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 7),
          const Expanded(
              child: Text('Tanyakan kecocokan nutrisi atau resep...',
                  style: TextStyle(fontSize: 10, color: AppColors.mutedText))),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 14),
          ),
        ]),
      );

  Widget _buildFoodSummary(String foodName, String imageUrl) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: AppColors.successLight,
                    child: const Icon(Icons.fastfood_rounded,
                        color: AppColors.primary))),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('◉  Diselamatkan 18 menit lalu',
                    style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text('Surplus Salmon Don...',
                    style: TextStyle(fontWeight: FontWeight.w800)),
                Text('Bento Box Katering Eksklusif · Restoran Omakesa SCBD',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.mutedText, fontSize: 9)),
              ],
            ),
          ),
        ]),
      );

  Widget _buildNutritionCard() => Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
            color: const Color(0xFFF0F3F0),
            borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          SizedBox(
            height: 110,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox.square(
                dimension: 94,
                child: CircularProgressIndicator(
                    value: .76,
                    strokeWidth: 9,
                    backgroundColor: AppColors.secondary,
                    color: AppColors.primary),
              ),
              const Column(mainAxisSize: MainAxisSize.min, children: [
                Text('TOTAL PROTEIN',
                    style: TextStyle(fontSize: 7, color: AppColors.mutedText)),
                Text('38g',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                Text('76% Target',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 8,
                        fontWeight: FontWeight.w700)),
              ]),
            ]),
          ),
          Row(children: [
            _NutritionMini(
                label: 'PROTEIN MURNI',
                value: '38g',
                detail: 'Tinggi (Otot Pulih)'),
            const SizedBox(width: 8),
            _NutritionMini(
                label: 'KARBO KOMPLEKS',
                value: '52g',
                detail: 'Indeks Glikemik Rendah'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _NutritionMini(
                label: 'OMEGA-3 EPA/DHA',
                value: '14g',
                detail: 'Anti-Inflamasi'),
            const SizedBox(width: 8),
            _NutritionMini(
                label: 'SERAT PANGAN', value: '6.5g', detail: 'Prebiotik Usus'),
          ]),
          const SizedBox(height: 10),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: const Row(children: [
                Text('92',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SKOR KEBUGARAN AI: 92/100',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w800)),
                  Text('Optimal Pasca-Workout', style: TextStyle(fontSize: 10)),
                ]),
                Spacer(),
                Icon(Icons.verified_outlined,
                    color: AppColors.primary, size: 16),
              ])),
        ]),
      );

  Widget _buildAllergyCard() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFFFD9CB),
            borderRadius: BorderRadius.circular(12)),
        child: const Row(children: [
          Icon(Icons.shield_outlined, color: const Color(0xFFB94826), size: 17),
          SizedBox(width: 8),
          Expanded(
            child: Text(
                'PROFIL ALERGI & DIET\nBebas Produk Susu · Mengandung Wijen & Gluten',
                style: TextStyle(fontSize: 9, height: 1.4)),
          ),
        ]),
      );

  Widget _buildAiRecommendation() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFF0F3F0),
            borderRadius: BorderRadius.circular(18)),
        child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.psychology_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Expanded(
                    child: Text('NutriRescue Intelligence',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 12))),
                Text('Baru saja',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 8)),
              ]),
              SizedBox(height: 10),
              Text(
                  'Porsi ini memiliki profil protein sangat baik untuk target pemulihan otot kamu malam ini. Saya sarankan konsumsi edamame terlebih dahulu untuk stabilisasi glukosa darah sebelum menikmati salmon dan nasi donburi.',
                  style: TextStyle(fontSize: 10, height: 1.45)),
              SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _SmallAction(
                        icon: Icons.volume_up_outlined,
                        label: 'Dengarkan\nRingkasan')),
                SizedBox(width: 8),
                Expanded(
                    child: _SmallAction(
                        icon: Icons.note_alt_outlined,
                        label: 'Catat ke Makro\nHarian')),
              ]),
            ]),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFD8F6DD),
          borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.primary, size: 13),
        const SizedBox(width: 4),
        Text('$label\n$value',
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 7,
                fontWeight: FontWeight.w800)),
      ]));
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)));
}

class _NutritionMini extends StatelessWidget {
  const _NutritionMini(
      {required this.label, required this.value, required this.detail});
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(11)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('●  $label',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 7,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(color: AppColors.mutedText, fontSize: 8)),
          ]),
        ),
      );
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(9)),
        child: Row(children: [
          Icon(icon, color: AppColors.primary, size: 13),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 8)),
        ]),
      );
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard(
      {required this.imageUrl,
      required this.title,
      required this.subtitle,
      required this.action});
  final String imageUrl;
  final String title;
  final String subtitle;
  final String action;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 112,
            width: double.infinity,
            child: Image.network(imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: AppColors.successLight,
                    child: const Icon(Icons.restaurant_rounded,
                        color: AppColors.primary, size: 36))),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 12),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('7 MENIT   ·   ZERO WASTE',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppColors.mutedText, fontSize: 9)),
              const SizedBox(height: 8),
              Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8)),
                      child: Text(action,
                          style: const TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w800)))),
            ]),
          ),
        ]),
      );
}
