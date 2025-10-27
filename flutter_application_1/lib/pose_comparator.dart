import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// --- Vector Class (Adapted for PoseLandmark) ---
// Represents a 3D vector between two landmarks.
class Vector {
  late final String name;
  late final double x, y, z;
  late final double length;
  late final PoseLandmarkType startType;
  late final PoseLandmarkType endType;

  // Constructor for creating a vector directly.
  Vector(
    this.x,
    this.y,
    this.z, {
    this.name = "",
    this.length = -1,
    this.startType = PoseLandmarkType.nose, // Default placeholder
    this.endType = PoseLandmarkType.nose,   // Default placeholder
  });

  /// Build Vector based on start and end PoseLandmarks.
  Vector.fromLandmarks(PoseLandmark start, PoseLandmark end) {
    x = end.x - start.x;
    y = end.y - start.y;
    z = end.z - start.z;
    length = _getLength(x, y, z);
    name = '${start.type.toString().split('.').last}-->${end.type.toString().split('.').last}';
    startType = start.type;
    endType = end.type;
  }

  /// Build a Unit Vector (length 1) based on an existing vector.
  Vector.unitVector(Vector vector) {
    if (vector.length == 0) {
      // Avoid division by zero
      x = 0; y = 0; z = 0; length = 0;
    } else {
      x = vector.x / vector.length;
      y = vector.y / vector.length;
      z = vector.z / vector.length;
      length = 1.0;
    }
    name = "Unit ${vector.name}";
    startType = vector.startType;
    endType = vector.endType;
  }

  // Calculates the magnitude (length) of the vector.
  double _getLength(double x, double y, double z) =>
      sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));

  @override
  String toString() =>
      "Vector(name: $name, x: $x, y: $y, z: $z, length: $length)";
}


// --- Normalization Functions (Adapted for PoseLandmarkType Map) ---

/// Normalizes a sequence of landmarks, placing them at a standard target distance.
/// Input: A map of landmarks for the sequence, ordered logically.
/// Output: A map containing the normalized landmarks.
Map<PoseLandmarkType, PoseLandmark> normalizeLandmarkSequence(
  Map<PoseLandmarkType, PoseLandmark?> landmarksSequenceMap,
  List<PoseLandmarkType> sequenceOrder, // The order to process landmarks
  double targetDistance
) {
  Map<PoseLandmarkType, PoseLandmark> normalizedLandmarks = {};
  PoseLandmark? current = landmarksSequenceMap[sequenceOrder.first];

  if (current == null) return {}; // Cannot normalize if the starting point is missing

  normalizedLandmarks[current.type] = current;

  for (var i = 1; i < sequenceOrder.length; i++) {
    PoseLandmark? nextOriginal = landmarksSequenceMap[sequenceOrder[i]];

    if (nextOriginal == null) continue; // Skip if a landmark in the sequence is missing

    final unitV = Vector.unitVector(Vector.fromLandmarks(current!, nextOriginal));

    // Calculate the position of the normalized 'next' landmark
    final PoseLandmark nextNormalized = PoseLandmark(
      type: nextOriginal.type,
      x: current.x + unitV.x * targetDistance,
      y: current.y + unitV.y * targetDistance,
      z: current.z + unitV.z * targetDistance,
      likelihood: nextOriginal.likelihood, // Keep the original likelihood
    );

    normalizedLandmarks[nextNormalized.type] = nextNormalized;
    current = nextNormalized; // The next iteration starts from the newly calculated point
  }
  return normalizedLandmarks;
}


