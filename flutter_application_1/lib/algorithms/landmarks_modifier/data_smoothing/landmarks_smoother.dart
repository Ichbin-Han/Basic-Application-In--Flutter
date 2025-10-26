import './one_euro_filter.dart';
import '../../models/frame.dart';
import '../../models/landmark.dart';

class LandmarksSmoother {
  final String exerciseName;

  final Map<String, OneEuroFilter> _filters = {};

  final Map<String, List<double>> _exerciseSettings = {
    'situps': [1.1, 0.005, 1.5],
    'jumpingjacks': [0.8, 0.005, 2.5],
    'default': [1.0, 0.005, 1.2],
  };

  late final List<double> settings;
  late final double minCutoff;
  late final double beta;

  LandmarksSmoother({this.exerciseName = 'default'}) {
    settings = _exerciseSettings[exerciseName] ?? _exerciseSettings['default']!;
    minCutoff = settings[0];
    beta = settings[1];

    _initializeFilters(minCutoff, beta);
  }

  final List<String> landmarkNames = [
    'NOSE',
    'LEFT_EYE_INNER',
    'LEFT_EYE',
    'LEFT_EYE_OUTER',
    'RIGHT_EYE_INNER',
    'RIGHT_EYE',
    'RIGHT_EYE_OUTER',
    'LEFT_EAR',
    'RIGHT_EAR',
    'MOUTH_LEFT',
    'MOUTH_RIGHT',
    'LEFT_SHOULDER',
    'RIGHT_SHOULDER',
    'LEFT_ELBOW',
    'RIGHT_ELBOW',
    'LEFT_WRIST',
    'RIGHT_WRIST',
    'LEFT_PINKY',
    'RIGHT_PINKY',
    'LEFT_INDEX',
    'RIGHT_INDEX',
    'LEFT_THUMB',
    'RIGHT_THUMB',
    'LEFT_HIP',
    'RIGHT_HIP',
    'LEFT_KNEE',
    'RIGHT_KNEE',
    'LEFT_ANKLE',
    'RIGHT_ANKLE',
    'LEFT_HEEL',
    'RIGHT_HEEL',
    'LEFT_FOOT_INDEX',
    'RIGHT_FOOT_INDEX',
  ];

  void _initializeFilters(double minCutoff, double beta) {
    for (String name in landmarkNames) {
      _filters['${name}_x'] = OneEuroFilter(minCutoff: minCutoff, beta: beta);
      _filters['${name}_y'] = OneEuroFilter(minCutoff: minCutoff, beta: beta);
      _filters['${name}_z'] = OneEuroFilter(minCutoff: minCutoff, beta: beta);
    }
  }

  /// Reset filters to base
  void resetFilters() {
    _initializeFilters(minCutoff, beta);
  }

  /// Returns smoothed frames.
  ///
  /// [frames] -> list of frames, that can be smoothed.
  /// That argument affects filters which means that to reset filters
  /// you have to call method *resetFilters* inside class
  List<Frame> smooth(List<Frame> frames) {
    final settings =
        _exerciseSettings[exerciseName] ?? _exerciseSettings['default']!;
    final velocityThreshold = settings[2];

    List<Frame> smoothedFrames = [];
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final lms = frame.landmarks;

      List<Landmark> smoothedLandmarks = [];
      for (var j = 0; j < lms.length; j++) {
        final name = lms[j].name;
        final currentTimeSec = frame.timestampMs / 1000.0;

        final rawX = lms[j].x;
        final rawY = lms[j].y;
        final rawZ = lms[j].z;

        final filterX = _filters['${name}_x']!;
        final filterY = _filters['${name}_y']!;
        final filterZ = _filters['${name}_z']!;

        final dt = currentTimeSec - filterX.getPrevT();

        if (dt > 0) {
          final dx = (rawX - filterX.getPrevX()) / dt;
          final dy = (rawY - filterY.getPrevY()) / dt;
          final dz = (rawZ - filterZ.getPrevZ()) / dt;

          if (dx.abs() > velocityThreshold ||
              dy.abs() > velocityThreshold ||
              dz.abs() > velocityThreshold) {
            // TODO: handle fast movement
          }
        }

        final smoothX = filterX.filter(rawX, currentTimeSec);
        final smoothY = filterY.filter(rawY, currentTimeSec);
        final smoothZ = filterZ.filter(rawZ, currentTimeSec);

        smoothedLandmarks.add(
          lms[j].copyWith(x: smoothX, y: smoothY, z: smoothZ),
        );
      }

      smoothedFrames.add(frame.copyWith(landmarks: smoothedLandmarks));
    }

    return smoothedFrames;
  }
}
