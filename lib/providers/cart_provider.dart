import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _checkoutItems = [];

  List<Product> get checkoutItems => List.unmodifiable(_checkoutItems);

  bool contains(Product product) =>
      _checkoutItems.any((item) => item.id == product.id);

  void addToCart(Product product) {
    if (contains(product)) return;
    _checkoutItems.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _checkoutItems.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  int get totalPrice =>
      _checkoutItems.fold(0, (total, product) => total + product.discountPrice);

  void clearCart() {
    _checkoutItems.clear();
    notifyListeners();
  }
}
