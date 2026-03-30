import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart' show rootBundle;

class SeedData {
  static Future<void> seed() async {
    final db = FirebaseFirestore.instance;
    final uuid = const Uuid();

    // 1. Seed Categories
    List<Map<String, dynamic>> categories = [];
    try {
      final csvData = await rootBundle.loadString('lib/data/sample_data/categories.csv');
      final lines = csvData.split('\n');

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        final parts = lines[i].split(',');
        if (parts.length >= 3) {
          categories.add({
            'id': parts[0].trim(),
            'name': parts[1].trim(),
            'description': parts[2].trim(),
          });
        }
      }
    } catch (e) {
      categories = [
        {'id': 'skincare', 'name': 'Skincare', 'description': 'Face and body care products'},
        {'id': 'haircare', 'name': 'Haircare', 'description': 'Shampoos, conditioners, and styling'},
        {'id': 'makeup', 'name': 'Makeup', 'description': 'Cosmetics for face, eyes, and lips'},
        {'id': 'fragrance', 'name': 'Fragrance', 'description': 'Perfumes and colognes'},
        {'id': 'nails', 'name': 'Nails', 'description': 'Polish and nail care'},
      ];
      print('Could not load categories.csv, using fallback data. Error: $e');
    }

    // 2. Seed Users from CSV
    List<Map<String, dynamic>> users = [];
    try {
      final csvData = await rootBundle.loadString('lib/data/sample_data/users.csv');
      final lines = csvData.split('\n');

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        final parts = lines[i].split(',');
        if (parts.length >= 4) {
          users.add({
            'uid': parts[0].trim(),
            'email': parts[1].trim(),
            'name': parts[2].trim(),
            'role': parts[3].trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      // Fallback
      users = [
        {
          'uid': 'owner_1',
          'email': 'glow@beauty.com',
          'name': 'Sarah Glow',
          'role': 'business',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'uid': 'owner_2',
          'email': 'pure@hair.com',
          'name': 'John Pure',
          'role': 'business',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'uid': 'customer_1',
          'email': 'alice@example.com',
          'name': 'Alice Smith',
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'uid': 'customer_2',
          'email': 'bob@example.com',
          'name': 'Bob Johnson',
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];
      print('Could not load users.csv, using fallback data. Error: $e');
    }

    // 3. Seed Businesses from CSV
    List<Map<String, dynamic>> businesses = [];
    try {
      final csvData = await rootBundle.loadString('lib/data/sample_data/businesses.csv');
      final lines = csvData.split('\n');

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        final parts = lines[i].split(',');
        if (parts.length >= 7) {
          businesses.add({
            'id': parts[0].trim(),
            'ownerId': parts[1].trim(),
            'name': parts[2].trim(),
            'description': parts[3].trim(),
            'logoUrl': parts[4].trim(),
            'ecommerceLink': parts[5].trim(),
            'trustScore': double.tryParse(parts[6].trim()) ?? 4.0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      // Fallback
      businesses = [
        {
          'id': 'biz_1',
          'ownerId': 'owner_1',
          'name': 'Glow Beauty Studio',
          'description': 'Premium skincare and facial treatments.',
          'logoUrl': 'https://picsum.photos/seed/glow/200/200',
          'ecommerceLink': 'https://example.com/glow',
          'trustScore': 4.8,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'biz_2',
          'ownerId': 'owner_2',
          'name': 'Pure Hair Care',
          'description': 'Organic hair treatments and styling.',
          'logoUrl': 'https://picsum.photos/seed/hair/200/200',
          'ecommerceLink': 'https://example.com/pure',
          'trustScore': 4.5,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];
      print('Could not load businesses.csv, using fallback data. Error: $e');
    }

    // 4. Seed Products from CSV
    List<Map<String, dynamic>> products = [];
    try {
      final csvData = await rootBundle.loadString('lib/data/sample_data/products.csv');
      final lines = csvData.split('\n');

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        final parts = lines[i].split(',');
        if (parts.length >= 7) {
          products.add({
            'id': parts[0].trim(),
            'businessId': parts[1].trim(),
            'categoryId': parts[2].trim(),
            'name': parts[3].trim(),
            'description': parts[4].trim(),
            'price': double.tryParse(parts[5].trim()) ?? 0.0,
            'imageUrl': parts[6].trim(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      // Fallback
      products = [
        {
          'id': uuid.v4(),
          'businessId': 'biz_1',
          'categoryId': 'skincare',
          'name': 'Radiance Serum',
          'description': 'Vitamin C serum for glowing skin.',
          'price': 45.0,
          'imageUrl': 'https://picsum.photos/seed/serum/300/300',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': uuid.v4(),
          'businessId': 'biz_1',
          'categoryId': 'skincare',
          'name': 'Hydrating Mask',
          'description': 'Deep hydration for dry skin.',
          'price': 25.0,
          'imageUrl': 'https://picsum.photos/seed/mask/300/300',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': uuid.v4(),
          'businessId': 'biz_2',
          'categoryId': 'haircare',
          'name': 'Argan Oil Shampoo',
          'description': 'Nourishing shampoo with pure argan oil.',
          'price': 18.0,
          'imageUrl': 'https://picsum.photos/seed/shampoo/300/300',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];
      print('Could not load products.csv, using fallback data. Error: $e');
    }

    // 5. Seed Reviews from CSV
    List<Map<String, dynamic>> reviews = [];
    try {
      final csvData = await rootBundle.loadString('lib/data/sample_data/reviews.csv');
      final lines = csvData.split('\n');

      for (int i = 1; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) continue;
        final parts = lines[i].split(',');
        if (parts.length >= 6) {
          reviews.add({
            'id': uuid.v4(), // generate new ID for review
            'businessId': parts[1].trim(),
            'userId': parts[2].trim(),
            'userName': parts[3].trim(),
            'rating': int.tryParse(parts[4].trim()) ?? 5,
            'text': parts[5].trim(),
            'imageUrl': null,
            'videoLink': null,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      reviews = [
        {
          'id': uuid.v4(),
          'businessId': 'biz_1',
          'userId': 'customer_1',
          'userName': 'Alice Smith',
          'rating': 5,
          'text': 'Amazing service and products! My skin has never looked better.',
          'imageUrl': null,
          'videoLink': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': uuid.v4(),
          'businessId': 'biz_1',
          'userId': 'customer_2',
          'userName': 'Bob Johnson',
          'rating': 4,
          'text': 'Great experience, but the serum was a bit pricey.',
          'imageUrl': null,
          'videoLink': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'id': uuid.v4(),
          'businessId': 'biz_2',
          'userId': 'customer_1',
          'userName': 'Alice Smith',
          'rating': 5,
          'text': 'The argan oil shampoo is a game changer for my hair!',
          'imageUrl': null,
          'videoLink': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];
      print('Could not load reviews.csv, using fallback data. Error: $e');
    }

    try {
      for (var cat in categories) {
        await db.collection('categories').doc(cat['id'] as String).set(cat);
      }

      for (var user in users) {
        await db.collection('users').doc(user['uid'] as String).set(user);
      }

      for (var biz in businesses) {
        await db.collection('businesses').doc(biz['id'] as String).set(biz);
      }

      for (var prod in products) {
        await db.collection('products').doc(prod['id'] as String).set(prod);
      }

      for (var rev in reviews) {
        await db.collection('reviews').doc(rev['id'] as String).set(rev);
      }

      print('Seed data successfully inserted!');
    } catch (e) {
      print('Error inserting seed data: $e');
    }
  }
}
