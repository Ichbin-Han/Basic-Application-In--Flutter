class Landmark {
  final int index;
  final String name;
  final double x, y, z, visibility;

  Landmark({
    required this.index,
    required this.name,
    required this.x,
    required this.y,
    required this.z,
    required this.visibility,
  });

  Landmark copyWith({
    int? index,
    String? name,
    double? x,
    double? y,
    double? z,
    double? visibility,
  }) => Landmark(
    index: index ?? this.index,
    name: name ?? this.name,
    x: x ?? this.x,
    y: y ?? this.y,
    z: z ?? this.z,
    visibility: visibility ?? this.visibility,
  );

  @override
  String toString() =>
      'Landmark(index: $index, name: $name, x: $x, y: $y, z: $z, visibility: $visibility)';
}