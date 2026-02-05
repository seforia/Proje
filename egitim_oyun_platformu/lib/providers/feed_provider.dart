import 'package:flutter/material.dart';
import '../models/game_metadata.dart';
import '../services/firebase/firestore_service.dart';

const bool DEMO_MODE = true;

class FeedProvider extends ChangeNotifier {
  late final FirestoreService? _firestoreService;

  List<GameMetadata> _games = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedSubject;

  List<GameMetadata> get games => _games;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedSubject => _selectedSubject;

  FeedProvider() {
    if (!DEMO_MODE) {
      _firestoreService = FirestoreService();
    } else {
      _firestoreService = null;
    }
  }

  void loadFeed({String? subject}) {
    if (DEMO_MODE) {
      // Demo modda boş feed
      _games = [];
      return;
    }
    _isLoading = true;
    _selectedSubject = subject;
    notifyListeners();

    final stream = subject == null
        ? _firestoreService!.getGameFeed(limit: 20)
        : _firestoreService!.getGamesBySubject(subject, limit: 20);

    stream.listen(
      (games) {
        _games = games;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> isGameLiked(String userId, String gameId) async {
    if (DEMO_MODE) return false;
    try {
      return await _firestoreService!.isGameLiked(userId, gameId);
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
