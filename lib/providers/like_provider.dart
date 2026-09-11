import 'package:flutter/foundation.dart';

/// Provider untuk mengelola "like" user.
/// Aturan: 1 user hanya bisa like 1x per produk.
class LikeProvider extends ChangeNotifier {
  final Map<String, Set<String>> _userLikes = {};

  final Map<String, int> _likeCounts = {
    'box-001': 12,
    'box-002': 8,
    'box-003': 15,
  };

  String _currentUserId = 'user-001';
  String get currentUserId => _currentUserId;

  bool isLiked(String productId, {String? userId}) {
    final uid = userId ?? _currentUserId;
    return _userLikes[uid]?.contains(productId) ?? false;
  }

  int likeCount(String productId) => _likeCounts[productId] ?? 0;

  bool toggleLike(String productId, {String? userId}) {
    final uid = userId ?? _currentUserId;
    _userLikes.putIfAbsent(uid, () => <String>{});

    if (_userLikes[uid]!.contains(productId)) {
      _userLikes[uid]!.remove(productId);
      _likeCounts[productId] = (_likeCounts[productId] ?? 1) - 1;
      if (_likeCounts[productId]! < 0) _likeCounts[productId] = 0;
      notifyListeners();
      return false;
    } else {
      _userLikes[uid]!.add(productId);
      _likeCounts[productId] = (_likeCounts[productId] ?? 0) + 1;
      notifyListeners();
      return true;
    }
  }

  Set<String> likedProductIds({String? userId}) {
    final uid = userId ?? _currentUserId;
    return Set.unmodifiable(_userLikes[uid] ?? <String>{});
  }

  void clearUserLikes({String? userId}) {
    final uid = userId ?? _currentUserId;
    _userLikes.remove(uid);
    notifyListeners();
  }

  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
}