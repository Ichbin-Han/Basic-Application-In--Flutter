import '../models/trainer_template.dart';
import '../models/landmark.dart';
import '../models/body_parts.dart';
import '../models/vector.dart';
import 'dart:math';

class LandmarksEqualizer {
  /// Landmarks that will be compared to the trainer's landmarks.
  /// Landmarks should be normalized before
  final List<Landmark> _landmarks;

  /// Processed landmarks for each pose
  late final Map<String, List<Landmark>> _mapPoseLandmarks;

  /// Trainer template
  late final TrainerTemplate template;

  /// [exercise] - the exercise name
  ///
  /// [_landmarks] - that will be processed and store results in [_mapPoseLandmarks]
  LandmarksEqualizer(this.template, this._landmarks) {
    _mapPoseLandmarks = {};
  }

  /// Return map that contains [String] pose as key
  /// and [List] of processed [Landmark]s as value
  Map<String, List<Landmark>> getProcessedLandmarks() {
    if (_mapPoseLandmarks.isNotEmpty) return _mapPoseLandmarks;
    for (var k in template.normPoseLandmarks.keys) {
      _mapPoseLandmarks[k] = _overlayLandmarks(k);
    }
    return _mapPoseLandmarks;
  }

  /// Сhange the position relative to the correct landmarks
  List<Landmark> _overlayLandmarks(String pose) {
    // Processed landmarks
    List<Landmark> processedLandmarks = [];

    // Static points
    List<BodyParts> indeces = template.staticPoints;

    // Correct landmarks
    List<Landmark> trainerLns = template.normPoseLandmarks[pose]!;

    // Centre of raw landmarks
    Landmark c1 = Landmark(
      index: -1,
      name: "First center",
      x: (_landmarks[indeces[0].index].x + _landmarks[indeces[1].index].x) / 2,
      y: (_landmarks[indeces[0].index].y + _landmarks[indeces[1].index].y) / 2,
      z: (_landmarks[indeces[0].index].z + _landmarks[indeces[1].index].z) / 2,
      visibility: 1,
    );

    // Centre of correct landmarks
    Landmark c2 = Landmark(
      index: -1,
      name: "Second center",
      x: (trainerLns[indeces[0].index].x + trainerLns[indeces[1].index].x) / 2,
      y: (trainerLns[indeces[0].index].y + trainerLns[indeces[1].index].y) / 2,
      z: (trainerLns[indeces[0].index].z + trainerLns[indeces[1].index].z) / 2,
      visibility: 1,
    );

    // The length of raw static points
    double d1 = Vector.fromLandmarks(
      _landmarks[indeces[0].index],
      _landmarks[indeces[1].index],
    ).length;

    // The length of correct static points
    double d2 = Vector.fromLandmarks(
      trainerLns[indeces[0].index],
      trainerLns[indeces[1].index],
    ).length;

    // The scale. Not necessary because both length shoulde be 1.0
    double s = d2 / d1;

    // Get rotation matrix
    var r = _getRotationMatrix(pose);

    // Process landmarks
    for (var l in _landmarks) {
      // Use formula newLandmark = r * (s * (landmark - c1)) + c2 for each
      double x = s * (l.x - c1.x);
      double y = s * (l.y - c1.y);
      double z = s * (l.z - c1.z);

      double newX = r[0] * x + r[1] * y + r[2] * z + c2.x;
      double newY = r[3] * x + r[4] * y + r[5] * z + c2.y;
      double newZ = r[6] * x + r[7] * y + r[8] * z + c2.z;

      var newLandmark = Landmark(
        index: l.index,
        name: l.name,
        x: newX,
        y: newY,
        z: newZ,
        visibility: l.visibility,
      );

      processedLandmarks.add(newLandmark);
    }

    return processedLandmarks;
  }

  List<double> _getRotationMatrix(String pose) {
    // Static points
    List<BodyParts> indeces = template.staticPoints;

    // Correct landmarks
    List<Landmark> trainerLns = template.normPoseLandmarks[pose]!;

    // Raw vector
    Vector v1 = Vector.fromLandmarks(
      _landmarks[indeces[0].index],
      _landmarks[indeces[1].index],
    );

    // Correct vector
    Vector v2 = Vector.fromLandmarks(
      trainerLns[indeces[0].index],
      trainerLns[indeces[1].index],
    );

    // Raw unit vector (length = 1.0)
    Vector uv1 = Vector.unitVector(v1);

    // Correct unit vector (length = 1.0)
    Vector uv2 = Vector.unitVector(v2);

    // Vector that is perpendicular to uv1 and uv2
    Vector cross = uv1.crossProduct(uv2);

    // Unit vector of cross.
    // Check whether cross.legnth is zero, preventing division by zero
    Vector u;
    if (cross.length > 1e-6) {
      u = Vector.unitVector(cross);
    } else {
      u = Vector(1.0, 0, 0);
    }

    // Arc cos
    double angle = acos(uv1.dotProduct(uv2).clamp(-1.0, 1.0));

    // Rodrigues' Rotation Formula
    List<double> r = [
      cos(angle) + u.x * u.x * (1 - cos(angle)),
      u.x * u.y * (1 - cos(angle)) - u.z * sin(angle),
      u.x * u.z * (1 - cos(angle)) + u.y * sin(angle),

      u.y * u.x * (1 - cos(angle)) + u.z * sin(angle),
      cos(angle) + u.y * u.y * (1 - cos(angle)),
      u.y * u.z * (1 - cos(angle)) - u.x * sin(angle),

      u.z * u.x * (1 - cos(angle)) - u.y * sin(angle),
      u.z * u.y * (1 - cos(angle)) + u.x * sin(angle),
      cos(angle) + u.z * u.z * (1 - cos(angle)),
    ];

    // Result
    return r;
  }
}
