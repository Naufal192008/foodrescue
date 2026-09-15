import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      (
        'Komunitas Zero Waste Jakarta',
        '47 anggota baru minggu ini. Ayo bagikan tips mengurangi food waste.',
        Icons.eco_rounded,
      ),
      (
        'Diskusi penyelamatan makanan',
        'Berdiskusi soal cara menangani surplus stok dan packaging yang lebih ramah lingkungan.',
        Icons.groups_rounded,
      ),
      (
        'Kampanye 1.000 Box Terselamatkan',
        'Mari bantu toko lokal menyalurkan makanan yang masih layak konsumsi.',
        Icons.celebration_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunitas',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.groups_rounded, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bergabung dan bantu komunitas FoodRescue tumbuh lebih besar.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...posts.map(
            (post) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.successLight,
                          child: Icon(post.$3, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            post.$1,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(post.$2,
                        style: const TextStyle(
                            color: AppColors.mutedText, height: 1.5)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Ikuti diskusi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
