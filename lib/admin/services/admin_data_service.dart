import '../models/admin_user.dart';

class AdminDataService {
  static final AdminDataService _instance = AdminDataService._();
  factory AdminDataService() => _instance;
  AdminDataService._();

  final List<AdminUser> users = [
    AdminUser(
      id: 'U001', name: 'Budi Santoso', email: 'budi@email.com',
      phone: '0812-3456-7890', role: UserRole.customer,
      status: UserStatus.active, joinedAt: DateTime(2024, 3, 12),
      lastLogin: DateTime.now(), totalOrders: 24, totalSpent: 285000,
    ),
    AdminUser(
      id: 'U002', name: 'Alya Putri', email: 'alya@email.com',
      phone: '0813-2233-4455', role: UserRole.customer,
      status: UserStatus.active, joinedAt: DateTime(2024, 5, 8),
      lastLogin: DateTime.now(), totalOrders: 12, totalSpent: 156000,
    ),
    AdminUser(
      id: 'U003', name: 'Rizky Adi', email: 'rizky@email.com',
      phone: '0821-9988-7766', role: UserRole.customer,
      status: UserStatus.suspended, joinedAt: DateTime(2024, 1, 22),
      totalOrders: 3, totalSpent: 45000,
    ),
  ];

  final List<AdminStore> stores = [
    AdminStore(
      id: 'ST001', name: 'Kopi Senja', ownerName: 'Rina Wati',
      email: 'owner@kopisenja.id', phone: '0811-2222-3333',
      address: 'Jl. Melati No. 24, Jakarta Selatan',
      rating: 4.8, totalSales: 2850000, totalProducts: 12,
      isVerified: true, isActive: true, createdAt: DateTime(2024, 2, 14),
    ),
    AdminStore(
      id: 'ST002', name: 'Dapur Ibu Rina', ownerName: 'Rina Kartika',
      email: 'rina@dapuribu.id', phone: '0812-5555-6666',
      address: 'Jl. Anggrek No. 8, Jakarta Pusat',
      rating: 4.6, totalSales: 1520000, totalProducts: 8,
      isVerified: true, isActive: true, createdAt: DateTime(2024, 3, 1),
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
      id: 'L001', adminName: 'Super Admin', action: 'LOGIN',
      target: 'admin@foodrescue.id',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      details: 'Login berhasil',
    ),
  ];
}