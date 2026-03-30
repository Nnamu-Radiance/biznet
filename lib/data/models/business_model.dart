import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? location;
  final String? ecommerceLink;
  final String? logoUrl;
  final String? instagram;
  final String? twitter;
  final String? facebook;
  final double trustScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.location,
    this.ecommerceLink,
    this.logoUrl,
    this.instagram,
    this.twitter,
    this.facebook,
    required this.trustScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    try {
      return BusinessModel(
        id: map['id']?.toString() ?? '',
        ownerId: map['ownerId']?.toString() ?? '',
        name: map['name']?.toString() ?? 'Unnamed Business',
        description: map['description']?.toString(),
        location: map['location']?.toString(),
        ecommerceLink: map['ecommerceLink']?.toString(),
        logoUrl: map['logoUrl']?.toString(),
        instagram: map['instagram']?.toString(),
        twitter: map['twitter']?.toString(),
        facebook: map['facebook']?.toString(),
        trustScore: (map['trustScore'] ?? 0.0).toDouble(),
        createdAt: map['createdAt'] is Timestamp
            ? (map['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: map['updatedAt'] is Timestamp
            ? (map['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing BusinessModel: $e, data: $map');
      // Return a fallback model to avoid crashing the whole list
      return BusinessModel(
        id: map['id']?.toString() ?? 'error',
        ownerId: map['ownerId']?.toString() ?? '',
        name: 'Error Loading Business',
        trustScore: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'location': location,
      'ecommerceLink': ecommerceLink,
      'logoUrl': logoUrl,
      'instagram': instagram,
      'twitter': twitter,
      'facebook': facebook,
      'trustScore': trustScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
