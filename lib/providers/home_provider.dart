import 'package:flutter/material.dart';
import '../../../../data/models/business_model.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/review_model.dart';
import '../../../../data/services/firestore_service.dart';

class HomeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<BusinessModel> _featuredBusinesses = [];
  List<CategoryModel> _categories = [];
  List<ReviewModel> _recentReviews = [];
  bool _isLoading = false;
  String? _error;

  List<BusinessModel> get featuredBusinesses => _featuredBusinesses;
  List<CategoryModel> get categories => _categories;
  List<ReviewModel> get recentReviews => _recentReviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('HomeProvider: Initializing data...');

      // Fetch featured businesses (real-time stream)
      _firestoreService.getBusinesses().listen((businesses) {
        print('HomeProvider: Received ${businesses.length} businesses from Firestore');
        if (businesses.isNotEmpty) {
          for (var b in businesses) {
            print('HomeProvider: Business - ID: ${b.id}, Name: ${b.name}, TrustScore: ${b.trustScore}');
          }
        } else {
          print('HomeProvider: Businesses collection is EMPTY');
        }

        // Sort by trustScore descending for "featured"
        businesses.sort((a, b) => b.trustScore.compareTo(a.trustScore));
        _featuredBusinesses = businesses.take(5).toList();
        print('HomeProvider: Featured businesses count: ${_featuredBusinesses.length}');
        notifyListeners();
      }, onError: (e) {
        print('HomeProvider: Error in businesses stream: $e');
        _error = 'Failed to load businesses';
        notifyListeners();
      });

      // Fetch categories (real-time stream)
      _firestoreService.getCategories().listen((categories) {
        print('HomeProvider: Received ${categories.length} categories');
        _categories = categories;
        notifyListeners();
      }, onError: (e) {
        print('HomeProvider: Error in categories stream: $e');
      });

      // Fetch recent reviews (real-time stream)
      _firestoreService.getRecentReviews().listen((reviews) {
        print('HomeProvider: Received ${reviews.length} recent reviews');
        _recentReviews = reviews;
        notifyListeners();
      }, onError: (e) {
        print('HomeProvider: Error in recent reviews stream: $e');
      });

    } catch (e) {
      print('HomeProvider: General error in _init: $e');
      _error = 'Failed to load home data';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _init();
  }
}
