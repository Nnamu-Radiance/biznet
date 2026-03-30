import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String businessId;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    try {
      return ProductModel(
        id: map['id']?.toString() ?? '',
        businessId: map['businessId']?.toString() ?? '',
        categoryId: map['categoryId']?.toString() ?? '',
        name: map['name']?.toString() ?? 'Unnamed Product',
        description: map['description']?.toString(),
        price: (map['price'] ?? 0.0).toDouble(),
        imageUrl: map['imageUrl']?.toString(),
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: map['updatedAt'] is Timestamp
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing ProductModel: $e, data: $map');
      return ProductModel(
        id: map['id']?.toString() ?? 'error',
        businessId: map['businessId']?.toString() ?? '',
        categoryId: map['categoryId']?.toString() ?? '',
        name: 'Error Loading Product',
        price: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'categoryId': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
