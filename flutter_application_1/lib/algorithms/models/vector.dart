import 'dart:math';
import 'landmark.dart';

class Vector {
  late final String name;

  late final double x, y, z;
  late final double length;

  late final double angleXYDeg;
  late final double angleZDeg;

  Vector(this.x, this.y, this.z, {this.name = "vector"}) {
    length = _getLength(x, y, z);
  }

  /// Build Vector based on [start] and [end]
  Vector.fromLandmarks(Landmark start, Landmark end) {
    x = end.x - start.x;
    y = end.y - start.y;
    z = end.z - start.z;
    length = _getLength(x, y, z);
    name = '${start.name}-->${end.name}';
    angleXYDeg = atan2(y, x) * 180 / pi;
    angleZDeg = atan2(z, sqrt(x * x + y * y)) * 180 / pi;
  }

  /// Build Unit Vector based on [vector]
  Vector.unitVector(Vector vector) {
    x = vector.x / vector.length;
    y = vector.y / vector.length;
    z = vector.z / vector.length;
    length = 1.0;
    name = "Unit ${vector.name}";
    angleXYDeg = atan2(y, x) * 180 / pi;
    angleZDeg = atan2(z, sqrt(x * x + y * y)) * 180 / pi;
  }

  /// Magnitude
  double _getLength(double x, double y, double z) =>
      sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));

  /// Dot Product
  double dotProduct(Vector v) => x * v.x + y * v.y + z * v.z;

  /// Returns [Vector] that is perpendicular
  Vector crossProduct(Vector v) =>
      Vector(y * v.z - z * v.y, z * v.x - x * v.z, x * v.y - y * v.x);

  /// Returns direction [String]
  String directionLabel() {
    if (length < 0.02) return 'stable';

    final xDir = x > 0.05
        ? 'right'
        : x < -0.05
        ? 'left'
        : ' ';
    final yDir = x > 0.05
        ? 'up'
        : x < -0.05
        ? 'down'
        : ' ';
    final zDir = x > 0.05
        ? 'forward'
        : x < -0.05
        ? 'backward'
        : ' ';

    return "$xDir-$yDir-$zDir";
  }

  /// Returns level of strength [String]
  String strengthLabel() {
    if (length < 0.02) return 'very slightly';
    if (length < 0.06) return 'slightly';
    if (length < 0.15) return 'moderately';
    return 'strongly';
  }

  /// Returns strength plus direction [String]
  String shortHint() {
    final d = directionLabel();
    if (d == 'no movement') return 'no movement';
    return '${strengthLabel()} $d';
  }

  @override
  String toString() =>
      "Vector(name: $name, x: $x, y: $y, z: $z, length: $length, angleXYDeg: $angleXYDeg, angleZDeg: $angleZDeg)";

  Vector copyWith({String? name, double? x, double? y, double? z}) =>
      Vector(x ?? this.x, y ?? this.y, z ?? this.z, name: name ?? this.name);

  // Overriding arith operators
  Vector operator +(Vector v) => Vector(x + v.x, y + v.y, z + v.z);
  Vector operator -(Vector v) => Vector(x - v.x, y - v.y, z - v.z);
  Vector operator *(Vector v) => Vector(x * v.x, y * v.y, z * v.z);
  Vector operator /(Vector v) => Vector(x / v.x, y / v.y, z / v.z);
}
