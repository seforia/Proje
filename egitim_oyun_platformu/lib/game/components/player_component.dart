import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class PlayerComponent extends PositionComponent with CollisionCallbacks {
  final String spriteName;
  final double jumpHeight;
  double velocityY = 0;
  bool isJumping = false;
  bool isOnGround = true;

  static const double gravity = 800;
  static const double groundLevel = 400;

  PlayerComponent({
    required this.spriteName,
    this.jumpHeight = 150,
  }) : super(
          size: Vector2(50, 50),
          position: Vector2(100, groundLevel),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision hitbox
    add(RectangleHitbox()..debugMode = false);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    velocityY += gravity * dt;
    position.y += velocityY * dt;

    // Ground collision
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocityY = 0;
      isJumping = false;
      isOnGround = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Simple colored square for MVP (replace with sprite later)
    final paint = Paint()
      ..color = _getSpriteColor(spriteName)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Add simple face
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), 5, eyePaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), 5, eyePaint);
    
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), 2, pupilPaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.3), 2, pupilPaint);
  }

  void jump() {
    if (isOnGround && !isJumping) {
      velocityY = -jumpHeight * 3;
      isJumping = true;
      isOnGround = false;
    }
  }

  Color _getSpriteColor(String name) {
    if (name.contains('blue')) return Colors.blue;
    if (name.contains('green')) return Colors.green;
    if (name.contains('orange')) return Colors.orange;
    if (name.contains('red')) return Colors.red;
    if (name.contains('purple')) return Colors.purple;
    return Colors.cyan;
  }
}
