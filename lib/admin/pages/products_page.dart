import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/app_colors.dart';
import '../../models/product_model.dart';
import '../services/admin_data_service.dart';

class _AdminProduct {
  _AdminProduct.fromProduct(Product product)
      : id = product.id,
        name = product.name,
        storeName = product.storeName,
        price = product.discountPrice,
        stock = product.stock,
        category = product.category,
        active = product.stock > 0;

  _AdminProduct({
    required this.id,
    required this.name,
    required this.storeName,
    required this.price,
    required this.stock,
    required this.category,
    required this.active,
  });
  final String id;
  String name;
  String storeName;
  int price;
  int stock;
  String category;
  bool active;

  Product toProduct() => Product(
        id: id,
        name: name,
        storeName: storeName,
        distance: 1.5,
        originalPrice: price * 2,
        discountPrice: price,
        imageUrl: '',
        stock: stock,
        pickupStart: DateTime.now(),
        pickupEnd: DateTime.now().add(const Duration(hours: 4)),
        rating: 4.5,
        description: 'Produk FoodRescue',
        itemsInBag: [category],
        category: category,
      );
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchCtrl = TextEditingController();
  late final List<_AdminProduct> _products;

  @override
  void initState() {
    super.initState();
    _products =
        AdminDataService().products.map(_AdminProduct.fromProduct).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchCtrl.text.toLowerCase();
    final list = _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.storeName.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final narrow = constraints.maxWidth < 620;
            final title = const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manajemen Produk',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Kelola semua produk di platform',
                    style: TextStyle(color: AppColors.mutedText)),
              ],
            );
            final action = FilledButton.icon(
              onPressed: () => _form(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah Produk',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            );
            return narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [title, const SizedBox(height: 12), action])
                : Row(children: [Expanded(child: title), action]);
          }),
          const SizedBox(height: 16),
          TextField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari produk atau toko...',
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8E3)),
              ),
              child: Column(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: const Row(children: [
                    Expanded(flex: 3, child: _H('PRODUK')),
                    Expanded(flex: 2, child: _H('TOKO')),
                    Expanded(flex: 2, child: _H('KATEGORI')),
                    Expanded(flex: 2, child: _H('HARGA')),
                    Expanded(flex: 1, child: _H('STOK')),
                    Expanded(flex: 2, child: _H('AKSI')),
                  ]),
                ),
                const Divider(height: 1),
                Expanded(
                  child: list.isEmpty
                      ? const Center(child: Text('Tidak ada produk'))
                      : ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) => _row(list[i]),
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(_AdminProduct p) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          Expanded(
            flex: 3,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fastfood_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
          Expanded(
              flex: 2,
              child: Text(p.storeName, style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(p.category,
                  style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 11)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Rp ${NumberFormat('#,###', 'id_ID').format(p.price)}',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            flex: 1,
            child: Text('${p.stock}',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: p.stock == 0 ? AppColors.danger : AppColors.text)),
          ),
          Expanded(
            flex: 2,
            child: Row(children: [
              IconButton(
                onPressed: () => _form(product: p),
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.secondary, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () {
                  setState(() => _products.remove(p));
                  AdminDataService().deleteProduct(p.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Produk dihapus'),
                        backgroundColor: AppColors.primary),
                  );
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

  Future<void> _form({_AdminProduct? product}) async {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final storeCtrl = TextEditingController(text: product?.storeName ?? '');
    final priceCtrl =
        TextEditingController(text: product?.price.toString() ?? '');
    final stockCtrl =
        TextEditingController(text: product?.stock.toString() ?? '');
    final catCtrl = TextEditingController(text: product?.category ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Produk', border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: storeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Toko', border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: catCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Kategori', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Harga', border: OutlineInputBorder()),
                      validator: (v) => v == null || int.tryParse(v) == null
                          ? 'Angka tidak valid'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Stok', border: OutlineInputBorder()),
                      validator: (v) => v == null || int.tryParse(v) == null
                          ? 'Angka tidak valid'
                          : null,
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              setState(() {
                if (product == null) {
                  final created = _AdminProduct(
                    id: 'P${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    storeName: storeCtrl.text.trim(),
                    price: int.parse(priceCtrl.text),
                    stock: int.parse(stockCtrl.text),
                    category: catCtrl.text.trim().isEmpty
                        ? 'Umum'
                        : catCtrl.text.trim(),
                    active: true,
                  );
                  _products.insert(
                    0,
                    created,
                  );
                  AdminDataService().addProduct(created.toProduct());
                } else {
                  product.name = nameCtrl.text.trim();
                  product.storeName = storeCtrl.text.trim();
                  product.price = int.parse(priceCtrl.text);
                  product.stock = int.parse(stockCtrl.text);
                  product.category = catCtrl.text.trim();
                  AdminDataService().updateProduct(product.toProduct());
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(product == null
                      ? 'Produk ditambahkan'
                      : 'Produk diperbarui'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
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
