import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../providers/admin_provider.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  Future<void> _exportCsv(BuildContext context, String filename, List<List<String>> rows) async {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map((e) => '"${e.replaceAll('"', '""')}"').join(','));
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$filename disalin ke clipboard (${rows.length} baris)'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _exportJson(BuildContext context, String filename, List<Map<String, dynamic>> data) async {
    final txt = const JsonEncoder.withIndent('  ').convert(data);
    await Clipboard.setData(ClipboardData(text: txt));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$filename disalin sebagai JSON (${data.length} entri)'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Laporan & Export',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Unduh laporan dalam berbagai format',
            style: TextStyle(color: AppColors.mutedText)),
        const SizedBox(height: 22),
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
              const Text('Ringkasan Bisnis',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 16),
              Row(children: [
                _summary('Total Revenue',
                    'Rp ${NumberFormat('#,###', 'id_ID').format(p.totalRevenue)}',
                    AppColors.primary),
                _summary('Total Orders', '${p.orders.length}', Colors.blue),
                _summary('Total Users', '${p.users.length}', Colors.purple),
                _summary('Total Stores', '${p.stores.length}', AppColors.secondary),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('Format Export',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 1100 ? 3 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.3,
          children: [
            _exportCard(
              title: 'Laporan Pesanan (CSV)',
              subtitle: '${p.orders.length} baris',
              icon: Icons.receipt_long_rounded,
              color: Colors.blue,
              onTap: () => _exportCsv(
                context,
                'orders.csv',
                [
                  ['Kode', 'Customer', 'Toko', 'Produk', 'Total', 'Status', 'Tanggal'],
                  ...p.orders.map((o) => [
                        o.code,
                        o.customerName,
                        o.storeName,
                        o.productName,
                        o.total.toString(),
                        o.status,
                        DateFormat('yyyy-MM-dd HH:mm').format(o.createdAt),
                      ]),
                ],
              ),
            ),
            _exportCard(
              title: 'Data Pengguna (CSV)',
              subtitle: '${p.users.length} baris',
              icon: Icons.people_alt_rounded,
              color: Colors.purple,
              onTap: () => _exportCsv(
                context,
                'users.csv',
                [
                  ['ID', 'Nama', 'Email', 'Telepon', 'Role', 'Status', 'Total Order', 'Total Spent'],
                  ...p.users.map((u) => [
                        u.id,
                        u.name,
                        u.email,
                        u.phone,
                        u.role.name,
                        u.status.name,
                        u.totalOrders.toString(),
                        u.totalSpent.toString(),
                      ]),
                ],
              ),
            ),
            _exportCard(
              title: 'Data Toko (CSV)',
              subtitle: '${p.stores.length} baris',
              icon: Icons.storefront_rounded,
              color: AppColors.primary,
              onTap: () => _exportCsv(
                context,
                'stores.csv',
                [
                  ['ID', 'Nama', 'Owner', 'Email', 'Rating', 'Sales', 'Products', 'Verified', 'Active'],
                  ...p.stores.map((s) => [
                        s.id,
                        s.name,
                        s.ownerName,
                        s.email,
                        s.rating.toString(),
                        s.totalSales.toString(),
                        s.totalProducts.toString(),
                        s.isVerified.toString(),
                        s.isActive.toString(),
                      ]),
                ],
              ),
            ),
            _exportCard(
              title: 'Pesanan (JSON)',
              subtitle: 'API-ready format',
              icon: Icons.code_rounded,
              color: Colors.deepOrange,
              onTap: () => _exportJson(
                context,
                'orders.json',
                p.orders
                    .map((o) => {
                          'id': o.id,
                          'code': o.code,
                          'customer': o.customerName,
                          'store': o.storeName,
                          'product': o.productName,
                          'total': o.total,
                          'status': o.status,
                          'createdAt': o.createdAt.toIso8601String(),
                        })
                    .toList(),
              ),
            ),
            _exportCard(
              title: 'Pengguna (JSON)',
              subtitle: 'API-ready format',
              icon: Icons.data_object_rounded,
              color: Colors.teal,
              onTap: () => _exportJson(
                context,
                'users.json',
                p.users.map((u) => u.toJson()).toList(),
              ),
            ),
            _exportCard(
              title: 'Audit Logs (JSON)',
              subtitle: '${p.logs.length} entri',
              icon: Icons.security_rounded,
              color: Colors.red,
              onTap: () => _exportJson(
                context,
                'logs.json',
                p.logs
                    .map((l) => {
                          'id': l.id,
                          'admin': l.adminName,
                          'action': l.action,
                          'target': l.target,
                          'time': l.timestamp.toIso8601String(),
                          'details': l.details,
                        })
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summary(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
            ],
          ),
        ),
      );

  Widget _exportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8E3)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 14)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.mutedText, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, color: AppColors.mutedText),
          ]),
        ),
      );
}