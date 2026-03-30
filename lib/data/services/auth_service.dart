import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final FirebaseFirestore _db;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService() {
    print('AuthService: Initializing Firestore with default database');
    _db = FirebaseFirestore.instance;
  }

  void _handleFirestoreError(dynamic error, String operation, String path) {
    final errInfo = {
      'error': error.toString(),
      'operationType': operation,
      'path': path,
      'authInfo': {
        'userId': _auth.currentUser?.uid,
        'email': _auth.currentUser?.email,
        'emailVerified': _auth.currentUser?.emailVerified,
        'isAnonymous': _auth.currentUser?.isAnonymous,
      }
    };
    print('Firestore Error: ${jsonEncode(errInfo)}');
    throw Exception(jsonEncode(errInfo));
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Create user document in Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
        } catch (e) {
          _handleFirestoreError(e, 'write', 'users/${user.uid}');
        }

        // If user is a business, create a business document
        if (role == 'business') {
          final businessId = 'biz_${user.uid}';
          final newBusiness = {
            'id': businessId,
            'ownerId': user.uid,
            'name': name,
            'description': 'Welcome to $name! We are excited to serve you.',
            'logoUrl': null,
            'ecommerceLink': null,
            'trustScore': 5.0, // Initial trust score
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          };
          try {
            await _db.collection('businesses').doc(businessId).set(newBusiness);
          } catch (e) {
            _handleFirestoreError(e, 'write', 'businesses/$businessId');
          }
        }
      }
      return result;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Login with email and password
  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null && !result.user!.emailVerified) {
        // Optionally resend verification if needed, but for now we just return the result
        // The provider will handle the check
      }

      return result;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle({String? role}) async {
    try {
      // Ensure fresh sign in by signing out first
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot doc;
        try {
          doc = await _db.collection('users').doc(user.uid).get();
        } catch (e) {
          _handleFirestoreError(e, 'get', 'users/${user.uid}');
          return null; // Should not reach here
        }

        if (!doc.exists) {
          // Create new user if they don't exist
          UserModel newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            role: role ?? 'customer', // Use provided role or default to customer
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          try {
            await _db.collection('users').doc(user.uid).set(newUser.toMap());
          } catch (e) {
            _handleFirestoreError(e, 'write', 'users/${user.uid}');
          }

          // If user is a business, create a business document
          if (role == 'business') {
            final businessId = 'biz_${user.uid}';
            final newBusiness = {
              'id': businessId,
              'ownerId': user.uid,
              'name': user.displayName ?? 'My Beauty Business',
              'description': 'Welcome to our business! We are excited to serve you.',
              'logoUrl': user.photoURL,
              'ecommerceLink': null,
              'trustScore': 5.0, // Initial trust score
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            };
            try {
              await _db.collection('businesses').doc(businessId).set(newBusiness);
            } catch (e) {
              _handleFirestoreError(e, 'write', 'businesses/$businessId');
            }
          }
        } else {
          // User exists, check if they are a business and if business doc exists
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          if (userData['role'] == 'business') {
            final businessId = 'biz_${user.uid}';
            DocumentSnapshot bizDoc;
            try {
              bizDoc = await _db.collection('businesses').doc(businessId).get();
            } catch (e) {
              _handleFirestoreError(e, 'get', 'businesses/$businessId');
              return null; // Should not reach here
            }

            if (!bizDoc.exists) {
              final newBusiness = {
                'id': businessId,
                'ownerId': user.uid,
                'name': userData['name'] ?? user.displayName ?? 'My Beauty Business',
                'description': 'Welcome to our business! We are excited to serve you.',
                'logoUrl': user.photoURL,
                'ecommerceLink': null,
                'trustScore': 5.0,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              };
              try {
                await _db.collection('businesses').doc(businessId).set(newBusiness);
              } catch (e) {
                _handleFirestoreError(e, 'write', 'businesses/$businessId');
              }
            }
          }
        }
      }
      return result;
    } catch (e) {
      print('Google Sign-In error: $e');
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Update user data in Firestore
  Future<void> updateUserData(UserModel user) async {
    try {
      await _db.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Update user data error: $e');
      rethrow;
    }
  }
}
