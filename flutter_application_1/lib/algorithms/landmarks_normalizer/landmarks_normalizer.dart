import '../models/landmark.dart';
import '../models/vector.dart';
import '../models/body_parts.dart';
import '../models/pair.dart';

/// Returns a map of [normalizedLandmarks], placing [Landmark]s at the same distance from each other
///
/// [landmarksSequence] - map of consecutive [Landmark]s, which are about to be normalized
///
/// [targetDistance] - the distance bewteen neighboring points
///
/// Description: it takes first [Landmark] as the base and places all next [Landmark]s
/// at a distance equal to [targetDistance] in the direction of the vector to the next one
Map<int, Landmark> normalizeLandmarksSequence(
  List<Landmark> landmarksSequence,
  double targetDistance,
) {
  Map<int, Landmark> normalizedLandmarks = {};
  var current = landmarksSequence.first;
  normalizedLandmarks[current.index] = current;

  for (var i = 1; i < landmarksSequence.length; i++) {
    var next = landmarksSequence[i];

    final unitV = Vector.unitVector(Vector.fromLandmarks(current, next));
    next = Landmark(
      index: next.index,
      name: next.name,
      x: current.x + unitV.x * targetDistance,
      y: current.y + unitV.y * targetDistance,
      z: current.z + unitV.z * targetDistance,
      visibility: next.visibility,
    );

    normalizedLandmarks[next.index] = next;
    current = next;
  }
  return normalizedLandmarks;
}

/// Returns a map of normalized [Landmark]s, which have a certain length between them
///
/// [landmarks] - map of [Landmark]s
///
/// [targetDistance] - the distance bewteen neighboring points
///
/// Description: it normalizes [Landmark]s for body parts such as face, torso, hands, legs
Map<int, Landmark> getNormalizedLandmarks(
  Map<int, Landmark> landmarks,
  double targetDistance,
) {
  // Face
  var normRightFace = normalizeLandmarksSequence([
    landmarks[BodyParts.NOSE.index]!,
    landmarks[BodyParts.RIGHT_EYE_INNER.index]!,
    landmarks[BodyParts.RIGHT_EYE.index]!,
    landmarks[BodyParts.RIGHT_EYE_OUTER.index]!,
    landmarks[BodyParts.RIGHT_EAR.index]!,
  ], targetDistance);
  var normLeftFace = normalizeLandmarksSequence([
    normRightFace[BodyParts.NOSE.index]!,
    landmarks[BodyParts.LEFT_EYE_INNER.index]!,
    landmarks[BodyParts.LEFT_EYE.index]!,
    landmarks[BodyParts.LEFT_EYE_OUTER.index]!,
    landmarks[BodyParts.LEFT_EAR.index]!,
  ], targetDistance);
  var normMouth = normalizeLandmarksSequence([
    landmarks[BodyParts.MOUTH_LEFT.index]!,
    landmarks[BodyParts.MOUTH_RIGHT.index]!,
  ], targetDistance);

  // Torso
  var normTorso = normalizeLandmarksSequence([
    landmarks[BodyParts.RIGHT_SHOULDER.index]!,
    landmarks[BodyParts.LEFT_SHOULDER.index]!,
    landmarks[BodyParts.LEFT_HIP.index]!,
  ], targetDistance);
  var normRightHip = normalizeLandmarksSequence([
    normTorso[BodyParts.LEFT_HIP.index]!,
    landmarks[BodyParts.RIGHT_HIP.index]!,
  ], targetDistance);

  // Right leg
  var normRightLeg = normalizeLandmarksSequence([
    normRightHip[BodyParts.RIGHT_HIP.index]!,
    landmarks[BodyParts.RIGHT_KNEE.index]!,
    landmarks[BodyParts.RIGHT_ANKLE.index]!,
  ], targetDistance);
  var normRightHeel = normalizeLandmarksSequence([
    normRightLeg[BodyParts.RIGHT_ANKLE.index]!,
    landmarks[BodyParts.RIGHT_HEEL.index]!,
  ], targetDistance);
  var normRightFootIndex = normalizeLandmarksSequence([
    normRightLeg[BodyParts.RIGHT_ANKLE.index]!,
    landmarks[BodyParts.RIGHT_FOOT_INDEX.index]!,
  ], targetDistance);

  // Left leg
  var normLeftLeg = normalizeLandmarksSequence([
    normTorso[BodyParts.LEFT_HIP.index]!,
    landmarks[BodyParts.LEFT_KNEE.index]!,
    landmarks[BodyParts.LEFT_ANKLE.index]!,
  ], targetDistance);
  var normLeftHeel = normalizeLandmarksSequence([
    normLeftLeg[BodyParts.LEFT_ANKLE.index]!,
    landmarks[BodyParts.LEFT_HEEL.index]!,
  ], targetDistance);
  var normLeftFootIndex = normalizeLandmarksSequence([
    normLeftLeg[BodyParts.LEFT_ANKLE.index]!,
    landmarks[BodyParts.LEFT_FOOT_INDEX.index]!,
  ], targetDistance);

  // Right hand
  var normRightHand = normalizeLandmarksSequence([
    normTorso[BodyParts.RIGHT_SHOULDER.index]!,
    landmarks[BodyParts.RIGHT_ELBOW.index]!,
    landmarks[BodyParts.RIGHT_WRIST.index]!,

    landmarks[BodyParts.RIGHT_PINKY.index]!,
  ], targetDistance);
  var normRightThumb = normalizeLandmarksSequence([
    normRightHand[BodyParts.RIGHT_WRIST.index]!,
    landmarks[BodyParts.RIGHT_THUMB.index]!,
  ], targetDistance);
  var normRightIndex = normalizeLandmarksSequence([
    normRightHand[BodyParts.RIGHT_WRIST.index]!,
    landmarks[BodyParts.RIGHT_INDEX.index]!,
  ], targetDistance);
  var normRightPinky = normalizeLandmarksSequence([
    normRightHand[BodyParts.RIGHT_WRIST.index]!,
    landmarks[BodyParts.RIGHT_PINKY.index]!,
  ], targetDistance);

  // Left leg
  var normLeftHand = normalizeLandmarksSequence([
    normTorso[BodyParts.LEFT_SHOULDER.index]!,
    landmarks[BodyParts.LEFT_ELBOW.index]!,
    landmarks[BodyParts.LEFT_WRIST.index]!,
    landmarks[BodyParts.LEFT_THUMB.index]!,
    landmarks[BodyParts.LEFT_INDEX.index]!,
    landmarks[BodyParts.LEFT_PINKY.index]!,
  ], targetDistance);
  var normLeftThumb = normalizeLandmarksSequence([
    normLeftHand[BodyParts.LEFT_WRIST.index]!,
    landmarks[BodyParts.LEFT_THUMB.index]!,
  ], targetDistance);
  var normLeftIndex = normalizeLandmarksSequence([
    normLeftHand[BodyParts.LEFT_WRIST.index]!,
    landmarks[BodyParts.LEFT_INDEX.index]!,
  ], targetDistance);
  var normLeftPinky = normalizeLandmarksSequence([
    normLeftHand[BodyParts.LEFT_WRIST.index]!,
    landmarks[BodyParts.LEFT_PINKY.index]!,
  ], targetDistance);

  Map<int, Landmark> allNorm = {
    ...normLeftFace,
    ...normRightFace,
    ...normMouth,

    ...normTorso,
    ...normRightHip,

    ...normLeftHand,
    ...normLeftThumb,
    ...normLeftIndex,
    ...normLeftPinky,

    ...normRightHand,
    ...normRightThumb,
    ...normRightIndex,
    ...normRightPinky,

    ...normLeftLeg,
    ...normLeftHeel,
    ...normLeftFootIndex,

    ...normRightLeg,
    ...normRightHeel,
    ...normRightFootIndex,
  };

  Map<int, Landmark> complete = _sortMapLandmark(landmarks, allNorm);

  return complete;
}

