import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../providers/admin_provider.dart';
import '../widgets/confirm_dialog.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _searchCtrl = TextEditingController();
  String _statusFilter = 'Semua';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    final q = _searchCtrl.text.toLowerCase();
    final list = p.orders.where((o) {
      final mQ = o.code.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.storeName.toLowerCase().contains(q) ||
          o.productName.toLowerCase().contains(q);
      final mS = _statusFilter == 'Semua' || o.status == _statusFilter;
      return mQ && mS;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manajemen Pesanan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Pantau dan kelola semua transaksi',
              style: TextStyle(color: AppColors.mutedText)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari kode, customer, toko, produk...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8E3))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8E3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter,
                  onChanged: (v) => setState(() => _statusFilter = v!),
                  items: ['Semua', 'Menunggu', 'Siap Diambil', 'Selesai', 'Dibatalkan']
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13))))
                      .toList(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8E3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: const Row(children: [
                      Expanded(flex: 2, child: _H('KODE')),
                      Expanded(flex: 3, child: _H('CUSTOMER')),
                      Expanded(flex: 3, child: _H('TOKO / PRODUK')),
                      Expanded(flex: 2, child: _H('TOTAL')),
                      Expanded(flex: 2, child: _H('STATUS')),
                      Expanded(flex: 2, child: _H('AKSI')),
                    ]),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: list.isEmpty
                        ? const Center(child: Text('Tidak ada pesanan'))
                        : ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) => _orderRow(list[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderRow(dynamic o) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.code,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(DateFormat('dd MMM, HH:mm').format(o.createdAt),
                    style: const TextStyle(
                        color: AppColors.mutedText, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(o.customerName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.storeName,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(o.productName,
                    style: const TextStyle(
                        color: AppColors.mutedText, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Rp ${NumberFormat('#,###', 'id_ID').format(o.total)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.primary)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor(o.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(o.status,
                  style: TextStyle(
                      color: _statusColor(o.status),
                      fontWeight: FontWeight.w800,
                      fontSize: 11)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(children: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  context.read<AdminProvider>().updateOrderStatus(o.id, v);
                },
                itemBuilder: (_) => ['Menunggu', 'Siap Diambil', 'Selesai', 'Dibatalkan']
                    .map((e) => PopupMenuItem(value: e, child: Text(e)))
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Ubah',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                    Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ]),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Hapus Pesanan?',
                    message: 'Pesanan ${o.code} akan dihapus permanen.',
                    confirmLabel: 'Hapus',
                    danger: true,
                  );
                  if (ok && context.mounted) {
                    context.read<AdminProvider>().deleteOrder(o.id);
                  }
                },
                icon: const Icon(Icons.delete_rounded,
                    color: AppColors.danger, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ]),
          ),
        ]),
      );

  Color _statusColor(String s) => switch (s) {
        'Menunggu' => Colors.orange,
        'Siap Diambil' => Colors.blue,
        'Selesai' => AppColors.primary,
        'Dibatalkan' => AppColors.danger,
        _ => Colors.grey,
      };
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFF667085),
          letterSpacing: 0.6));
}