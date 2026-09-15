import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menu = [
      ('Analisis Penjualan', Icons.analytics_outlined),
      ('Tambah Barang / Makanan', Icons.add_circle_outline_rounded),
      ('Pengolahan Limbah Makanan', Icons.delete_outline_rounded),
      ('Komunitas', Icons.groups_outlined),
      ('Rating', Icons.star_outline_rounded),
      ('Profile Toko', Icons.storefront_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Saya',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.storefront_rounded,
                      color: AppColors.primary, size: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Kopi Senja',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Mitra FoodRescue aktif',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _StatCard(
                  label: 'Penjualan',
                  value: 'Rp 4,8Jt',
                  color: AppColors.primary),
              _StatCard(
                  label: 'Makanan Terselamatkan',
                  value: '152 box',
                  color: AppColors.secondary),
              _StatCard(
                  label: 'Limbah Dikurangi',
                  value: '48 kg',
                  color: AppColors.primaryDark),
              _StatCard(
                  label: 'Rating',
                  value: '4.8/5',
                  color: AppColors.successLight),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Kelola toko',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...menu.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.successLight,
                    child: Icon(item.$2, color: AppColors.primary),
                  ),
                  title: Text(item.$1,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.mutedText)),
        ],
      ),
    );
  }
}
