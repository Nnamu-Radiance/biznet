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
      if (query.isEmpty) {
        _searchResults = await _firestoreService.getAllBusinesses();
      } else {
        _searchResults = await _firestoreService.searchBusinesses(query);
      }
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
    } catch (e) {
      print('Category Search error: $e');
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllBusinesses() async {
    if (_query.isNotEmpty) return; // don't override if already searching

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _firestoreService.getAllBusinesses();
    } catch (e) {
      print('Load all businesses error: $e');
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    notifyListeners();
    loadAllBusinesses();
  }
}
