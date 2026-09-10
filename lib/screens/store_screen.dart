import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/app_colors.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool _storeOpen = true;
  int _selectedTab = 0;
  final List<_SellerProduct> _products = [
    _SellerProduct(
      name: 'Surprise Box Roti & Pastry',
      description: 'Roti dan pastry pilihan hari ini.',
      price: 25000,
      stock: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600',
      available: true,
    ),
    _SellerProduct(
      name: 'Paket Sarapan Hemat',
      description: 'Menu sarapan rumahan siap santap.',
      price: 18000,
      stock: 8,
      imageUrl:
          'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600',
      available: true,
    ),
    _SellerProduct(
      name: 'Paket Buah Segar',
      description: 'Buah potong segar dari stok hari ini.',
      price: 15000,
      stock: 0,
      imageUrl:
          'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=600',
      available: false,
    ),
  ];

  final List<_SellerOrder> _orders = [
    _SellerOrder(
        code: 'FR-7824',
        product: 'Surprise Box Roti & Pastry',
        customer: 'Alya Putri',
        status: 'Menunggu diambil',
        total: 27000),
    _SellerOrder(
        code: 'FR-6190',
        product: 'Paket Sarapan Hemat',
        customer: 'Rizky Adi',
        status: 'Selesai',
        total: 20000),
  ];

  final _currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showProductForm({_SellerProduct? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(
        text: product == null ? '' : product.price.toString());
    final stockController = TextEditingController(
        text: product == null ? '' : product.stock.toString());
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 4, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    product == null
                        ? 'Tambah Surprise Box'
                        : 'Edit Surprise Box',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Nama produk', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nama produk wajib diisi'
                        : null),
                const SizedBox(height: 10),
                TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Deskripsi singkat',
                        border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Deskripsi wajib diisi'
                        : null),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Harga (Rp)',
                              border: OutlineInputBorder()),
                          validator: _numberValidator)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Stok box',
                              border: OutlineInputBorder()),
                          validator: _numberValidator))
                ]),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          setState(() {
                            final updated = _SellerProduct(
                                name: nameController.text.trim(),
                                description: descriptionController.text.trim(),
                                price: int.parse(priceController.text),
                                stock: int.parse(stockController.text),
                                imageUrl: product?.imageUrl ??
                                    'https://images.unsplash.com/photo-1547592180-85f173990554?w=600',
                                available: int.parse(stockController.text) > 0);
                            if (product == null) {
                              _products.insert(0, updated);
                            } else {
                              final index = _products.indexOf(product);
                              _products[index] = updated;
                            }
                          });
                          Navigator.pop(sheetContext);
                          _showMessage(product == null
                              ? 'Produk berhasil ditambahkan'
                              : 'Produk berhasil diperbarui');
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(product == null
                            ? 'Tambah Produk'
                            : 'Simpan Perubahan'))),
              ],
            ),
          ),
        ),
      ),
    );
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
  }

  String? _numberValidator(String? value) {
    if (value == null ||
        value.trim().isEmpty ||
        int.tryParse(value) == null ||
        int.parse(value) < 0) {
      return 'Masukkan angka valid';
    }
    return null;
  }

  void _deleteProduct(_SellerProduct product) {
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('Hapus produk?'),
                content: Text('${product.name} akan dihapus dari toko.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Batal')),
                  FilledButton(
                      onPressed: () {
                        setState(() => _products.remove(product));
                        Navigator.pop(dialogContext);
                        _showMessage('Produk dihapus');
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.danger),
                      child: const Text('Hapus'))
                ]));
  }

  void _advanceOrder(_SellerOrder order) {
    setState(() {
      order.status = switch (order.status) {
        'Menunggu diambil' => 'Siap diambil',
        'Siap diambil' => 'Selesai',
        _ => 'Selesai',
      };
    });
    _showMessage('Status pesanan ${order.code} diperbarui');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Toko Saya',
              style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
                tooltip: 'Pengaturan toko',
                onPressed: () =>
                    _showMessage('Pengaturan toko siap dihubungkan ke API'),
                icon: const Icon(Icons.settings_outlined))
          ]),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showProductForm(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Box'))
          : null,
      body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          children: [
            _StoreHeader(
                storeOpen: _storeOpen,
                onToggle: (value) {
                  setState(() => _storeOpen = value);
                  _showMessage(
                      value ? 'Toko sekarang aktif' : 'Toko sedang ditutup');
                }),
            const SizedBox(height: 16),
            Row(children: const [
              _SummaryCard(
                  value: 'Rp 285rb',
                  label: 'Penjualan bulan ini',
                  icon: Icons.payments_outlined),
              SizedBox(width: 8),
              _SummaryCard(
                  value: '13',
                  label: 'Box terjual',
                  icon: Icons.inventory_2_outlined),
              SizedBox(width: 8),
              _SummaryCard(
                  value: '4.8',
                  label: 'Rating toko',
                  icon: Icons.star_outline_rounded)
            ]),
            const SizedBox(height: 22),
            Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  _StoreTab(
                      label: 'Produk',
                      selected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0)),
                  _StoreTab(
                      label: 'Pesanan',
                      selected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1))
                ])),
            const SizedBox(height: 14),
            if (_selectedTab == 0)
              ..._products.map(_buildProductTile)
            else
              ..._orders.map(_buildOrderTile),
          ]),
    );
  }

  Widget _buildProductTile(_SellerProduct product) {
    return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(product.imageUrl,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          width: 76,
                          height: 76,
                          color: AppColors.successLight,
                          child: const Icon(Icons.fastfood,
                              color: AppColors.primary)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(_currency.format(product.price),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800)),
                    Text('Stok: ${product.stock} box',
                        style: TextStyle(
                            color: product.stock == 0
                                ? AppColors.danger
                                : AppColors.mutedText,
                            fontSize: 12))
                  ])),
              Column(children: [
                Switch(
                    value: product.available,
                    onChanged: product.stock == 0
                        ? null
                        : (value) => setState(() => product.available = value),
                    activeThumbColor: AppColors.primary),
                PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'edit') _showProductForm(product: product);
                      if (action == 'delete') _deleteProduct(product);
                    },
                    itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'edit', child: Text('Edit produk')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Hapus produk'))
                        ])
              ])
            ])));
  }

  Widget _buildOrderTile(_SellerOrder order) {
    final isDone = order.status == 'Selesai';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(order.code,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              _StatusBadge(status: order.status)
            ]),
            const SizedBox(height: 10),
            Text(order.product,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.person_outline_rounded,
                  size: 16, color: AppColors.mutedText),
              const SizedBox(width: 4),
              Text(order.customer,
                  style: const TextStyle(color: AppColors.mutedText)),
              const Spacer(),
              Text(_currency.format(order.total),
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w800))
            ]),
            if (!isDone) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _advanceOrder(order),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(order.status == 'Menunggu diambil'
                      ? 'Tandai Siap Diambil'
                      : 'Selesaikan Pesanan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SellerProduct {
  _SellerProduct(
      {required this.name,
      required this.description,
      required this.price,
      required this.stock,
      required this.imageUrl,
      required this.available});
  final String name;
  final String description;
  final int price;
  final int stock;
  final String imageUrl;
  bool available;
}

class _SellerOrder {
  _SellerOrder(
      {required this.code,
      required this.product,
      required this.customer,
      required this.status,
      required this.total});
  final String code;
  final String product;
  final String customer;
  String status;
  final int total;
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.storeOpen, required this.onToggle});
  final bool storeOpen;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white,
            child: Icon(Icons.storefront_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kopi Senja',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 19)),
                SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.star_rounded, color: Colors.amber, size: 17),
                  SizedBox(width: 3),
                  Text('4.8  •  124 ulasan',
                      style: TextStyle(color: Colors.white70))
                ]),
              ],
            ),
          ),
          Column(
            children: [
              Text(storeOpen ? 'Buka' : 'Tutup',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              Switch(
                  value: storeOpen,
                  onChanged: onToggle,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard(
      {required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 21),
            const SizedBox(height: 7),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 14)),
            const SizedBox(height: 3),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.mutedText, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _StoreTab extends StatelessWidget {
  const _StoreTab(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.mutedText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final done = status == 'Selesai';
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: done ? AppColors.successLight : const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(20)),
        child: Text(status,
            style: TextStyle(
                color: done ? AppColors.primary : Colors.orange.shade800,
                fontSize: 11,
                fontWeight: FontWeight.w700)));
  }
}
