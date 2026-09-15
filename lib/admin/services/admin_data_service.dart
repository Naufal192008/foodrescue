import 'package:flutter/foundation.dart';

import '../../models/product_model.dart';
import '../models/admin_user.dart';

class AdminDataService extends ChangeNotifier {
  static final AdminDataService _instance = AdminDataService._();
  factory AdminDataService() => _instance;
  AdminDataService._();

  final List<AdminUser> users = [
    AdminUser(
      id: 'U001',
      name: 'Budi Santoso',
      email: 'budi@email.com',
      phone: '0812-3456-7890',
      role: UserRole.customer,
      status: UserStatus.active,
      joinedAt: DateTime(2024, 3, 12),
      lastLogin: DateTime.now(),
      totalOrders: 24,
      totalSpent: 285000,
    ),
    AdminUser(
      id: 'U002',
      name: 'Alya Putri',
      email: 'alya@email.com',
      phone: '0813-2233-4455',
      role: UserRole.customer,
      status: UserStatus.active,
      joinedAt: DateTime(2024, 5, 8),
      lastLogin: DateTime.now(),
      totalOrders: 12,
      totalSpent: 156000,
    ),
    AdminUser(
      id: 'U003',
      name: 'Rizky Adi',
      email: 'rizky@email.com',
      phone: '0821-9988-7766',
      role: UserRole.customer,
      status: UserStatus.suspended,
      joinedAt: DateTime(2024, 1, 22),
      totalOrders: 3,
      totalSpent: 45000,
    ),
  ];

  final List<AdminStore> stores = [
    AdminStore(
      id: 'ST001',
      name: 'Kopi Senja',
      ownerName: 'Rina Wati',
      email: 'owner@kopisenja.id',
      phone: '0811-2222-3333',
      address: 'Jl. Melati No. 24, Jakarta Selatan',
      rating: 4.8,
      totalSales: 2850000,
      totalProducts: 12,
      isVerified: true,
      isActive: true,
      createdAt: DateTime(2024, 2, 14),
    ),
    AdminStore(
      id: 'ST002',
      name: 'Dapur Ibu Rina',
      ownerName: 'Rina Kartika',
      email: 'rina@dapuribu.id',
      phone: '0812-5555-6666',
      address: 'Jl. Anggrek No. 8, Jakarta Pusat',
      rating: 4.6,
      totalSales: 1520000,
      totalProducts: 8,
      isVerified: true,
      isActive: true,
      createdAt: DateTime(2024, 3, 1),
    ),
  ];

