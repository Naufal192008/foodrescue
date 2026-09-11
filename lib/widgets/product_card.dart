import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/like_provider.dart';
import '../utils/app_colors.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onSave,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onSave;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  product.imageUrl,
                  width: 104,
                  height: 116,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 104,
                    height: 116,
                    color: AppColors.successLight,
                    child: const Icon(
                      Icons.fastfood,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Consumer<LikeProvider>(
                          builder: (context, likeProvider, _) {
                            final liked = likeProvider.isLiked(product.id);
                            final count = likeProvider.likeCount(product.id);
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                final nowLiked =
                                    likeProvider.toggleLike(product.id);
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(
                                      liked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 20,
                                      color: liked
                                          ? AppColors.danger
                                          : AppColors.mutedText,
                                    ),
                                    if (count > 0) ...[
                                      const SizedBox(width: 3),
                                      Text(
                                        '$count',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: liked
                                              ? AppColors.danger
                                              : AppColors.mutedText,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.storeName,
                      style: const TextStyle(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.mutedText,
                        ),
                        Text(
                          '${product.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(color: AppColors.mutedText),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: AppColors.secondary,
                        ),
                        Text(product.rating.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              format.format(product.originalPrice),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.mutedText,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              format.format(product.discountPrice),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: onSave,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Selamatkan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}