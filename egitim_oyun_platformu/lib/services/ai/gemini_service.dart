import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/game_template.dart';

class GeminiService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // TODO: .env'den al
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  static const String _promptTemplate = '''
Sen bir eğitim oyunu tasarım uzmanısın. Verilen konu için JSON formatında basit bir 2D eğitim oyunu oluştur.

KONU: {subject} - {topic}
HEDEF YAŞ: {age}
ZORLUK: {difficulty}

KURALLAR:
1. Oyun türü "quiz_runner", "collector" veya "puzzle" olabilir
2. 3-5 eğitsel soru ekle
3. Her soru için 3 şık oluştur (1 doğru, 2 yanlış)
4. Türkçe kullan
5. Yaş grubuna uygun kelimeler seç
6. Sprite isimleri İngilizce olmalı (varolan asset'lerden: astronaut_blue, robot_green, cat_orange, meteor_rock, tree_green, apple_red, coin_gold)
7. Tema şunlardan biri olmalı: space, forest, underwater, desert, city

SADECE JSON ÇıKTıSı VER. Açıklama yapma. Bu şemayı kullan:

{
  "gameType": "quiz_runner",
  "subject": "...",
  "topic": "...",
  "title": "...",
  "description": "...",
  "difficulty": "kolay/orta/zor",
  "config": {
    "duration": 60,
    "targetScore": 100,
    "speed": 1.0,
    "timeLimit": true
  },
  "entities": [
    {"id": "player1", "type": "player", "name": "...", "sprite": "astronaut_blue", "properties": {"jumpHeight": 150}},
    {"id": "obstacle1", "type": "obstacle", "name": "...", "sprite": "meteor_rock"}
  ],
  "questions": [
    {
      "id": "q1",
      "text": "...",
      "answers": [
        {"id": "a1", "text": "..."},
        {"id": "a2", "text": "..."},
        {"id": "a3", "text": "..."}
      ],
      "correctAnswerId": "a1",
      "points": 10
    }
  ],
  "aesthetics": {
    "theme": "space",
    "backgroundColor": "#0a0a2e",
    "primaryColor": "#00d9ff"
  }
}
''';

  Future<GameTemplate> generateGame({
    required String subject,
    required String topic,
    required String age,
    required String difficulty,
  }) async {
    try {
      final prompt = _promptTemplate
          .replaceAll('{subject}', subject)
          .replaceAll('{topic}', topic)
          .replaceAll('{age}', age)
          .replaceAll('{difficulty}', difficulty);

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('AI yanıt vermedi');
      }

      // Extract JSON from response
      final jsonString = _extractJson(response.text!);
      final jsonData = json.decode(jsonString);

      return GameTemplate.fromJson(jsonData);
    } catch (e) {
      throw Exception('Oyun üretilemedi: $e');
    }
  }

  String _extractJson(String response) {
    // Remove markdown code blocks if present
    String cleaned = response.trim();

    // Remove ```json and ``` if present
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }

    cleaned = cleaned.trim();

    // Find the first { and last }
    final firstBrace = cleaned.indexOf('{');
    final lastBrace = cleaned.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      return cleaned.substring(firstBrace, lastBrace + 1);
    }

    return cleaned;
  }

  // Test method with sample game
  GameTemplate getSampleGame() {
    final sampleJson = {
      "gameType": "quiz_runner",
      "subject": "Matematik",
      "topic": "Çarpım Tablosu",
      "title": "Uzay Çarpımı",
      "description": "Uzayda koşarak çarpım sorularını çöz!",
      "difficulty": "kolay",
      "config": {
        "duration": 60,
        "targetScore": 100,
        "speed": 1.0,
        "timeLimit": true
      },
      "entities": [
        {
          "id": "player1",
          "type": "player",
          "name": "Astronot Ali",
          "sprite": "astronaut_blue",
          "properties": {"jumpHeight": 150}
        },
        {
          "id": "obstacle1",
          "type": "obstacle",
          "name": "Meteor",
          "sprite": "meteor_rock",
          "properties": {"damage": 10}
        }
      ],
      "questions": [
        {
          "id": "q1",
          "text": "3 x 4 = ?",
          "answers": [
            {"id": "a1", "text": "12"},
            {"id": "a2", "text": "7"},
            {"id": "a3", "text": "15"}
          ],
          "correctAnswerId": "a1",
          "points": 10
        },
        {
          "id": "q2",
          "text": "5 x 6 = ?",
          "answers": [
            {"id": "a1", "text": "30"},
            {"id": "a2", "text": "25"},
            {"id": "a3", "text": "35"}
          ],
          "correctAnswerId": "a1",
          "points": 10
        },
        {
          "id": "q3",
          "text": "7 x 8 = ?",
          "answers": [
            {"id": "a1", "text": "56"},
            {"id": "a2", "text": "54"},
            {"id": "a3", "text": "64"}
          ],
          "correctAnswerId": "a1",
          "points": 10
        }
      ],
      "aesthetics": {
        "theme": "space",
        "backgroundColor": "#0a0a2e",
        "primaryColor": "#00d9ff"
      }
    };

    return GameTemplate.fromJson(sampleJson);
  }
}