  // Shared local catalog used by both the admin panel and the user Explore page.
  final List<Product> products = [
    Product(
      id: 'P001',
      name: 'Sourdough Loaf & Almond Croissant',
      storeName: 'Beau Bakery · Menteng',
      distance: 1.2,
      originalPrice: 120000,
      discountPrice: 42000,
      imageUrl:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=900',
      stock: 3,
      pickupStart: DateTime(2024, 1, 1, 16),
      pickupEnd: DateTime(2024, 1, 1, 20),
      rating: 4.8,
      description: 'Sourdough loaf dan almond croissant pilihan hari ini.',
      itemsInBag: ['Sourdough loaf', 'Almond croissant'],
      category: 'Bakery',
    ),
    Product(
      id: 'P002',
      name: 'Paket Nasi Ayam Hemat',
      storeName: 'Dapur Ibu Rina',
      distance: 2.1,
      originalPrice: 36000,
      discountPrice: 18000,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=900',
      stock: 8,
      pickupStart: DateTime(2024, 1, 1, 17),
      pickupEnd: DateTime(2024, 1, 1, 20),
      rating: 4.6,
      description: 'Paket nasi ayam rumahan.',
      itemsInBag: ['Nasi', 'Ayam', 'Sayur'],
      category: 'Meal',
    ),
    Product(
      id: 'P003',
      name: 'Fruit Bowl Segar',
      storeName: 'Green Market',
      distance: 1.8,
      originalPrice: 30000,
      discountPrice: 15000,
      imageUrl:
          'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=900',
      stock: 3,
      pickupStart: DateTime(2024, 1, 1, 15),
      pickupEnd: DateTime(2024, 1, 1, 19),
      rating: 4.7,
      description: 'Buah segar siap disantap.',
      itemsInBag: ['Buah musiman'],
      category: 'Fruit',
    ),
    Product(
      id: 'P004',
      name: 'Paket Sarapan Hemat',
      storeName: 'Kopi Senja',
      distance: 1.2,
      originalPrice: 36000,
      discountPrice: 18000,
      imageUrl:
          'https://images.unsplash.com/photo-1547592180-85f173990554?w=900',
      stock: 8,
      pickupStart: DateTime(2024, 1, 1, 7),
      pickupEnd: DateTime(2024, 1, 1, 11),
      rating: 4.5,
      description: 'Menu sarapan praktis.',
      itemsInBag: ['Roti', 'Kopi'],
      category: 'Meal',
    ),
    Product(
      id: 'P005',
      name: 'Donat Gula Spesial',
      storeName: 'Bakery Corner',
      distance: 3.0,
      originalPrice: 24000,
      discountPrice: 12000,
      imageUrl:
          'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=900',
      stock: 0,
      pickupStart: DateTime(2024, 1, 1, 16),
      pickupEnd: DateTime(2024, 1, 1, 19),
      rating: 4.4,
      description: 'Donat gula spesial.',
      itemsInBag: ['Donat'],
      category: 'Bakery',
    ),
  ];

  final List<AdminOrder> orders = List.generate(20, (i) {
    final statuses = ['Menunggu', 'Siap Diambil', 'Selesai', 'Dibatalkan'];
    return AdminOrder(
      id: 'ORD${1000 + i}',
      code: 'FR-${7800 + i}',
      customerName: ['Budi', 'Alya', 'Rizky'][i % 3],
      storeName: ['Kopi Senja', 'Dapur Ibu Rina'][i % 2],
      productName: 'Surprise Box ${i + 1}',
      total: 15000 + (i * 1500) % 50000,
      status: statuses[i % statuses.length],
      paymentMethod: ['GoPay', 'OVO', 'ShopeePay', 'QRIS'][i % 4],
      createdAt: DateTime.now().subtract(Duration(hours: i * 6)),
    );
  });

  final List<AuditLog> logs = [
    AuditLog(
      id: 'L001',
      adminName: 'Super Admin',
      action: 'LOGIN',
      target: 'admin@foodrescue.id',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      details: 'Login berhasil',
    ),
  ];

  void addUser(AdminUser user) {
    users.insert(0, user);
    notifyListeners();
  }

  void addProduct(Product product) {
    products.insert(0, product);
    notifyListeners();
  }

  void replaceProducts(Iterable<Product> incoming) {
    products
      ..clear()
      ..addAll(incoming);
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = products.indexWhere((item) => item.id == product.id);
    if (index == -1) return;
    products[index] = product;
    notifyListeners();
  }

  void deleteProduct(String id) {
    products.removeWhere((product) => product.id == id);
    notifyListeners();
  }

  void addOrderFromProduct(Product product) {
    orders.insert(
        0,
        AdminOrder(
          id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
          code: 'FR-${DateTime.now().millisecondsSinceEpoch % 100000}',
          customerName: 'User FoodRescue',
          storeName: product.storeName,
          productName: product.name,
          total: product.discountPrice,
          status: 'Menunggu',
          paymentMethod: 'Belum dipilih',
          createdAt: DateTime.now(),
        ));
    final index = products.indexWhere((item) => item.id == product.id);
    if (index != -1 && products[index].stock > 0) {
      products[index] =
          products[index].copyWith(stock: products[index].stock - 1);
    }
    notifyListeners();
  }
}
