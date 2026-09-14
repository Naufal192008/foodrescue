import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key, required this.selectedIndex, required this.onSelect, this.forceExpanded = false});
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool forceExpanded;

  static const _items = [
    (Icons.dashboard_rounded, 'Dashboard'),
    (Icons.people_alt_rounded, 'Pengguna'),
    (Icons.storefront_rounded, 'Toko'),
    (Icons.inventory_2_rounded, 'Produk'),
    (Icons.receipt_long_rounded, 'Pesanan'),
    (Icons.insights_rounded, 'Analytics'),
    (Icons.file_download_rounded, 'Laporan'),
    (Icons.security_rounded, 'Audit Logs'),
    (Icons.settings_rounded, 'Pengaturan'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = forceExpanded || MediaQuery.sizeOf(context).width > 1100;
    final w = wide ? 260.0 : 76.0;
    return Container(
      width: w,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 22, horizontal: wide ? 20 : 0),
            child: Row(
              mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
                ),
                if (wide) ...[
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FoodRescue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                      Text('Admin Panel', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final selected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSelect(i),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 13, horizontal: wide ? 14 : 0),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: selected ? Border.all(color: AppColors.primary.withValues(alpha: 0.4)) : null,
                      ),
                      child: Row(
                        mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          Icon(_items[i].$1, color: selected ? AppColors.primary : Colors.white60, size: 22),
                          if (wide) ...[
                            const SizedBox(width: 14),
                            Text(_items[i].$2, style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 14,
                            )),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}