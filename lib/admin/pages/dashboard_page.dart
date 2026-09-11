import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../providers/admin_provider.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    final screenW = MediaQuery.of(context).size.width;
    final crossCount = screenW > 1400 ? 4 : screenW > 1000 ? 3 : screenW > 700 ? 2 : 1;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selamat datang kembali, Super Admin 👋',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 8),
                    Text('Pantau & kelola FoodRescue dari satu dashboard.',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const Icon(Icons.insights_rounded, size: 110, color: Colors.white24),
            ],
          ),
        ),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.7,
          children: [
            StatCard(
              title: 'Total Pengguna', value: '${p.users.length}',
              icon: Icons.people_alt_rounded, color: const Color(0xFF2E7D32),
              change: '+12%', subtitle: '${p.activeUsers} aktif',
            ),
            StatCard(
              title: 'Total Toko', value: '${p.stores.length}',
              icon: Icons.storefront_rounded, color: const Color(0xFF1976D2),
              change: '+5%', subtitle: '${p.activeStores} aktif',
            ),
            StatCard(
              title: 'Total Pesanan', value: '${p.orders.length}',
              icon: Icons.receipt_long_rounded, color: const Color(0xFFFF9800),
              change: '+18%', subtitle: '${p.pendingOrders} pending',
            ),
            StatCard(
              title: 'Total Revenue', value: 'Rp ${(p.totalRevenue / 1000).toStringAsFixed(0)}rb',
              icon: Icons.payments_rounded, color: const Color(0xFF7B1FA2),
              change: '+24%', subtitle: 'Bulan ini',
            ),
          ],
        ),
      ],
    );
  }
}