import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/business_model.dart';
import '../data/models/product_model.dart';
import '../data/models/review_model.dart';
import '../data/services/firestore_service.dart';

class BusinessProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  BusinessModel? _currentBusiness;
  List<ProductModel> _products = [];
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<BusinessModel?>? _businessSubscription;
  StreamSubscription<List<ProductModel>>? _productsSubscription;
  StreamSubscription<List<ReviewModel>>? _reviewsSubscription;

  BusinessModel? get currentBusiness => _currentBusiness;
  List<ProductModel> get products => _products;
  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _businessSubscription?.cancel();
    _productsSubscription?.cancel();
    _reviewsSubscription?.cancel();
    super.dispose();
  }

  Future<bool> updateBusinessProfile(BusinessModel business) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.saveBusiness(business);
      _currentBusiness = business;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Update business profile error: $e');
      _error = 'Failed to update business profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestoreService.addProduct(product);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Add product error: $e');
      _error = 'Failed to add product';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchBusinessByOwner(String ownerId, {String? userName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cancel previous subscriptions
      await _businessSubscription?.cancel();
      await _productsSubscription?.cancel();
      await _reviewsSubscription?.cancel();

      // Listen to business changes
      final businessId = 'biz_$ownerId';
      _businessSubscription = _firestoreService.getBusinessStreamById(businessId).listen((business) async {
        if (business == null) {
          // Try fallback query if not found by ID
          final fallbackBusiness = await _firestoreService.getBusinessByOwnerId(ownerId);
          if (fallbackBusiness != null) {
            _currentBusiness = fallbackBusiness;
            _setupSubCollections(fallbackBusiness.id);
            notifyListeners();
            return;
          }

          if (userName != null) {
            print('BusinessProvider: Business profile missing for $ownerId, creating one...');
            final newBusiness = BusinessModel(
              id: businessId,
              ownerId: ownerId,
              name: userName,
              description: 'Welcome to $userName! We are excited to serve you.',
              trustScore: 5.0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            await _firestoreService.createBusiness(newBusiness);
            // The stream will pick up the new business
          } else {
            _error = 'Business profile not found';
            notifyListeners();
          }
        } else {
          _currentBusiness = business;
          _setupSubCollections(business.id);
          notifyListeners();
        }
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Fetch business by owner error: $e');
      _error = 'Failed to load business profile';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupSubCollections(String businessId) {
    _productsSubscription?.cancel();
    _reviewsSubscription?.cancel();

    _productsSubscription = _firestoreService.getBusinessProducts(businessId).listen((updatedProducts) {
      _products = updatedProducts;
      notifyListeners();
    });

    _reviewsSubscription = _firestoreService.getBusinessReviews(businessId).listen((updatedReviews) {
      _reviews = updatedReviews;
      notifyListeners();
    });
  }

  Future<void> fetchBusinessDetails(String businessId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentBusiness = await _firestoreService.getBusinessById(businessId);
      if (_currentBusiness != null) {
        // Fetch products and reviews in parallel
        final productsStream = _firestoreService.getBusinessProducts(businessId);
        final reviewsStream = _firestoreService.getBusinessReviews(businessId);

        // Listen to streams for real-time updates
        productsStream.listen((updatedProducts) {
          _products = updatedProducts;
          notifyListeners();
        });

        reviewsStream.listen((updatedReviews) {
          _reviews = updatedReviews;
          notifyListeners();
        });
      } else {
        _error = 'Business not found';
      }
    } catch (e) {
      print('Fetch business details error: $e');
      _error = 'Failed to load business details';
    }

    _isLoading = false;
    notifyListeners();
  }
}
