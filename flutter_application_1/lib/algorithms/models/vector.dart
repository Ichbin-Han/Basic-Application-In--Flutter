import 'dart:math';
import './body_parts.dart';
import 'landmark.dart';

class Vector {
  late final String name;

  late final double x, y, z;
  late final double length;

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
  }

  /// Build Unit Vector based on [vector]
  Vector.unitVector(Vector vector) {
    x = vector.x / vector.length;
    y = vector.y / vector.length;
    z = vector.z / vector.length;
    length = 1.0;
    name = "Unit ${vector.name}";
  }

  double _getLength(double x, double y, double z) =>
      sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));

  double dotProduct(Vector v) => x * v.x + y * v.y + z * v.z;

  Vector crossProduct(Vector v) => Vector(
    y * v.z - z * v.y, 
    z * v.x - x * v.z, 
    x * v.y - y * v.x
  );

  @override
  String toString() =>
      "Vector(name: $name, x: $x, y: $y, z: $z, length: $length)";

  Vector copyWith({
    String? name,
    double? x,
    double? y,
    double? z,
    BodyParts? start,
    BodyParts? end,
  }) => Vector(x ?? this.x, y ?? this.y, z ?? this.z, name: name ?? this.name);

  // Overriding arith operators
  Vector operator +(Vector v) => Vector(x + v.x, y + v.y, z + v.z);
  Vector operator -(Vector v) => Vector(x - v.x, y - v.y, z - v.z);
  Vector operator *(Vector v) => Vector(x * v.x, y * v.y, z * v.z);
  Vector operator /(Vector v) => Vector(x / v.x, y / v.y, z / v.z);
}
