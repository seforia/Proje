import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/game_template.dart';

class QuestionDisplayComponent extends PositionComponent {
  final Question question;
  final Function(String) onAnswerSelected;
  String? selectedAnswerId;

  QuestionDisplayComponent({
    required this.question,
    required this.onAnswerSelected,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(600, 200),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw question background
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(12),
      ),
      bgPaint,
    );

    // Draw question text
    final questionPainter = TextPainter(
      text: TextSpan(
        text: question.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: size.x - 40);

    questionPainter.paint(canvas, const Offset(20, 20));

    // Draw answer buttons
    double answerY = 70;
    double answerHeight = 35;
    double answerSpacing = 10;

    for (var i = 0; i < question.answers.length; i++) {
      final answer = question.answers[i];
      final isSelected = selectedAnswerId == answer.id;
      final isCorrect = answer.id == question.correctAnswerId;

      // Button background
      final buttonPaint = Paint()
        ..color = isSelected
            ? (isCorrect ? Colors.green : Colors.red)
            : Colors.blue.shade700
        ..style = PaintingStyle.fill;

      final buttonRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          20,
          answerY + (i * (answerHeight + answerSpacing)),
          size.x - 40,
          answerHeight,
        ),
        const Radius.circular(8),
      );

      canvas.drawRRect(buttonRect, buttonPaint);

      // Button border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(buttonRect, borderPaint);

      // Answer text
      final answerPainter = TextPainter(
        text: TextSpan(
          text: '${String.fromCharCode(65 + i)}) ${answer.text}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.x - 60);

      answerPainter.paint(
        canvas,
        Offset(
          30,
          answerY + (i * (answerHeight + answerSpacing)) + 8,
        ),
      );
    }
  }

  void selectAnswer(String answerId) {
    selectedAnswerId = answerId;
    onAnswerSelected(answerId);
  }
}
