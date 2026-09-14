class Product {
  const Product({
    required this.id,
    required this.name,
    required this.storeName,
    required this.distance,
    required this.originalPrice,
    required this.discountPrice,
    required this.imageUrl,
    required this.stock,
    required this.pickupStart,
    required this.pickupEnd,
    required this.rating,
    required this.description,
    required this.itemsInBag,
    this.likes = 0,
  });

  final String id;
  final String name;
  final String storeName;
  final double distance;
  final int originalPrice;
  final int discountPrice;
  final String imageUrl;
  final int stock;
  final DateTime pickupStart;
  final DateTime pickupEnd;
  final double rating;
  final String description;
  final List<String> itemsInBag;
  final int likes;

  int get savings => originalPrice - discountPrice;

  Product copyWith({int? likes}) => Product(
        id: id,
        name: name,
        storeName: storeName,
        distance: distance,
        originalPrice: originalPrice,
        discountPrice: discountPrice,
        imageUrl: imageUrl,
        stock: stock,
        pickupStart: pickupStart,
        pickupEnd: pickupEnd,
        rating: rating,
        description: description,
        itemsInBag: itemsInBag,
        likes: likes ?? this.likes,
      );

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      storeName: json['store_name'] ?? json['storeName'] ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      originalPrice: json['original_price'] ?? json['originalPrice'] ?? 0,
      discountPrice: json['discount_price'] ?? json['discountPrice'] ?? 0,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      stock: json['stock'] ?? 0,
      pickupStart: DateTime.tryParse(json['pickup_start'] ?? json['pickupStart'] ?? '') ?? DateTime.now(),
      pickupEnd: DateTime.tryParse(json['pickup_end'] ?? json['pickupEnd'] ?? '') ?? DateTime.now(),
      rating: (json['rating'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      itemsInBag: List<String>.from(json['items_in_bag'] ?? json['itemsInBag'] ?? []),
    );
  }
}