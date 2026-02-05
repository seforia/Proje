import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';
import '../models/user_model.dart';

// DEMO MODE flag - main.dart'tan import edilebilir
const bool DEMO_MODE = true;

class AuthProvider extends ChangeNotifier {
  late final AuthService? _authService;
  late final FirestoreService? _firestoreService;

  User? _user;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => DEMO_MODE ? true : _user != null;

  AuthProvider() {
    if (DEMO_MODE) {
      // Demo modda Firebase servisleri initialize etme
      _authService = null;
      _firestoreService = null;
      // Demo kullanıcı profili
      _userProfile = UserModel(
        id: 'demo_user',
        name: 'Demo Kullanıcı',
        email: 'demo@example.com',
        avatarUrl: null,
        createdAt: DateTime.now(),
        gamesCreated: 5,
        totalScore: 1250,
      );
    } else {
      _authService = AuthService();
      _firestoreService = FirestoreService();
      _authService!.authStateChanges.listen((user) {
        _user = user;
        if (user != null) {
          _loadUserProfile(user.uid);
        } else {
          _userProfile = null;
        }
        notifyListeners();
      });
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    if (DEMO_MODE) return;
    try {
      _userProfile = await _firestoreService!.getUserProfile(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Kullanıcı profili yüklenemedi: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (DEMO_MODE) {
      // Demo modda giriş her zaman başarılı
      return true;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    if (DEMO_MODE) {
      // Demo modda kayıt her zaman başarılı
      return true;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _authService!.registerWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestoreService!.createUserProfile(
        userCredential.user!.uid,
        name,
        email,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    if (DEMO_MODE) return;
    await _authService!.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    if (DEMO_MODE) {
      // Demo modda şifre sıfırlama simülasyonu
      return true;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
