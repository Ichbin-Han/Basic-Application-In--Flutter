import './data_smoothing/landmarks_smoother.dart';
import './establishig_z/z_estimator.dart' as ze;
import '../models/frame.dart';
import '../models/landmark.dart';
import '../landmarks_normalizer/normalizer.dart';

/// Handles landmark processing pipeline: manual smoothing, Z-estimation, and normalization.
///
/// Example how to use:
/// ```
/// final frames = await readLandmarksVideoCsv(
///    'situps.csv',
/// );
///
/// LandmarksModifier lm1 = LandmarksModifier(exerciseName: "situps");
///
/// for (var i = 0; i < frames.length; i++) {
///    lm1.prepareFrame(frames[i]);
///
///    // It prevents processing each frame.
///    // Smoothing demands several frames (e.g. 5)
///    final isBatchReady = (i % 5 == 0 && i != 0) || i == frames.length - 1;
///    if (!isBatchReady) continue;
///
///    // Smoothing
///    lm1.smoothPreparedFrames();
///
///    // Z estimating
///    lm1.estimateZPreparedFrames();
///
///    // Adding these frames to the main list
///    lm1.commitPreparedFrames();
/// }
///
/// // All processed frames
/// final res = lm1.frames;
/// ```
class LandmarksModifier {
  /// Prepared frames for manual processing
  final List<Frame> preparedFrames = [];

  /// Processed (final) frames
  final List<Frame> frames = [];

  /// Internal smoother
  late final LandmarksSmoother _landmarksSmoother;

  LandmarksModifier({String exerciseName = "default"}) {
    _landmarksSmoother = LandmarksSmoother(exerciseName: exerciseName);
  }

  /// Prepare frame for later processing
  void prepareFrame(Frame frame) {
    final frameCopy = frame.copyWith(
      landmarks: frame.landmarks.map((l) => l.copyWith()).toList(),
    );
    preparedFrames.add(frameCopy);
  }

  /// Apply smoothing to all prepared frames
  void smoothPreparedFrames() {
    if (preparedFrames.isEmpty) return;
    try {
      final smoothed = _landmarksSmoother.smooth(preparedFrames);
      preparedFrames
        .addAll(smoothed);
    } catch (e) {
      return;
    }
  }

  /// Estimate Z values for all prepared frames
  void estimateZPreparedFrames() {
    for (int i = 0; i < preparedFrames.length; i++) {
      final zEstimated = ze.estimateZForImageLandmarks(
        preparedFrames[i].landmarks,
        visibilityThreshold: 0.4,
        smoothPasses: 3,
        smoothLambda: 0.25,
        centerOnPelvis: true,
        centerOnlyActive: true,
        keepInactiveAtZero: true,
        scaleBoost: 1.12,
        zGain: 1.8,
      );

      preparedFrames[i] = preparedFrames[i].copyWith(
        landmarks: List.from(zEstimated),
      );
    }
  }

  /// Save normalized frames and clear prepared frames
  void commitPreparedFrames() {
    frames.addAll(
      preparedFrames.map(
        (f) => f.copyWith(
          landmarks: f.landmarks.map((l) => l.copyWith()).toList(),
        ),
      ),
    );
    preparedFrames.clear();
  }

  // - - - Static methods that return modified landmarks - - - 
  
  /// Returns list of normalized [Landmark]s
  static List<Landmark> getNormalized(List<Landmark> landmarks) {
    Normalizer normalizer = Normalizer();
    normalizer.prepareFrame(
      Frame(video: "", frameIndex: 0, timestampMs: 0, landmarks: landmarks),
    );
    normalizer.normalizePreparedFrames();
    return normalizer.preparedFrames.last.landmarks;
  }

  /// Returns list of smoothed [Landmark]s
  static List<Landmark> getSmoothed(
    List<Landmark> currentLandmarks,
    List<Landmark> previousLandmarks,
  ) {
    LandmarksModifier landmarksModifier = LandmarksModifier();
    landmarksModifier.prepareFrame(
      Frame(
        video: "",
        frameIndex: 0,
        timestampMs: 0,
        landmarks: previousLandmarks,
      ),
    );
    landmarksModifier.prepareFrame(
      Frame(
        video: "",
        frameIndex: 0,
        timestampMs: 0,
        landmarks: currentLandmarks,
      ),
    );
    landmarksModifier.smoothPreparedFrames();
    return landmarksModifier.preparedFrames.last.landmarks;
  }

  /// Returns list of z-estimated [Landmark]s
  static List<Landmark> getZEstimated(List<Landmark> landmarks) {
    LandmarksModifier landmarksModifier = LandmarksModifier();
    landmarksModifier.prepareFrame(
      Frame(video: "", frameIndex: 0, timestampMs: 0, landmarks: landmarks),
    );
    landmarksModifier.estimateZPreparedFrames();
    return landmarksModifier.preparedFrames.last.landmarks;
  }

}
