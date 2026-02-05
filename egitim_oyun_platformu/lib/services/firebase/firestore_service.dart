import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';
import '../../models/game_template.dart';
import '../../models/game_metadata.dart';
import '../../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===== USER OPERATIONS =====

  // Create user profile
  Future<void> createUserProfile(String userId, String name, String email) async {
    await _db.collection(FirebaseConstants.usersCollection).doc(userId).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'gamesCreated': 0,
      'totalScore': 0,
    });
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _db.collection(FirebaseConstants.usersCollection).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection(FirebaseConstants.usersCollection).doc(userId).update(data);
  }

  // ===== GAME OPERATIONS =====

  // Save game
  Future<String> saveGame(
    GameTemplate template,
    String userId,
    String userName,
  ) async {
    final gameData = {
      'creatorId': userId,
      'creatorName': userName,
      'gameData': template.toJson(),
      'subject': template.subject,
      'topic': template.topic,
      'title': template.title,
      'difficulty': template.difficulty,
      'plays': 0,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'isPublic': true,
    };

    final docRef = await _db.collection(FirebaseConstants.gamesCollection).add(gameData);

    // Update user's games created count
    await _db.collection(FirebaseConstants.usersCollection).doc(userId).update({
      'gamesCreated': FieldValue.increment(1),
    });

    return docRef.id;
  }

  // Get game by ID
  Future<GameMetadata?> getGame(String gameId) async {
    final doc = await _db.collection(FirebaseConstants.gamesCollection).doc(gameId).get();
    if (doc.exists) {
      return GameMetadata.fromFirestore(doc);
    }
    return null;
  }

  // Get game feed (latest public games)
  Stream<List<GameMetadata>> getGameFeed({int limit = 20}) {
    return _db
        .collection(FirebaseConstants.gamesCollection)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GameMetadata.fromFirestore(doc)).toList());
  }

  // Get games by subject
  Stream<List<GameMetadata>> getGamesBySubject(String subject, {int limit = 20}) {
    return _db
        .collection(FirebaseConstants.gamesCollection)
        .where('isPublic', isEqualTo: true)
        .where('subject', isEqualTo: subject)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GameMetadata.fromFirestore(doc)).toList());
  }

  // Get user's games
  Stream<List<GameMetadata>> getUserGames(String userId) {
    return _db
        .collection(FirebaseConstants.gamesCollection)
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GameMetadata.fromFirestore(doc)).toList());
  }

  // Delete game
  Future<void> deleteGame(String gameId, String userId) async {
    final game = await getGame(gameId);
    if (game != null && game.creatorId == userId) {
      await _db.collection(FirebaseConstants.gamesCollection).doc(gameId).delete();

      // Update user's games created count
      await _db.collection(FirebaseConstants.usersCollection).doc(userId).update({
        'gamesCreated': FieldValue.increment(-1),
      });
    }
  }

  // ===== GAME PLAY OPERATIONS =====

  // Record game play
  Future<void> recordGamePlay({
    required String userId,
    required String gameId,
    required int score,
    required bool completed,
    required int duration,
  }) async {
    await _db.collection(FirebaseConstants.gamePlaysCollection).add({
      'userId': userId,
      'gameId': gameId,
      'score': score,
      'completed': completed,
      'duration': duration,
      'playedAt': FieldValue.serverTimestamp(),
    });

    // Update game play count
    await _db.collection(FirebaseConstants.gamesCollection).doc(gameId).update({
      'plays': FieldValue.increment(1),
    });

    // Update user's total score
    await _db.collection(FirebaseConstants.usersCollection).doc(userId).update({
      'totalScore': FieldValue.increment(score),
    });
  }

  // Get user's game plays
  Stream<List<GamePlay>> getUserGamePlays(String userId) {
    return _db
        .collection(FirebaseConstants.gamePlaysCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('playedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GamePlay.fromFirestore(doc)).toList());
  }

  // ===== LIKE OPERATIONS =====

  // Toggle like
  Future<void> toggleLike(String userId, String gameId, bool isLiked) async {
    final likeQuery = await _db
        .collection(FirebaseConstants.likesCollection)
        .where('userId', isEqualTo: userId)
        .where('gameId', isEqualTo: gameId)
        .get();

    if (isLiked && likeQuery.docs.isEmpty) {
      // Add like
      await _db.collection(FirebaseConstants.likesCollection).add({
        'userId': userId,
        'gameId': gameId,
        'likedAt': FieldValue.serverTimestamp(),
      });
      await _db.collection(FirebaseConstants.gamesCollection).doc(gameId).update({
        'likes': FieldValue.increment(1),
      });
    } else if (!isLiked && likeQuery.docs.isNotEmpty) {
      // Remove like
      await likeQuery.docs.first.reference.delete();
      await _db.collection(FirebaseConstants.gamesCollection).doc(gameId).update({
        'likes': FieldValue.increment(-1),
      });
    }
  }

  // Check if user liked game
  Future<bool> isGameLiked(String userId, String gameId) async {
    final likeQuery = await _db
        .collection(FirebaseConstants.likesCollection)
        .where('userId', isEqualTo: userId)
        .where('gameId', isEqualTo: gameId)
        .get();

    return likeQuery.docs.isNotEmpty;
  }

  // ===== COMMENT OPERATIONS =====

  // Add comment
  Future<void> addComment({
    required String gameId,
    required String userId,
    required String userName,
    required String text,
  }) async {
    await _db.collection(FirebaseConstants.commentsCollection).add({
      'gameId': gameId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get game comments
  Stream<QuerySnapshot> getGameComments(String gameId) {
    return _db
        .collection(FirebaseConstants.commentsCollection)
        .where('gameId', isEqualTo: gameId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete comment
  Future<void> deleteComment(String commentId, String userId) async {
    final comment = await _db.collection(FirebaseConstants.commentsCollection).doc(commentId).get();
    if (comment.exists && comment.data()?['userId'] == userId) {
      await comment.reference.delete();
    }
  }
}
