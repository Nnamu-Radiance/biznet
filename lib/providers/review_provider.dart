import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/review_model.dart';
import '../data/services/firestore_service.dart';

class ReviewProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> postReview({
    required String businessId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
    String? photoUrl,
    String? productId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final review = ReviewModel(
        id: _uuid.v4(),
        businessId: businessId,
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating.toInt(),
        text: comment,
        imageUrl: photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.postReview(review);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Post review error: $e');
      _error = 'Failed to post review';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
