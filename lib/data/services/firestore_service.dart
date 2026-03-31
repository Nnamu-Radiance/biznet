import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/business_model.dart';
import '../models/review_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class FirestoreService {
  late final FirebaseFirestore _db;

  FirestoreService() {
    _db = FirebaseFirestore.instance;
  }

  void _handleFirestoreError(dynamic error, String operation, String path) {
    final auth = FirebaseAuth.instance;
    final errInfo = {
      'error': error.toString(),
      'operationType': operation,
      'path': path,
      'authInfo': {
        'userId': auth.currentUser?.uid,
        'email': auth.currentUser?.email,
        'emailVerified': auth.currentUser?.emailVerified,
        'isAnonymous': auth.currentUser?.isAnonymous,
      }
    };
    print('Firestore Error: ${jsonEncode(errInfo)}');
    throw Exception(jsonEncode(errInfo));
  }

  // --- CATEGORIES ---

  Stream<List<CategoryModel>> getCategories() {
    return _db.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()))
          .toList();
    });
  }

  // --- BUSINESSES ---

  // Get business by owner ID (Stream)
  Stream<BusinessModel?> getBusinessStreamByOwnerId(String ownerId) {
    return _db
        .collection('businesses')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return BusinessModel.fromMap(snapshot.docs.first.data());
      }
      return null;
    });
  }

  // Get business by ID (Stream)
  Stream<BusinessModel?> getBusinessStreamById(String businessId) {
    return _db.collection('businesses').doc(businessId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return BusinessModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Get a single business by ID
  Future<BusinessModel?> getBusinessById(String businessId) async {
    DocumentSnapshot doc = await _db.collection('businesses').doc(businessId).get();
    if (doc.exists && doc.data() != null) {
      return BusinessModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get all businesses (with real-time updates)
  Stream<List<BusinessModel>> getBusinesses() {
    return _db.collection('businesses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BusinessModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Get business by owner ID
  Future<BusinessModel?> getBusinessByOwnerId(String ownerId) async {
    QuerySnapshot snapshot = await _db
        .collection('businesses')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return BusinessModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Get featured businesses (highest trust score)
  Future<List<BusinessModel>> getFeaturedBusinesses({int limit = 5}) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('businesses')
          .orderBy('trustScore', descending: true)
          .limit(limit)
          .get();

      if (snapshot.docs.isEmpty) {
        // Fallback: Just get any businesses if none have trustScore or collection is empty
        snapshot = await _db.collection('businesses').limit(limit).get();
      }

      return snapshot.docs
          .map((doc) => BusinessModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching featured businesses: $e');
      // Fallback: Just get any businesses if ordering fails (e.g. missing index)
      QuerySnapshot snapshot = await _db.collection('businesses').limit(limit).get();
      return snapshot.docs
          .map((doc) => BusinessModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    }
  }

  // Create/Update business
  Future<void> saveBusiness(BusinessModel business) async {
    try {
      await _db.collection('businesses').doc(business.id).set(business.toMap());
    } catch (e) {
      _handleFirestoreError(e, 'write', 'businesses/${business.id}');
    }
  }

  // Search for businesses by name or category
  Future<List<BusinessModel>> searchBusinesses(String query) async {
    if (query.isEmpty) return [];

    // Simple case-insensitive search (Firestore doesn't support this natively well,
    // so we'll do a simple prefix search or filter client-side if needed,
    // but for now, let's try a basic query)
    final lowerCaseQuery = query.toLowerCase();

    // Fetch all businesses (in a real app with large data, you would use Algolia or Typesense)
    QuerySnapshot snapshot = await _db.collection('businesses').get();

    return snapshot.docs
        .map((doc) => BusinessModel.fromMap(doc.data() as Map<String, dynamic>))
        .where((business) =>
            business.name.toLowerCase().contains(lowerCaseQuery) ||
            (business.description?.toLowerCase().contains(lowerCaseQuery) ?? false))
        .toList();
  }

  // Get businesses by category ID
  Future<List<BusinessModel>> getBusinessesByCategory(String categoryId) async {
    // Note: since our datamodel does not currently store categories directly on the business
    // we would ideally find products of that category and then pull up the related businesses.
    // Let's implement it by finding products with this categoryId first.
    QuerySnapshot productsSnapshot = await _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .get();

    if (productsSnapshot.docs.isEmpty) return [];

    // Extract unique business IDs from the products
    final Set<String> businessIds = {};
    for (var doc in productsSnapshot.docs) {
      final productData = doc.data() as Map<String, dynamic>;
      if (productData.containsKey('businessId')) {
        businessIds.add(productData['businessId'] as String);
      }
    }

    if (businessIds.isEmpty) return [];

    // Fetch the business documents for those IDs.
    List<BusinessModel> businesses = [];
    for (String id in businessIds) {
      BusinessModel? business = await getBusinessById(id);
      if (business != null) {
        businesses.add(business);
      }
    }
    return businesses;
  }

  // --- REVIEWS ---

  // Get reviews for a specific business
  Stream<List<ReviewModel>> getBusinessReviews(String businessId) {
    return _db
        .collection('reviews')
        .where('businessId', isEqualTo: businessId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Get recent reviews across all businesses
  Stream<List<ReviewModel>> getRecentReviews({int limit = 5}) {
    return _db
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Post a new review
  Future<void> postReview(ReviewModel review) async {
    await _db.collection('reviews').doc(review.id).set(review.toMap());

    // Update business trust score (simplified logic)
    DocumentReference businessRef = _db.collection('businesses').doc(review.businessId);
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(businessRef);
      if (snapshot.exists) {
        // In a real app, you'd calculate trustScore based on multiple factors
        // For now, just update the updatedAt timestamp
        transaction.update(businessRef, {
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // --- PRODUCTS ---

  // Get products for a business
  Stream<List<ProductModel>> getBusinessProducts(String businessId) {
    return _db
        .collection('products')
        .where('businessId', isEqualTo: businessId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Add a product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _db.collection('products').doc(product.id).set(product.toMap());
    } catch (e) {
      _handleFirestoreError(e, 'write', 'products/${product.id}');
    }
  }

  // Create a new business
  Future<void> createBusiness(BusinessModel business) async {
    await _db.collection('businesses').doc(business.id).set(business.toMap());
  }
}
