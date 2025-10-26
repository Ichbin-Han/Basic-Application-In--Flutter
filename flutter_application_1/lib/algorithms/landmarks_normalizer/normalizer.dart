import '../models/frame.dart';
import '../models/vector.dart';
import '../models/landmark.dart';
import '../models/pair.dart';
import 'landmarks_normalizer.dart';

/// Handle landmarks normalizing, making the same distance between
/// neighboring landmarks
/// 
/// Example:
/// ```
/// Normalizer norm = Normalizer();
/// for (var f in lm.frames) {
///     // Prepare frame for processing
///     norm.prepareFrame(f);
///
///     // Optional
///     norm.storeVectors([f]);
///     
///     // Normalize prepared frames
///     norm.normalizePreparedFrames();
///
///     // Add these prepared frames to list of frames 
///     // and clear prepared frames
///     norm.commitPreparedFrames();
/// }
/// var res = norm.frames;
/// ```
class Normalizer {
  /// Prepared frames for normalizing
  final List<Frame> preparedFrames = [];

  /// Normalized frames
  final List<Frame> frames = [];

  /// Stored original vectors
  final List<Map<Pair, Vector>> vectors = [];

  /// Prepare frame
  void prepareFrame(Frame frame) {
    final frameCopy = frame.copyWith(
      landmarks: frame.landmarks.map((l) => l.copyWith()).toList(),
    );
    preparedFrames.add(frameCopy);
  }

  // Normalize all prepared frames
  void normalizePreparedFrames({double targetDistance = 1.0}) {
    for (int i = 0; i < preparedFrames.length; i++) {
      final norm = getNormalizedLandmarks(
        _toMap(preparedFrames[i].landmarks),
        targetDistance,
      );

      preparedFrames[i] = preparedFrames[i].copyWith(
        landmarks: List.from(norm.values.toList()),
      );
      // preparedFrames[i].refreshVectors();
    }
  }

  /// Store vectors for landmark reconstruction
  ///
  /// [frames] - frames in which vectors will be added to list of [vectors].
  ///
  /// Example:
  /// ```dart
  /// storeVectors([frame1, frame2]); // add multiple frames
  /// storeVectors([singleFrame]);    // add one frame
  /// ```
  void storeVectors(List<Frame> frames) {
    for (var frame in frames) {
      final deepCopy = <Pair, Vector>{};
      frame.vectors.forEach((pair, vector) {
        deepCopy[Pair(pair.start, pair.end)] = vector.copyWith();
      });
      vectors.add(deepCopy);
    }
  }

  /// Clear vectors
  void clearVectors() => vectors.clear();

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

  /// Restore landmarks of all processed frames
  ///
  /// [start] - Optional. An integer number specifying at which position to start. Default is 0.
  ///
  /// [stop] - Optional. An integer number specifying at which position to stop (not included).
  /// Default is the length of frames
  void reconstructLandmarks({int start = 0, int? stop}) {
    stop ??= frames.length;

    if (stop > frames.length || stop < start) {
      throw RangeError(
        "Invalid range: stop=$stop, start=$start, length=${frames.length}",
      );
    }

    for (var i = start; i < stop; i++) {
      final restored = restoreLandmarks(
        _toMap(frames[i].landmarks),
        vectors[i],
      );
      frames[i] = frames[i].copyWith(landmarks: restored.values.toList());
    }
  }

  /// Convert list of landmarks to map
  Map<int, Landmark> _toMap(List<Landmark> landmarks) => {
    for (var l in landmarks) l.index: l,
  };
}
