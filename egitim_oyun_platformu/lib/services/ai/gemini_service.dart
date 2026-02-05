import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import '../../models/game_template.dart';

class GeminiService {
  // Prefer a secure backend proxy in production. Do NOT commit API keys to source control.
  // For quick local testing you can pass the key with --dart-define=GEMINI_API_KEY="KEY"
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  // Optional backend proxy URL: --dart-define=GEMINI_BACKEND_URL="https://..."
  static const String _backendUrl = String.fromEnvironment('GEMINI_BACKEND_URL', defaultValue: '');
  late final GenerativeModel? _model;

  GeminiService() {
    if (_apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );
    } else {
      _model = null;
    }
  }

  static const String _promptTemplate = '''
Sen eğitim oyunu tasarım uzmanı bir AI'sın.

GÖREVİN:
- Verilen konu için JSON-tabanlı mini oyun/simülasyon senaryosu üret
- Etkileşimli öğrenmeye odaklan
- Adım adım zorluk artış sağla
- Öğretici ipuçları ve kural açıklamaları ekle

ÖNEMLİ: Motor kodu YAZMA. Sadece senaryo JSON'u üret.

KONU: {subject} - {topic}
YAŞ: {age}
ZORLUK: {difficulty}

ÇıKTı FORMATI (SEÇ):

1) QUIZ_RUNNER (koşarak soru cevaplama):
{
  "gameType": "quiz_runner",
  "subject": "...", "topic": "...", "title": "...", "description": "...", "difficulty": "...",
  "config": {"duration": 60, "targetScore": 100, "timeLimit": true},
  "entities": [
    {"id": "player1", "type": "player", "sprite": "astronaut_blue", "properties": {"jumpHeight": 150}},
    {"id": "obstacle1", "type": "obstacle", "sprite": "meteor_rock"}
  ],
  "questions": [
    {"id": "q1", "text": "3 x 4 = ?", "answers": [{"id": "a1", "text": "12"}, {"id": "a2", "text": "7"}], "correctAnswerId": "a1", "points": 10}
  ],
  "pedagogy": {"concept": "Çarpım tablosu", "hint": "Çarpım, tekrarlı toplamadır", "explain": "3 x 4 = 3+3+3+3"}
}

2) MIRROR_REFLECTION (ayna simülasyonu):
{
  "meta": {"id": "sim_mirror_v1", "title": "Düzlem Aynada Yansıma", "subject": "Fizik", "topic": "Düzlem Ayna", "gradeBand": "9-10", "difficulty": "kolay", "language": "tr"},
  "simulation": {
    "scene": {"width": 800, "height": 600, "background": "#0A0A2E", "grid": {"enabled": true, "size": 20}},
    "entities": [
      {"id": "light1", "type": "light_source", "position": {"x": 100, "y": 300}, "angleDeg": 0, "draggable": true, "rotatable": true},
      {"id": "mirror1", "type": "mirror", "position": {"x": 400, "y": 300}, "angleDeg": 45, "draggable": true, "rotatable": true, "properties": {"length": 180}},
      {"id": "target1", "type": "target", "position": {"x": 680, "y": 240}, "properties": {"radius": 22}}
    ],
    "rules": {"reflection": {"enabled": true, "law": "angle_in_equals_angle_out"}, "ray": {"maxBounces": 1, "maxLength": 1000}}
  },
  "goals": [{"id": "goal1", "type": "hit_target", "targetId": "target1"}],
  "constraints": {"maxMoves": 5, "timeLimitSec": 90},
  "scoring": {"base": 100, "timeBonusPerSec": 1, "movePenalty": 5, "precisionBonus": {"enabled": true, "thresholdPx": 6, "bonus": 25}},
  "pedagogy": {
    "concept": "Gelme açısı = yansıma açısı", 
    "hint": "Aynayı saat yönünde çevir", 
    "explain": "Işın, ayna normaline göre eş açıyla yansır",
    "tutorialSteps": ["Aynayı 10° çevir", "Işını hedefe yönlendir", "Kuralı doğrula"]
  }
}

SADECE JSON ÇıKTıSı VER. Açıklama yapma.
''';

  Future<GameTemplate> generateGame({
    required String subject,
    required String topic,
    required String age,
    required String difficulty,
  }) async {
    // If no API key, return sample game directly
    if (_apiKey.isEmpty && _backendUrl.isEmpty) {
      return getSampleGame();
    }

    try {
      final prompt = _promptTemplate
          .replaceAll('{subject}', subject)
          .replaceAll('{topic}', topic)
          .replaceAll('{age}', age)
          .replaceAll('{difficulty}', difficulty);

      // If a backend URL is provided, call it (keeps key server-side)
      if (_backendUrl.isNotEmpty) {
        final uri = Uri.parse('$_backendUrl/generateGame');
        final res = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt}));
        if (res.statusCode != 200) {
          // Fallback to sample game on error
          return getSampleGame();
        }
        final map = json.decode(res.body);
        final jsonString = map['json'] as String? ?? '';
        final jsonData = json.decode(jsonString);
        return GameTemplate.fromJson(jsonData);
      }

      if (_model == null) {
        // No API key, use sample game
        return getSampleGame();
      }

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        // AI didn't respond, use sample game
        return getSampleGame();
      }

      // Extract JSON from response
      final jsonString = _extractJson(response.text!);
      final jsonData = json.decode(jsonString);

      return GameTemplate.fromJson(jsonData);
    } catch (e) {
      // On any error, return sample game instead of throwing
      return getSampleGame();
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

  // Sample mirror reflection simulation
  Map<String, dynamic> getSampleMirrorSimulation() {
    return {
      "meta": {
        "id": "sim_mirror_basic_v1",
        "title": "Düzlem Aynada Yansıma - Temel",
        "subject": "Fizik",
        "topic": "Düzlem Ayna",
        "gradeBand": "9-10",
        "difficulty": "kolay",
        "language": "tr"
      },
      "simulation": {
        "scene": {
          "width": 800,
          "height": 600,
          "background": "#0A0A2E",
          "grid": {"enabled": true, "size": 20}
        },
        "entities": [
          {
            "id": "light1",
            "type": "light_source",
            "position": {"x": 100, "y": 300},
            "angleDeg": 0,
            "draggable": true,
            "rotatable": true
          },
          {
            "id": "mirror1",
            "type": "mirror",
            "position": {"x": 400, "y": 300},
            "angleDeg": 45,
            "draggable": true,
            "rotatable": true,
            "properties": {"length": 180}
          },
          {
            "id": "target1",
            "type": "target",
            "position": {"x": 680, "y": 240},
            "properties": {"radius": 22}
          }
        ],
        "rules": {
          "reflection": {"enabled": true, "law": "angle_in_equals_angle_out"},
          "ray": {"maxBounces": 1, "maxLength": 1000}
        }
      },
      "goals": [
        {"id": "goal1", "type": "hit_target", "targetId": "target1"}
      ],
      "constraints": {"maxMoves": 5, "timeLimitSec": 90},
      "scoring": {
        "base": 100,
        "timeBonusPerSec": 1,
        "movePenalty": 5,
        "precisionBonus": {"enabled": true, "thresholdPx": 6, "bonus": 25}
      },
      "pedagogy": {
        "concept": "Gelme açısı = yansıma açısı",
        "hint": "Aynayı saat yönünde çevir",
        "explain":
            "Işık, ayna yüzeyine dik doğruya (normal) göre eş açılarla gelir ve yansır. Bu, yansıma yasasıdır.",
        "tutorialSteps": [
          "Aynayı 10° çevirerek ışını hedefe yönlendir",
          "Işık kaynağını hareket ettir",
          "Gelme açısı ve yansıma açısını karşılaştır"
        ]
      }
    };
  }
}
