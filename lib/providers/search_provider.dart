import 'package:flutter/material.dart';
import '../data/models/business_model.dart';
import '../data/services/firestore_service.dart';

class SearchProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<BusinessModel> _searchResults = [];
  bool _isLoading = false;
  String _query = '';

  List<BusinessModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get query => _query;

  Future<void> search(String query) async {
    _query = query;
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _firestoreService.searchBusinesses(query);
    } catch (e) {
      print('Search error: $e');
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchByCategory(String categoryId) async {
    _query = 'Category: $categoryId';
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _firestoreService.getBusinessesByCategory(categoryId);
      // Remove any duplicate businesses just in case
      final ids = <String>{};
      _searchResults.retainWhere((b) => ids.add(b.id));

    } catch (e) {
      print('Category Search error: $e');
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _searchResults = [];
    notifyListeners();
  }
}
