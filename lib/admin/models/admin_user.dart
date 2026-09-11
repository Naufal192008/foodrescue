enum UserRole { admin, superAdmin, storeOwner, customer }
enum UserStatus { active, suspended, banned }

class AdminUser {
  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.lastLogin,
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.avatarUrl,
  });

  final String id;
  String name;
  String email;
  String phone;
  UserRole role;
  UserStatus status;
  final DateTime joinedAt;
  DateTime? lastLogin;
  int totalOrders;
  int totalSpent;
  String? avatarUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'status': status.name,
        'joinedAt': joinedAt.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
      };
}

class AdminStore {
  AdminStore({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.rating,
    required this.totalSales,
    required this.totalProducts,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  String name;
  String ownerName;
  String email;
  String phone;
  String address;
  double rating;
  int totalSales;
  int totalProducts;
  bool isVerified;
  bool isActive;
  final DateTime createdAt;
}

class AdminOrder {
  AdminOrder({
    required this.id,
    required this.code,
    required this.customerName,
    required this.storeName,
    required this.productName,
    required this.total,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  final String id;
  final String code;
  final String customerName;
  final String storeName;
  final String productName;
  final int total;
  String status;
  final String paymentMethod;
  final DateTime createdAt;
}

class AuditLog {
  AuditLog({
    required this.id,
    required this.adminName,
    required this.action,
    required this.target,
    required this.timestamp,
    this.details,
  });

  final String id;
  final String adminName;
  final String action;
  final String target;
  final DateTime timestamp;
  final String? details;
}