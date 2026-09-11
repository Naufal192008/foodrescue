import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../providers/admin_provider.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Analytics & Insight',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Pantau performa platform secara real-time',
            style: TextStyle(color: AppColors.mutedText)),
        const SizedBox(height: 20),
        // Simple bar chart for revenue
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8E3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Revenue 7 Hari Terakhir',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 6),
              Text(
                'Total: Rp ${NumberFormat('#,###', 'id_ID').format(p.totalRevenue)}',
                style: const TextStyle(color: AppColors.mutedText),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                    final value = 0.3 + (i * 0.1);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 160 * value,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryDark],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(days[i],
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _insightCard(
                title: 'Top Toko',
                icon: Icons.emoji_events_rounded,
                color: AppColors.secondary,
                children: p.stores
                    .take(5)
                    .map((s) => _listItem(
                          s.name,
                          'Rp ${NumberFormat('#,###', 'id_ID').format(s.totalSales)}',
                          s.rating,
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _insightCard(
                title: 'User Paling Aktif',
                icon: Icons.people_alt_rounded,
                color: Colors.blue,
                children: (p.users.toList()
                      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent)))
                    .take(5)
                    .map((u) => _listItem(
                          u.name,
                          '${u.totalOrders} order',
                          null,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _insightCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8E3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 15)),
            ]),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      );

  Widget _listItem(String name, String value, double? rating) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(name[0],
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13)),
          ),
          if (rating != null) ...[
            const Icon(Icons.star_rounded, color: AppColors.secondary, size: 14),
            const SizedBox(width: 2),
            Text('${rating.toStringAsFixed(1)}  ',
                style: const TextStyle(fontSize: 11)),
          ],
          Text(value,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ]),
      );
}