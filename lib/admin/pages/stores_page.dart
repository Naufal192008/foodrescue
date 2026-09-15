 import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../models/admin_user.dart';
import '../providers/admin_provider.dart';
import '../widgets/confirm_dialog.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});
  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AdminProvider>();
    final q = _searchCtrl.text.toLowerCase();
    final list = p.stores
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.ownerName.toLowerCase().contains(q) ||
            s.address.toLowerCase().contains(q))
        .toList();
    final screenW = MediaQuery.of(context).size.width;
    final cross = screenW > 1500 ? 4 : screenW > 1100 ? 3 : screenW > 700 ? 2 : 1;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manajemen Toko',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Kelola semua mitra toko FoodRescue',
                      style: TextStyle(color: AppColors.mutedText)),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _showStoreForm(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.add_business_rounded),
              label: const Text('Tambah Toko',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari toko, owner, atau alamat...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8E3))),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.45,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => _storeCard(list[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storeCard(AdminStore s) => Container(
        padding: const EdgeInsets.all(18),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Text(s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15)),
                      ),
                      if (s.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified_rounded,
                              color: Colors.blue, size: 16),
                        ),
                    ]),
                    Text(s.ownerName,
                        style: const TextStyle(
                            color: AppColors.mutedText, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: s.isActive ? AppColors.primary : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(s.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.mutedText, fontSize: 12)),
            const SizedBox(height: 12),
            Row(children: [
              _mini(Icons.star_rounded, s.rating.toString(),
                  AppColors.secondary),
              const SizedBox(width: 14),
              _mini(Icons.shopping_bag_outlined, '${s.totalProducts}',
                  Colors.blue),
              const Spacer(),
              Text('Rp ${NumberFormat('#,###', 'id_ID').format(s.totalSales)}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 13)),
            ]),
            const Spacer(),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showStoreForm(store: s),
                  icon: const Icon(Icons.edit_rounded, size: 15),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  context.read<AdminProvider>().toggleStoreActive(s.id);
                },
                icon: Icon(
                  s.isActive ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.orange,
                  size: 18,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () async {
                  final provider = context.read<AdminProvider>();
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Hapus Toko?',
                    message:
                        '${s.name} akan dihapus permanen dari platform.',
                    confirmLabel: 'Hapus',
                    danger: true,
                  );
                  if (ok) {
                    provider.deleteStore(s.id);
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
          ],
        ),
      );

  Widget _mini(IconData icon, String text, Color color) => Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
      ]);

  Future<void> _showStoreForm({AdminStore? store}) async {
    final nameCtrl = TextEditingController(text: store?.name ?? '');
    final ownerCtrl = TextEditingController(text: store?.ownerName ?? '');
    final emailCtrl = TextEditingController(text: store?.email ?? '');
    final phoneCtrl = TextEditingController(text: store?.phone ?? '');
    final addrCtrl = TextEditingController(text: store?.address ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(store == null ? 'Tambah Toko' : 'Edit Toko',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 460,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nama Toko', border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ownerCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nama Owner', border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Telepon', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addrCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Alamat', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final p = context.read<AdminProvider>();
              if (store == null) {
                p.addStore(AdminStore(
                  id: 'ST${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  ownerName: ownerCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  address: addrCtrl.text.trim(),
                  rating: 0,
                  totalSales: 0,
                  totalProducts: 0,
                  isVerified: false,
                  isActive: true,
                  createdAt: DateTime.now(),
                ));
              } else {
                store.name = nameCtrl.text.trim();
                store.ownerName = ownerCtrl.text.trim();
                store.email = emailCtrl.text.trim();
                store.phone = phoneCtrl.text.trim();
                store.address = addrCtrl.text.trim();
                p.updateStore(store);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}