/// Normalizes all key body parts (face, torso, limbs) using predefined sequences.
/// Input: The full map of detected landmarks.
/// Output: A map containing only the normalized landmarks for key body parts.
Map<PoseLandmarkType, PoseLandmark> getNormalizedLandmarks(
    Map<PoseLandmarkType, PoseLandmark> landmarks, double targetDistance) {

  // Define sequences for different body parts using PoseLandmarkType
  const faceRightSequence = [PoseLandmarkType.nose, PoseLandmarkType.rightEyeInner, PoseLandmarkType.rightEye, PoseLandmarkType.rightEyeOuter, PoseLandmarkType.rightEar];
  const faceLeftSequence = [PoseLandmarkType.nose, PoseLandmarkType.leftEyeInner, PoseLandmarkType.leftEye, PoseLandmarkType.leftEyeOuter, PoseLandmarkType.leftEar];
  const mouthSequence = [PoseLandmarkType.leftMouth, PoseLandmarkType.rightMouth];
  const torsoSequence = [PoseLandmarkType.rightShoulder, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip]; // Base for others
  const rightHipSequence = [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip];
  const rightLegSequence = [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle];
  const rightHeelSequence = [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel];
  const rightFootIndexSequence = [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightFootIndex];
  const leftLegSequence = [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle];
  const leftHeelSequence = [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel];
  const leftFootIndexSequence = [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftFootIndex];
  const rightArmSequence = [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist];
  const rightHandSequence = [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb, PoseLandmarkType.rightIndex, PoseLandmarkType.rightPinky]; // Simplified hand
  const leftArmSequence = [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist];
  const leftHandSequence = [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb, PoseLandmarkType.leftIndex, PoseLandmarkType.leftPinky]; // Simplified hand

  // Helper function to create the input map for normalizeLandmarkSequence
  Map<PoseLandmarkType, PoseLandmark?> getSequenceMap(List<PoseLandmarkType> sequence) {
    return { for (var type in sequence) type : landmarks[type] };
  }

  // Normalize each part
  final normFaceRight = normalizeLandmarkSequence(getSequenceMap(faceRightSequence), faceRightSequence, targetDistance);
  // Re-base left face normalization on the normalized nose from the right face pass
  final Map<PoseLandmarkType, PoseLandmark?> leftFaceInput = getSequenceMap(faceLeftSequence);
  if (normFaceRight[PoseLandmarkType.nose] != null) {
      leftFaceInput[PoseLandmarkType.nose] = normFaceRight[PoseLandmarkType.nose];
  }
  final normFaceLeft = normalizeLandmarkSequence(leftFaceInput, faceLeftSequence, targetDistance);
  final normMouth = normalizeLandmarkSequence(getSequenceMap(mouthSequence), mouthSequence, targetDistance);

  final normTorso = normalizeLandmarkSequence(getSequenceMap(torsoSequence), torsoSequence, targetDistance);
  // Re-base right hip on normalized right shoulder
   final Map<PoseLandmarkType, PoseLandmark?> rightHipInput = getSequenceMap(rightHipSequence);
   if (normTorso[PoseLandmarkType.rightShoulder] != null) {
       rightHipInput[PoseLandmarkType.rightShoulder] = normTorso[PoseLandmarkType.rightShoulder];
   }
  final normRightHip = normalizeLandmarkSequence(rightHipInput, rightHipSequence, targetDistance);

  // Re-base limbs on normalized torso/hip points
  final Map<PoseLandmarkType, PoseLandmark?> rightLegInput = getSequenceMap(rightLegSequence);
  if (normRightHip[PoseLandmarkType.rightHip] != null) {
      rightLegInput[PoseLandmarkType.rightHip] = normRightHip[PoseLandmarkType.rightHip];
  }
  final normRightLeg = normalizeLandmarkSequence(rightLegInput, rightLegSequence, targetDistance);

  final Map<PoseLandmarkType, PoseLandmark?> rightHeelInput = getSequenceMap(rightHeelSequence);
  if (normRightLeg[PoseLandmarkType.rightAnkle] != null) {
      rightHeelInput[PoseLandmarkType.rightAnkle] = normRightLeg[PoseLandmarkType.rightAnkle];
  }
  final normRightHeel = normalizeLandmarkSequence(rightHeelInput, rightHeelSequence, targetDistance);

  final Map<PoseLandmarkType, PoseLandmark?> rightFootIndexInput = getSequenceMap(rightFootIndexSequence);
   if (normRightLeg[PoseLandmarkType.rightAnkle] != null) {
       rightFootIndexInput[PoseLandmarkType.rightAnkle] = normRightLeg[PoseLandmarkType.rightAnkle];
   }
  final normRightFootIndex = normalizeLandmarkSequence(rightFootIndexInput, rightFootIndexSequence, targetDistance);


  final Map<PoseLandmarkType, PoseLandmark?> leftLegInput = getSequenceMap(leftLegSequence);
  if (normTorso[PoseLandmarkType.leftHip] != null) {
      leftLegInput[PoseLandmarkType.leftHip] = normTorso[PoseLandmarkType.leftHip];
  }
  final normLeftLeg = normalizeLandmarkSequence(leftLegInput, leftLegSequence, targetDistance);

  // ... (similarly re-base left heel, foot index, arms, and hands on previously normalized points) ...
  // (Code omitted for brevity, but the pattern is the same: update the input map with the normalized anchor point)
   final Map<PoseLandmarkType, PoseLandmark?> leftHeelInput = getSequenceMap(leftHeelSequence);
   if (normLeftLeg[PoseLandmarkType.leftAnkle] != null) {
       leftHeelInput[PoseLandmarkType.leftAnkle] = normLeftLeg[PoseLandmarkType.leftAnkle];
   }
   final normLeftHeel = normalizeLandmarkSequence(leftHeelInput, leftHeelSequence, targetDistance);

   final Map<PoseLandmarkType, PoseLandmark?> leftFootIndexInput = getSequenceMap(leftFootIndexSequence);
   if (normLeftLeg[PoseLandmarkType.leftAnkle] != null) {
       leftFootIndexInput[PoseLandmarkType.leftAnkle] = normLeftLeg[PoseLandmarkType.leftAnkle];
   }
   final normLeftFootIndex = normalizeLandmarkSequence(leftFootIndexInput, leftFootIndexSequence, targetDistance);


  final Map<PoseLandmarkType, PoseLandmark?> rightArmInput = getSequenceMap(rightArmSequence);
  if (normTorso[PoseLandmarkType.rightShoulder] != null) {
      rightArmInput[PoseLandmarkType.rightShoulder] = normTorso[PoseLandmarkType.rightShoulder];
  }
  final normRightArm = normalizeLandmarkSequence(rightArmInput, rightArmSequence, targetDistance);

   final Map<PoseLandmarkType, PoseLandmark?> rightHandInput = getSequenceMap(rightHandSequence);
   if (normRightArm[PoseLandmarkType.rightWrist] != null) {
       rightHandInput[PoseLandmarkType.rightWrist] = normRightArm[PoseLandmarkType.rightWrist];
   }
  final normRightHand = normalizeLandmarkSequence(rightHandInput, rightHandSequence, targetDistance);


  final Map<PoseLandmarkType, PoseLandmark?> leftArmInput = getSequenceMap(leftArmSequence);
  if (normTorso[PoseLandmarkType.leftShoulder] != null) {
      leftArmInput[PoseLandmarkType.leftShoulder] = normTorso[PoseLandmarkType.leftShoulder];
  }
  final normLeftArm = normalizeLandmarkSequence(leftArmInput, leftArmSequence, targetDistance);

  final Map<PoseLandmarkType, PoseLandmark?> leftHandInput = getSequenceMap(leftHandSequence);
  if (normLeftArm[PoseLandmarkType.leftWrist] != null) {
      leftHandInput[PoseLandmarkType.leftWrist] = normLeftArm[PoseLandmarkType.leftWrist];
  }
  final normLeftHand = normalizeLandmarkSequence(leftHandInput, leftHandSequence, targetDistance);

  // Combine all normalized parts into a single map.
  // Using spread operator (...) merges maps, later entries overwrite earlier ones if keys collide (which shouldn't happen here with distinct sequences).
  Map<PoseLandmarkType, PoseLandmark> allNormalized = {
    ...normFaceRight, ...normFaceLeft, ...normMouth,
    ...normTorso, ...normRightHip,
    ...normRightLeg, ...normRightHeel, ...normRightFootIndex,
    ...normLeftLeg, ...normLeftHeel, ...normLeftFootIndex,
    ...normRightArm, ...normRightHand,
    ...normLeftArm, ...normLeftHand,
  };

  return allNormalized;
}

