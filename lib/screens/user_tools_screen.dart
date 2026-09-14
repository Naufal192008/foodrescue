import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      ('FR-7824', 'Surprise Box Roti & Pastry', 'Rp 27.000', '12 Sep 2026'),
      ('FR-6190', 'Paket Sarapan Hemat', 'Rp 20.000', '9 Sep 2026'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Pesanan selesai',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          ...orders.map(
            (order) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.successLight,
                  child: Icon(Icons.check_rounded, color: AppColors.primary),
                ),
                title: Text(order.$2,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${order.$1} • ${order.$4}'),
                trailing: Text(
                  order.$3,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<String> _methods = ['Transfer Bank •••• 1234'];

  Future<void> _addMethod() async {
    final controller = TextEditingController();
    final method = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah metode pembayaran'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama metode',
            hintText: 'Contoh: GoPay •••• 8899',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || method == null || method.isEmpty) return;
    setState(() => _methods.add(method));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Tambah metode pembayaran',
            onPressed: _addMethod,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ..._methods.map(
            (method) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.successLight,
                  child: Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.primary),
                ),
                title: Text(method),
                trailing: IconButton(
                  tooltip: 'Hapus metode pembayaran',
                  onPressed: () => setState(() => _methods.remove(method)),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                ),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _addMethod,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah metode pembayaran'),
          ),
        ],
      ),
    );
  }
}
