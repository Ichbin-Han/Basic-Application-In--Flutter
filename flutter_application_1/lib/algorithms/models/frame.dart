import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'landmark.dart';
import 'body_parts.dart';
import 'vector.dart';
import '../landmarks_normalizer/landmarks_vector.dart';
import 'pair.dart';

class Frame {
  final String video;
  final int frameIndex;
  final int timestampMs;
  final List<Landmark> landmarks;

  late Map<Pair, Vector> vectors;

  Frame({
    required this.video,
    required this.frameIndex,
    required this.timestampMs,
    required this.landmarks,
  }) {
    _initVectors();
  }

  factory Frame.fromMlkitPose(Pose pose, int frameIndex) => Frame(
    video: "UserVideo",
    frameIndex: frameIndex,
    timestampMs: -1,
    landmarks: pose.landmarks.values
        .map(
          (l) => Landmark(
            index: l.type.index,
            name: l.type.name,
            x: l.x,
            y: l.y,
            z: l.z,
            visibility: l.likelihood,
          ),
        )
        .toList(),
  );

  void refreshVectors() => _initVectors();

  void _initVectors() {
    vectors = {
      // Face
      ...createVectorsBodyParts([
        landmarks[BodyParts.NOSE.index],
        landmarks[BodyParts.RIGHT_EYE_INNER.index],
        landmarks[BodyParts.RIGHT_EYE.index],
        landmarks[BodyParts.RIGHT_EYE_OUTER.index],
        landmarks[BodyParts.RIGHT_EAR.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.NOSE.index],
        landmarks[BodyParts.LEFT_EYE_INNER.index],
        landmarks[BodyParts.LEFT_EYE.index],
        landmarks[BodyParts.LEFT_EYE_OUTER.index],
        landmarks[BodyParts.LEFT_EAR.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.MOUTH_LEFT.index],
        landmarks[BodyParts.MOUTH_RIGHT.index],
      ]),

      // Torso
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_SHOULDER.index],
        landmarks[BodyParts.LEFT_SHOULDER.index],
        landmarks[BodyParts.LEFT_HIP.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_HIP.index],
        landmarks[BodyParts.RIGHT_HIP.index],
      ]),

      // Right leg
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_HIP.index],
        landmarks[BodyParts.RIGHT_KNEE.index],
        landmarks[BodyParts.RIGHT_ANKLE.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_ANKLE.index],
        landmarks[BodyParts.RIGHT_HEEL.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_ANKLE.index],
        landmarks[BodyParts.RIGHT_FOOT_INDEX.index],
      ]),

      // Left leg
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_HIP.index],
        landmarks[BodyParts.LEFT_KNEE.index],
        landmarks[BodyParts.LEFT_ANKLE.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_ANKLE.index],
        landmarks[BodyParts.LEFT_HEEL.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_ANKLE.index],
        landmarks[BodyParts.LEFT_FOOT_INDEX.index],
      ]),

      // Right hand
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_SHOULDER.index],
        landmarks[BodyParts.RIGHT_ELBOW.index],
        landmarks[BodyParts.RIGHT_WRIST.index],
        landmarks[BodyParts.RIGHT_PINKY.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_WRIST.index],
        landmarks[BodyParts.RIGHT_THUMB.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_WRIST.index],
        landmarks[BodyParts.RIGHT_INDEX.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.RIGHT_WRIST.index],
        landmarks[BodyParts.RIGHT_PINKY.index],
      ]),

      // Left hand
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_SHOULDER.index],
        landmarks[BodyParts.LEFT_ELBOW.index],
        landmarks[BodyParts.LEFT_WRIST.index],
        landmarks[BodyParts.LEFT_THUMB.index],
        landmarks[BodyParts.LEFT_INDEX.index],
        landmarks[BodyParts.LEFT_PINKY.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_WRIST.index],
        landmarks[BodyParts.LEFT_THUMB.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_WRIST.index],
        landmarks[BodyParts.LEFT_INDEX.index],
      ]),
      ...createVectorsBodyParts([
        landmarks[BodyParts.LEFT_WRIST.index],
        landmarks[BodyParts.LEFT_PINKY.index],
      ]),
    };
  }

  Frame copyWith({
    String? video,
    int? frameIndex,
    int? timestampMs,
    List<Landmark>? landmarks,
  }) {
    return Frame(
      video: video ?? this.video,
      frameIndex: frameIndex ?? this.frameIndex,
      timestampMs: timestampMs ?? this.timestampMs,
      landmarks: landmarks ?? this.landmarks,
    );
  }

  @override
  String toString() =>
      'Frame(video: $video, frameIndex: $frameIndex, timestampMs: $timestampMs, landmarks: ${landmarks.length})';
}