// --- Error Calculation Functions (Adapted for PoseLandmarkType Map) ---

/// Calculates the error vector [dx, dy, dz] between corresponding landmarks of two poses.
/// Input: Two maps representing the poses to compare.
/// Output: A map where keys are PoseLandmarkType and values are List<double> [errorX, errorY, errorZ].
Map<PoseLandmarkType, List<double>> determineError(
  Map<PoseLandmarkType, PoseLandmark> firstPose,
  Map<PoseLandmarkType, PoseLandmark> secondPose,
) {
  Map<PoseLandmarkType, List<double>> errorMap = {};

  // Iterate through all possible landmark types
  for (final type in PoseLandmarkType.values) {
    final first = firstPose[type];
    final second = secondPose[type];

    // Calculate error only if the landmark exists in both poses
    if (first != null && second != null) {
      errorMap[type] = [
        (second.x - first.x),
        (second.y - first.y),
        (second.z - first.z),
      ];
    } else {
      // Optionally handle missing landmarks (e.g., assign a large error or skip)
      // errorMap[type] = [double.infinity, double.infinity, double.infinity];
    }
  }

  return errorMap;
}

/// Calculates a single score representing the total error between two poses.
/// Input: The error map generated by determineError.
/// Output: A double representing the sum of magnitudes of error vectors for each landmark.
double sumError(Map<PoseLandmarkType, List<double>> mapError) {
  double totalErrorMagnitude = 0;

  // Calculate the magnitude of the error vector for each landmark and sum them up.
  mapError.values.forEach((errorVector) {
    if (errorVector.length == 3) {
      final errorMagnitude = sqrt(
          pow(errorVector[0], 2) + pow(errorVector[1], 2) + pow(errorVector[2], 2));
      totalErrorMagnitude += errorMagnitude;
    }
  });

  return totalErrorMagnitude;
}

