import '../models/vector.dart';
import '../models/landmark.dart';
import '../models/body_parts.dart';
import '../models/pair.dart';

/// Returns a list of [vectors] between given body parts.
///
/// [landmarks] - map that contains keys(index of body part) and values([Landmark]).
///
/// [sequence] - string that describes sequence of creating vectors.
///
/// `sequence` format:
/// - segments are splitted by symbol `>`.
/// - each segment can have multiple indeces using `&`.
///
/// Examples: `"0>1&2>3>4"`
/// - Connects landmark[0] with landmark[1] and landmark[2], two vectors are just created.
/// - Next, it connects landmark[1] and landmark[2] with landmark[3], two vector are just created.
/// - Next, it connects landmark[3] with landmark[4], one vector is just created.
/// - It returns 5 vectors in total.
List<Vector> createVectorsBodyPartsBySequence(
  Map<int, Landmark> landmarks,
  String sequence,
) {
  final regex = RegExp(r'^(\d+(&\d+)*)(>(\d+(&\d+)*))*$');

  if (!regex.hasMatch(sequence)) {
    throw Exception("Sequence has an incorrect format");
  }

  List<List<Landmark?>> targetLandmarks = sequence
      .split('>')
      .map(
        (segment) => segment
            .split('&')
            .map((indexStr) => landmarks[int.parse(indexStr)])
            .toList(),
      )
      .toList();

  List<Vector> vectors = [];
  for (var i = 0; i < targetLandmarks.length - 1; i++) {
    for (var first in targetLandmarks[i]) {
      for (var second in targetLandmarks[i + 1]) {
        vectors.add(Vector.fromLandmarks(first!, second!));
      }
    }
  }

  return vectors;
}

Map<Pair, Vector> createVectorsBodyParts(List<Landmark> landmarksSequence) {
  Map<Pair, Vector> vectors = {};
  var current = landmarksSequence.first;

  for (var i = 1; i < landmarksSequence.length; i++) {
    final next = landmarksSequence[i];

    final v = Vector.fromLandmarks(current, next);

    vectors[Pair(
          BodyParts.values[current.index],
          BodyParts.values[next.index],
        )] =
        v;

    current = next;
  }
  return vectors;
}
