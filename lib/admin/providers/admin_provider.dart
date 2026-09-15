import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';
import '../models/admin_user.dart';
import '../services/admin_data_service.dart';

class AdminProvider extends ChangeNotifier {
  final _data = AdminDataService();

  AdminProvider() {
    _data.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _data.removeListener(notifyListeners);
    super.dispose();
  }

  List<AdminUser> get users => _data.users;
  List<AdminStore> get stores => _data.stores;
  List<AdminOrder> get orders => _data.orders;
  List<Product> get products => _data.products;
  List<AuditLog> get logs => _data.logs;

  void addUser(AdminUser user) {
    _data.users.insert(0, user);
    _log('CREATE_USER', user.name);
    notifyListeners();
  }

  void updateUser(AdminUser user) {
    final i = _data.users.indexWhere((u) => u.id == user.id);
    if (i != -1) {
      _data.users[i] = user;
      _log('UPDATE_USER', user.name);
      notifyListeners();
    }
  }

  void deleteUser(String id) {
    _data.users.removeWhere((u) => u.id == id);
    _log('DELETE_USER', id);
    notifyListeners();
  }

  void toggleUserStatus(String id) {
    final i = _data.users.indexWhere((u) => u.id == id);
    if (i != -1) {
      final u = _data.users[i];
      u.status = u.status == UserStatus.active
          ? UserStatus.suspended
          : UserStatus.active;
      _log('TOGGLE_USER', u.name);
      notifyListeners();
    }
  }

  void addStore(AdminStore store) {
    _data.stores.insert(0, store);
    _log('CREATE_STORE', store.name);
    notifyListeners();
  }

  void updateStore(AdminStore store) {
    final i = _data.stores.indexWhere((s) => s.id == store.id);
    if (i != -1) {
      _data.stores[i] = store;
      _log('UPDATE_STORE', store.name);
      notifyListeners();
    }
  }

  void deleteStore(String id) {
    _data.stores.removeWhere((s) => s.id == id);
    _log('DELETE_STORE', id);
    notifyListeners();
  }

  void toggleStoreActive(String id) {
    final i = _data.stores.indexWhere((s) => s.id == id);
    if (i != -1) {
      _data.stores[i].isActive = !_data.stores[i].isActive;
      _log('TOGGLE_STORE', _data.stores[i].name);
      notifyListeners();
    }
  }

  void updateOrderStatus(String id, String status) {
    final i = _data.orders.indexWhere((o) => o.id == id);
    if (i != -1) {
      _data.orders[i].status = status;
      _log('UPDATE_ORDER', _data.orders[i].code);
      notifyListeners();
    }
  }

  void deleteOrder(String id) {
    _data.orders.removeWhere((o) => o.id == id);
    _log('DELETE_ORDER', id);
    notifyListeners();
  }

  void _log(String action, String target, {String? details}) {
    _data.logs.insert(
        0,
        AuditLog(
          id: 'L${DateTime.now().millisecondsSinceEpoch}',
          adminName: 'Super Admin',
          action: action,
          target: target,
          timestamp: DateTime.now(),
          details: details,
        ));
  }

  double get totalRevenue => _data.orders.fold(0.0, (s, o) => s + o.total);
  int get activeUsers =>
      _data.users.where((u) => u.status == UserStatus.active).length;
  int get activeStores => _data.stores.where((s) => s.isActive).length;
  int get pendingOrders =>
      _data.orders.where((o) => o.status == 'Menunggu').length;
  int get completedOrders =>
      _data.orders.where((o) => o.status == 'Selesai').length;
}
