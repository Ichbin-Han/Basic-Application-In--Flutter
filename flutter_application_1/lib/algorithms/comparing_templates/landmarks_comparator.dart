import '../models/trainer_template.dart';
import '../models/landmark.dart';
import '../models/body_parts.dart';
import '../models/pose_error.dart';
import 'dart:math';


/// Returns map
/// that contains [BodyParts] as key and list of [error_x, error_y, error_z] as value.
///
/// Compares first list with second and returns error
Map<BodyParts, List<double>> determineError(
  List<Landmark> firstLandmark,
  List<Landmark> secondLandmark,
) {
  Map<BodyParts, List<double>> map = {};

  if (firstLandmark.length != secondLandmark.length) {
    throw Exception("Different length");
  }

  var len = firstLandmark.length;
  for (var i = 0; i < len; i++) {
    BodyParts part = BodyParts.values[firstLandmark[i].index];
    map[part] = [
      (secondLandmark[i].x - firstLandmark[i].x),
      (secondLandmark[i].y - firstLandmark[i].y),
      (secondLandmark[i].z - firstLandmark[i].z),
    ];
  }

  return map;
}

/// Returns the sum of errors
double sumError(Map<BodyParts, List<double>> mapError) {
  double res = 0;

  // sqrt(x^2 + y^2 + z^2)
  for (var values in mapError.values) {
    double sum = 0;
    for (var num in values) {
      sum += num * num;
    }

    res += sqrt(sum);
  }

  return res;
}

/// Returns a map containing the best-matching pose name as key
/// and its detailed error map (BodyParts → [errorX, errorY, errorZ]) as value.
PoseError getMostAccuratePoseAndError(
  TrainerTemplate template,
  Map<String, List<Landmark>> userLandmarks,
) {
  final templateLandmarks = template.normPoseLandmarks;
  final Map<String, double> totalErrors = {};

  // Sum errors for each pose
  userLandmarks.forEach((poseName, userPoseLandmarks) {
    final totalError = sumError(
      determineError(userPoseLandmarks, templateLandmarks[poseName]!),
    );
    totalErrors[poseName] = totalError;
  });

  // Find the least error
  final bestPose = totalErrors.entries.reduce((a, b) {
    return a.value < b.value ? a : b;
  }).key;

  // Calculate for that pose
  final detailedError = determineError(
    userLandmarks[bestPose]!,
    templateLandmarks[bestPose]!,
  );

  return PoseError(bestPose, detailedError);
}

