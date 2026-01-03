class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String>? imageUrls; 
  final String? imagePublicId; 
  final String category;
  final int stock;
  final bool isFavorite;
  final String? sellerId;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.imageUrls,
    this.imagePublicId, 
    required this.category,
    required this.stock,
    this.isFavorite = false,
    this.sellerId,
    this.createdAt,
  });

  // Convert from JSON / Firestore document
  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle image URL - Firebase Storage returns full URLs
    String? imageUrl = json['image'];
    if (imageUrl != null) {
      if (!imageUrl.startsWith('http')) {
        imageUrl = imageUrl;
      }
    } else if (json['image_url'] != null) {
      imageUrl = json['image_url'] as String?;
    }

    // Multi image support
    List<String>? imageUrls;
    if (json['imageUrls'] != null) {
      if (json['imageUrls'] is List) {
        imageUrls = (json['imageUrls'] as List).whereType<String>().toList();
      } else if (json['imageUrls'] is List<dynamic>) {
        imageUrls = (json['imageUrls'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Handle timestamp
    DateTime? createdAt;
    final createdAtValue = json['created_at'];
    if (createdAtValue is DateTime) {
      createdAt = createdAtValue;
    }

    // Get ID from json if present, otherwise use a generated one
    final id =
        json['id'] as String? ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return Product(
      id: id,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      imagePublicId:
          json['image_public_id'] as String?, // ✅ NEW: Cloudinary public ID
      category: json['category'] as String? ?? 'Other',
      stock: json['stock'] as int? ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
      sellerId: json['seller_id'] as String?,
      createdAt: createdAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      if (imageUrl != null) 'image': imageUrl,
      if (imageUrls != null && imageUrls!.isNotEmpty) 'imageUrls': imageUrls,
      if (imagePublicId != null) 'image_public_id': imagePublicId, // ✅ NEW
      'category': category,
      'stock': stock,
      'is_favorite': isFavorite,
      if (sellerId != null) 'seller_id': sellerId,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  // Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    List<String>? imageUrls,
    String? imagePublicId, // ✅ NEW
    String? category,
    int? stock,
    bool? isFavorite,
    String? sellerId,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      imagePublicId: imagePublicId ?? this.imagePublicId, // ✅ NEW
      category: category ?? this.category,
      stock: stock ?? this.stock,
      isFavorite: isFavorite ?? this.isFavorite,
      sellerId: sellerId ?? this.sellerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
