import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String businessId;
  final String? productId; // optional product review
  final int rating;
  final String text;
  final String? imageUrl;
  final String? videoLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.businessId,
    this.productId,
    required this.rating,
    required this.text,
    this.imageUrl,
    this.videoLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    try {
      final createdAt = map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now();

      return ReviewModel(
        id: map['id']?.toString() ?? '',
        userId: map['userId']?.toString() ?? '',
        userName: map['userName']?.toString() ?? 'Anonymous',
        businessId: map['businessId']?.toString() ?? '',
        productId: map['productId']?.toString(),
        rating: (map['rating'] ?? 0).toInt(),
        text: map['text']?.toString() ?? map['comment']?.toString() ?? '',
        imageUrl: map['imageUrl']?.toString() ?? map['photoUrl']?.toString(),
        videoLink: map['videoLink']?.toString(),
        createdAt: createdAt,
        updatedAt: map['updatedAt'] is Timestamp
            ? (map['updatedAt'] as Timestamp).toDate()
            : createdAt,
      );
    } catch (e) {
      print('Error parsing ReviewModel: $e, data: $map');
      return ReviewModel(
        id: map['id']?.toString() ?? 'error',
        userId: map['userId']?.toString() ?? '',
        userName: 'Error Loading Review',
        businessId: map['businessId']?.toString() ?? '',
        productId: map['productId']?.toString(),
        rating: 0,
        text: 'Error loading review content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'businessId': businessId,
      'productId': productId,
      'rating': rating,
      'text': text,
      'imageUrl': imageUrl,
      'videoLink': videoLink,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