// --- Main Comparison Logic (Placeholder - Needs Adaptation) ---
// This part needs more context on how TrainerTemplate and userLandmarks are structured.
// The functions below are kept structurally similar but might need adjustments.

/// Represents the comparison result: the name of the best matching pose and its detailed error.
class PoseComparisonResult {
  final bool isMatch;
  final double errorScore; // Lower score means better match
  final String? poseName; // Name of the matched template pose (if applicable)
  final Map<PoseLandmarkType, List<double>>? detailedError; // Detailed error per landmark

  PoseComparisonResult({
    required this.isMatch,
    required this.errorScore,
    this.poseName,
    this.detailedError,
  });
}


/// Compares a detected pose against a template pose after normalization.
/// Returns a PoseComparisonResult indicating if it's a match and the error score.
PoseComparisonResult compareNormalizedPoses(
    Map<PoseLandmarkType, PoseLandmark> normalizedDetectedPose,
    Map<PoseLandmarkType, PoseLandmark> normalizedTemplatePose,
    {double matchThreshold = 10.0} // Adjust this threshold based on testing!
) {
  // Calculate the error between the two normalized poses.
  final detailedError = determineError(normalizedDetectedPose, normalizedTemplatePose);
  final totalError = sumError(detailedError);

  print("Comparison Error Score: $totalError"); // Log for debugging

  // Check if the total error is below the acceptance threshold.
  final bool isMatch = totalError < matchThreshold;

  return PoseComparisonResult(
    isMatch: isMatch,
    errorScore: totalError,
    detailedError: detailedError, // Include detailed error for potential feedback
  );
}


/*
// Original function from Vitaly's code - kept for reference

// Assumes TrainerTemplate and a specific structure for userLandmarks (Map<String, List<Landmark>>)
import 'dart:math';

import '../../csv_helper.dart';
import '../length_manipulation/body_parts.dart';
import '../comparing_templates/trainer_template.dart';

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

/// Class that represents pose name and error for each body part
class PoseError {
  /// Pose name
  final String poseName;

  /// Error(error_x, error_y, error_z) for each body part
  final Map<BodyParts, List<double>> error;

  const PoseError(this.poseName, this.error);
}
*/