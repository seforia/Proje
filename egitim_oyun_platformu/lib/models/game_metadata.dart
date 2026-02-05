import 'package:cloud_firestore/cloud_firestore.dart';

class GameMetadata {
  final String id;
  final String creatorId;
  final String creatorName;
  final String subject;
  final String topic;
  final String title;
  final String? thumbnail;
  final String difficulty;
  final int plays;
  final int likes;
  final DateTime createdAt;
  final bool isPublic;
  final Map<String, dynamic> gameData;

  GameMetadata({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.subject,
    required this.topic,
    required this.title,
    this.thumbnail,
    required this.difficulty,
    this.plays = 0,
    this.likes = 0,
    required this.createdAt,
    this.isPublic = true,
    required this.gameData,
  });

  factory GameMetadata.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameMetadata(
      id: doc.id,
      creatorId: data['creatorId'] as String,
      creatorName: data['creatorName'] as String,
      subject: data['subject'] as String,
      topic: data['topic'] as String,
      title: data['title'] as String,
      thumbnail: data['thumbnail'] as String?,
      difficulty: data['difficulty'] as String,
      plays: data['plays'] as int? ?? 0,
      likes: data['likes'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] as bool? ?? true,
      gameData: data['gameData'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'subject': subject,
      'topic': topic,
      'title': title,
      'thumbnail': thumbnail,
      'difficulty': difficulty,
      'plays': plays,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublic': isPublic,
      'gameData': gameData,
    };
  }
}

class GamePlay {
  final String id;
  final String userId;
  final String gameId;
  final int score;
  final bool completed;
  final int duration;
  final DateTime playedAt;

  GamePlay({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.score,
    required this.completed,
    required this.duration,
    required this.playedAt,
  });

  factory GamePlay.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GamePlay(
      id: doc.id,
      userId: data['userId'] as String,
      gameId: data['gameId'] as String,
      score: data['score'] as int,
      completed: data['completed'] as bool,
      duration: data['duration'] as int,
      playedAt: (data['playedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'gameId': gameId,
      'score': score,
      'completed': completed,
      'duration': duration,
      'playedAt': Timestamp.fromDate(playedAt),
    };
  }
}
