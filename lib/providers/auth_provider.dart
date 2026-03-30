import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biznet/data/services/auth_service.dart';
import 'package:biznet/data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  // Use type inference to avoid analyzer issues if the type can't be resolved temporarily
  final _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;
  String? _pendingRole;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmailVerified => _isEmailVerified;
  String? get pendingRole => _pendingRole;

  void setPendingRole(String? role) {
    _pendingRole = role;
    Future.microtask(() => notifyListeners());
  }

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Use microtask to avoid calling notifyListeners during build phase
    Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });

    User? user = _authService.currentUser;
    if (user != null) {
      _isEmailVerified = user.emailVerified;
      try {
        _userModel = await _authService.getUserData(user.uid);
      } catch (e) {
        print('Error fetching user data in init: $e');
      }
    }

    Future.microtask(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserCredential? result = await _authService.login(email, password);
      if (result?.user != null) {
        _isEmailVerified = result!.user!.emailVerified;
        if (!_isEmailVerified) {
          _error = 'Please verify your email address.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        _userModel = await _authService.getUserData(result.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithGoogle({String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserCredential? result = await _authService.signInWithGoogle(role: role);
      if (result?.user != null) {
        _isEmailVerified = result!.user!.emailVerified;
        _userModel = await _authService.getUserData(result.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;
      print('FirebaseAuthException in signInWithGoogle: ${e.code} - ${e.message}');
    } on Exception catch (e) {
      final errorStr = e.toString();
      print('Exception in signInWithGoogle: $errorStr');
      if (errorStr.contains('network_error') || errorStr.contains('unavailable')) {
        _error = 'Network error. Please check your internet connection and Firestore configuration.';
      } else {
        _error = 'An unexpected error occurred: $errorStr';
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
      print('Unknown error in signInWithGoogle: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserCredential? result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (result?.user != null) {
        _isEmailVerified = result!.user!.emailVerified;
        _userModel = await _authService.getUserData(result.user!.uid);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> reloadUser() async {
    User? user = _authService.currentUser;
    if (user != null) {
      await user.reload();
      _isEmailVerified = user.emailVerified;
      if (_isEmailVerified) {
        _userModel = await _authService.getUserData(user.uid);
      }
      notifyListeners();
    }
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    _isEmailVerified = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    String? photoUrl,
    String? bio,
  }) async {
    if (_userModel == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserModel updatedUser = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        name: name,
        role: _userModel!.role,
        photoUrl: photoUrl ?? _userModel!.photoUrl,
        bio: bio ?? _userModel!.bio,
        hasBuiltProfile: _userModel!.hasBuiltProfile,
        createdAt: _userModel!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _authService.updateUserData(updatedUser);
      _userModel = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile';
      print('Update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> markProfileAsBuilt({String? name}) async {
    if (_userModel == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      UserModel updatedUser = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        name: name ?? _userModel!.name,
        role: _userModel!.role,
        photoUrl: _userModel!.photoUrl,
        bio: _userModel!.bio,
        hasBuiltProfile: true,
        createdAt: _userModel!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _authService.updateUserData(updatedUser);
      _userModel = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to mark profile as built';
      print('Mark profile as built error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
