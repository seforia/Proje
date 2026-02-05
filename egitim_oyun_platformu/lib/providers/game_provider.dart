import 'package:flutter/material.dart';
import '../models/game_template.dart';
import '../models/game_metadata.dart';
import '../services/ai/gemini_service.dart';
import '../services/firebase/firestore_service.dart';

class GameProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final FirestoreService _firestoreService = FirestoreService();

  GameTemplate? _currentGame;
  List<GameMetadata> _feedGames = [];
  bool _isGenerating = false;
  bool _isLoadingFeed = false;
  String? _error;

  GameTemplate? get currentGame => _currentGame;
  List<GameMetadata> get feedGames => _feedGames;
  bool get isGenerating => _isGenerating;
  bool get isLoadingFeed => _isLoadingFeed;
  String? get error => _error;

  // Generate new game using AI
  Future<bool> generateGame({
    required String subject,
    required String topic,
    required String age,
    required String difficulty,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      _currentGame = await _geminiService.generateGame(
        subject: subject,
        topic: topic,
        age: age,
        difficulty: difficulty,
      );
      _isGenerating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  // Use sample game for testing
  void useSampleGame() {
    _currentGame = _geminiService.getSampleGame();
    notifyListeners();
  }

  // Save game to Firebase
  Future<String?> saveGame(String userId, String userName) async {
    if (_currentGame == null) return null;

    try {
      final gameId = await _firestoreService.saveGame(
        _currentGame!,
        userId,
        userName,
      );
      return gameId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Clear current game
  void clearGame() {
    _currentGame = null;
    _error = null;
    notifyListeners();
  }

  // Load game feed
  void loadGameFeed() {
    _isLoadingFeed = true;
    notifyListeners();

    _firestoreService.getGameFeed(limit: 20).listen(
      (games) {
        _feedGames = games;
        _isLoadingFeed = false;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoadingFeed = false;
        notifyListeners();
      },
    );
  }

  // Toggle like
  Future<void> toggleLike(String userId, String gameId, bool isLiked) async {
    try {
      await _firestoreService.toggleLike(userId, gameId, !isLiked);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Record game play
  Future<void> recordGamePlay({
    required String userId,
    required String gameId,
    required int score,
    required bool completed,
    required int duration,
  }) async {
    try {
      await _firestoreService.recordGamePlay(
        userId: userId,
        gameId: gameId,
        score: score,
        completed: completed,
        duration: duration,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