/// Restore lengths — symmetric to getNormalizedLandmarks
Map<int, Landmark> restoreLandmarks(
  Map<int, Landmark> landmarks,
  Map<Pair, Vector> vectors,
) {
  // restores a chain of body parts into a Map<int, Landmark>
  Map<int, Landmark> restoreSequence(
    Map<int, Landmark> sourceMap, // where to take the first/base from
    List<BodyParts> chain,
  ) {
    final Map<int, Landmark> part = {};
    if (chain.isEmpty) return part;
    final firstPart = chain.first;
    final baseLandmark =
        sourceMap[firstPart.index] ?? landmarks[firstPart.index];
    if (baseLandmark == null) return part;

    part[firstPart.index] = baseLandmark;

    for (var i = 1; i < chain.length; i++) {
      final prev = chain[i - 1];
      final curr = chain[i];

      final vec = vectors[Pair(prev, curr)];
      if (vec == null) {
        final orig = landmarks[curr.index];
        if (orig != null) part[curr.index] = orig;
        continue;
      }

      final prevLandmark =
          part[prev.index] ?? sourceMap[prev.index] ?? landmarks[prev.index];
      if (prevLandmark == null) continue;

      final restored = Landmark(
        index: landmarks[curr.index]!.index,
        name: landmarks[curr.index]!.name,
        x: prevLandmark.x + vec.x,
        y: prevLandmark.y + vec.y,
        z: prevLandmark.z + vec.z,
        visibility: landmarks[curr.index]!.visibility,
      );

      part[curr.index] = restored;
    }

    return part;
  }

  // Build parts in the same order s as getNormalizedLandmarks()
  // FACE
  final rightFace = restoreSequence(landmarks, [
    BodyParts.NOSE,
    BodyParts.RIGHT_EYE_INNER,
    BodyParts.RIGHT_EYE,
    BodyParts.RIGHT_EYE_OUTER,
    BodyParts.RIGHT_EAR,
  ]);

  // left face
  final leftFace = restoreSequence(
    {...landmarks, ...rightFace},
    [
      BodyParts.NOSE,
      BodyParts.LEFT_EYE_INNER,
      BodyParts.LEFT_EYE,
      BodyParts.LEFT_EYE_OUTER,
      BodyParts.LEFT_EAR,
    ],
  );

  final mouth = restoreSequence(landmarks, [
    BodyParts.MOUTH_LEFT,
    BodyParts.MOUTH_RIGHT,
  ]);

  // TORSO
  final torso = restoreSequence(landmarks, [
    BodyParts.RIGHT_SHOULDER,
    BodyParts.LEFT_SHOULDER,
    BodyParts.LEFT_HIP,
  ]);

  // rightHip depends on torso (uses LEFT_HIP from torso)
  final rightHip = restoreSequence(
    {...landmarks, ...torso},
    [BodyParts.LEFT_HIP, BodyParts.RIGHT_HIP],
  );

  // RIGHT LEG (depends on rightHip)
  final rightLeg = restoreSequence(
    {...landmarks, ...rightHip},
    [BodyParts.RIGHT_HIP, BodyParts.RIGHT_KNEE, BodyParts.RIGHT_ANKLE],
  );
  final rightHeel = restoreSequence(
    {...landmarks, ...rightLeg},
    [BodyParts.RIGHT_ANKLE, BodyParts.RIGHT_HEEL],
  );
  final rightFootIndex = restoreSequence(
    {...landmarks, ...rightLeg},
    [BodyParts.RIGHT_ANKLE, BodyParts.RIGHT_FOOT_INDEX],
  );

  // LEFT LEG (depends on torso -> LEFT_HIP)
  final leftLeg = restoreSequence(
    {...landmarks, ...torso},
    [BodyParts.LEFT_HIP, BodyParts.LEFT_KNEE, BodyParts.LEFT_ANKLE],
  );
  final leftHeel = restoreSequence(
    {...landmarks, ...leftLeg},
    [BodyParts.LEFT_ANKLE, BodyParts.LEFT_HEEL],
  );
  final leftFootIndex = restoreSequence(
    {...landmarks, ...leftLeg},
    [BodyParts.LEFT_ANKLE, BodyParts.LEFT_FOOT_INDEX],
  );

  // RIGHT HAND (start from torso RIGHT_SHOULDER)
  final rightHand = restoreSequence(
    {...landmarks, ...torso},
    [
      BodyParts.RIGHT_SHOULDER,
      BodyParts.RIGHT_ELBOW,
      BodyParts.RIGHT_WRIST,
      BodyParts.RIGHT_PINKY,
    ],
  );
  final rightThumb = restoreSequence(
    {...landmarks, ...rightHand},
    [BodyParts.RIGHT_WRIST, BodyParts.RIGHT_THUMB],
  );
  final rightIndex = restoreSequence(
    {...landmarks, ...rightHand},
    [BodyParts.RIGHT_WRIST, BodyParts.RIGHT_INDEX],
  );
  final rightPinky = restoreSequence(
    {...landmarks, ...rightHand},
    [BodyParts.RIGHT_WRIST, BodyParts.RIGHT_PINKY],
  );

  // LEFT HAND (start from torso LEFT_SHOULDER)
  final leftHand = restoreSequence(
    {...landmarks, ...torso},
    [
      BodyParts.LEFT_SHOULDER,
      BodyParts.LEFT_ELBOW,
      BodyParts.LEFT_WRIST,
      BodyParts.LEFT_PINKY,
    ],
  );
  final leftThumb = restoreSequence(
    {...landmarks, ...leftHand},
    [BodyParts.LEFT_WRIST, BodyParts.LEFT_THUMB],
  );
  final leftIndex = restoreSequence(
    {...landmarks, ...leftHand},
    [BodyParts.LEFT_WRIST, BodyParts.LEFT_INDEX],
  );
  final leftPinky = restoreSequence(
    {...landmarks, ...leftHand},
    [BodyParts.LEFT_WRIST, BodyParts.LEFT_PINKY],
  );

  // Combine everything using spread-operator exactly like getNormalizedLandmarks
  final Map<int, Landmark> allRestored = {
    ...leftFace,
    ...rightFace,
    ...mouth,
    ...torso,
    ...rightHip,
    ...leftHand,
    ...leftThumb,
    ...leftIndex,
    ...leftPinky,
    ...rightHand,
    ...rightThumb,
    ...rightIndex,
    ...rightPinky,
    ...leftLeg,
    ...leftHeel,
    ...leftFootIndex,
    ...rightLeg,
    ...rightHeel,
    ...rightFootIndex,
  };

  // Sort and fill missing using your helper
  final Map<int, Landmark> complete = _sortMapLandmark(landmarks, allRestored);
  return complete;
}

Map<int, Landmark> _sortMapLandmark(
  Map<int, Landmark> landmarks,
  Map<int, Landmark> newMap,
) {
  Map<int, Landmark> complete = {};
  for (var entry
      in landmarks.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
    complete[entry.key] = newMap[entry.key] ?? entry.value;
  }
  return complete;
}
