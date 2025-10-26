import 'body_parts.dart';

// Tuple that will be used in class Frame
class Pair {
  final BodyParts start;
  final BodyParts end;

  const Pair(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      other is Pair &&
      other.start.index == start.index &&
      other.end.index == end.index;

  @override
  int get hashCode => Object.hash(start.index, end.index);

  @override
  String toString() {
    return "Pair(start: ${start.name}, end: ${end.name})";
  }
}