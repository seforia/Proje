import 'dart:math';
import 'dart:ui';

/// Deterministic reflection physics system
/// Formula: R = D - 2(D·N)N
/// Where R = reflected ray, D = incident ray direction, N = surface normal
class ReflectionSystem {
  /// Calculate reflection vector given incident direction and surface normal
  /// Both vectors should be normalized
  static Offset reflect(Offset incident, Offset normal) {
    // R = D - 2(D·N)N
    final double dotProduct = incident.dx * normal.dx + incident.dy * normal.dy;
    return Offset(
      incident.dx - 2 * dotProduct * normal.dx,
      incident.dy - 2 * dotProduct * normal.dy,
    );
  }

  /// Calculate mirror normal from angle in degrees
  /// Mirror angle 0° = horizontal, normal points upward (+y)
  /// Mirror angle 45° = diagonal, normal points up-right
  static Offset calculateNormal(double angleDeg) {
    final double angleRad = angleDeg * pi / 180;
    // Normal is perpendicular to mirror surface (rotate by 90°)
    return Offset(
      -sin(angleRad), // Normal x component
      cos(angleRad),  // Normal y component (inverted y-axis in Flutter)
    );
  }

  /// Raycast from origin in direction, check collision with mirror
  /// Returns RayHit if collision occurs, null otherwise
  RayHit? castRay({
    required Offset origin,
    required Offset direction,
    required MirrorEntity mirror,
    double maxLength = 1000,
  }) {
    // Mirror line segment endpoints
    final double halfLen = mirror.length / 2;
    final double angleRad = mirror.angleDeg * pi / 180;
    
    final Offset mirrorDir = Offset(cos(angleRad), sin(angleRad));
    final Offset mirrorStart = mirror.position - mirrorDir * halfLen;
    final Offset mirrorEnd = mirror.position + mirrorDir * halfLen;

    // Line-line intersection (ray vs mirror segment)
    final Offset? hitPoint = _lineSegmentIntersection(
      origin,
      origin + direction * maxLength,
      mirrorStart,
      mirrorEnd,
    );

    if (hitPoint == null) return null;

    // Calculate distance
    final double distance = (hitPoint - origin).distance;
    if (distance > maxLength) return null;

    // Calculate reflected direction
    final Offset normal = calculateNormal(mirror.angleDeg);
    final Offset reflected = reflect(direction, normal);

    return RayHit(
      hitPoint: hitPoint,
      distance: distance,
      normal: normal,
      reflectedDirection: reflected,
      hitEntityId: mirror.id,
    );
  }

  /// Trace ray with multiple bounces
  List<RaySegment> traceRay({
    required Offset origin,
    required double angleDeg,
    required List<MirrorEntity> mirrors,
    int maxBounces = 3,
    double maxSegmentLength = 1000,
  }) {
    final List<RaySegment> segments = [];
    Offset currentOrigin = origin;
    Offset currentDirection = Offset(
      cos(angleDeg * pi / 180),
      sin(angleDeg * pi / 180),
    );

    for (int bounce = 0; bounce <= maxBounces; bounce++) {
      RayHit? closestHit;
      double closestDistance = maxSegmentLength;

      // Find closest mirror hit
      for (final mirror in mirrors) {
        final RayHit? hit = castRay(
          origin: currentOrigin,
          direction: currentDirection,
          mirror: mirror,
          maxLength: maxSegmentLength,
        );

        if (hit != null && hit.distance < closestDistance) {
          closestHit = hit;
          closestDistance = hit.distance;
        }
      }

      if (closestHit != null) {
        // Add segment to hit point
        segments.add(RaySegment(
          start: currentOrigin,
          end: closestHit.hitPoint,
          bounceIndex: bounce,
        ));

        // Continue from hit point in reflected direction
        currentOrigin = closestHit.hitPoint;
        currentDirection = closestHit.reflectedDirection;
      } else {
        // No hit, add final segment
        segments.add(RaySegment(
          start: currentOrigin,
          end: currentOrigin + currentDirection * maxSegmentLength,
          bounceIndex: bounce,
        ));
        break;
      }
    }

    return segments;
  }

  /// Check if ray hits target circle
  static bool hitsTarget({
    required List<RaySegment> rayPath,
    required Offset targetPosition,
    required double targetRadius,
  }) {
    for (final segment in rayPath) {
      if (_lineCircleIntersection(
        segment.start,
        segment.end,
        targetPosition,
        targetRadius,
      )) {
        return true;
      }
    }
    return false;
  }

  /// Line segment intersection (2D)
  static Offset? _lineSegmentIntersection(
    Offset a1,
    Offset a2,
    Offset b1,
    Offset b2,
  ) {
    final double denom = (b2.dy - b1.dy) * (a2.dx - a1.dx) -
        (b2.dx - b1.dx) * (a2.dy - a1.dy);

    if (denom.abs() < 1e-10) return null; // Parallel lines

    final double ua = ((b2.dx - b1.dx) * (a1.dy - b1.dy) -
            (b2.dy - b1.dy) * (a1.dx - b1.dx)) /
        denom;

    final double ub = ((a2.dx - a1.dx) * (a1.dy - b1.dy) -
            (a2.dy - a1.dy) * (a1.dx - b1.dx)) /
        denom;

    if (ua < 0 || ua > 1 || ub < 0 || ub > 1) return null;

    return Offset(
      a1.dx + ua * (a2.dx - a1.dx),
      a1.dy + ua * (a2.dy - a1.dy),
    );
  }

  /// Line-circle intersection check
  static bool _lineCircleIntersection(
    Offset lineStart,
    Offset lineEnd,
    Offset circleCenter,
    double radius,
  ) {
    final Offset d = lineEnd - lineStart;
    final Offset f = lineStart - circleCenter;

    final double a = d.dx * d.dx + d.dy * d.dy;
    final double b = 2 * (f.dx * d.dx + f.dy * d.dy);
    final double c = f.dx * f.dx + f.dy * f.dy - radius * radius;

    double discriminant = b * b - 4 * a * c;
    if (discriminant < 0) return false;

    discriminant = sqrt(discriminant);
    final double t1 = (-b - discriminant) / (2 * a);
    final double t2 = (-b + discriminant) / (2 * a);

    return (t1 >= 0 && t1 <= 1) || (t2 >= 0 && t2 <= 1);
  }
}

/// Ray hit information
class RayHit {
  final Offset hitPoint;
  final double distance;
  final Offset normal;
  final Offset reflectedDirection;
  final String hitEntityId;

  RayHit({
    required this.hitPoint,
    required this.distance,
    required this.normal,
    required this.reflectedDirection,
    required this.hitEntityId,
  });
}

/// Ray segment (start to end, with bounce index)
class RaySegment {
  final Offset start;
  final Offset end;
  final int bounceIndex;

  RaySegment({
    required this.start,
    required this.end,
    required this.bounceIndex,
  });
}

/// Simplified mirror entity for raycast
class MirrorEntity {
  final String id;
  final Offset position;
  final double angleDeg;
  final double length;

  MirrorEntity({
    required this.id,
    required this.position,
    required this.angleDeg,
    required this.length,
  });
}
