/// Allows to monitor exercise. For instance, how many repetitions and how long.
class ExerciseTracker {
  /// Start pose
  final String startPose;

  /// List of poses
  final List<String> poses;

  ExerciseTracker(this.startPose) : poses = [];

  /// Process pose, counting repetitions and time
  void processPose(
    String pose, {
    int frameDurationInMs = 100,
    List<String>? pattern,
  }) {
    // Make it in lower case and remove all spaces
    pose = pose.toLowerCase().replaceAll(' ', '');

    // Check is it start pose
    if (poses.isEmpty && startPose.toLowerCase().replaceAll(' ', '') != pose) {
      return;
    }

    // First pose
    if (poses.isEmpty) {
      poses.add(pose);
    } 
    // Check is the last pose the same, and if not, add new pose and count reps
    else if (poses.last != pose) {
      poses.add(pose);
      _countReps(pattern);
    }

    // Time
    _countTime(frameDurationInMs);
  }

  /// Reset repetitions or timer, and clear the poses
  void reset() {
    poses.clear();
    _reps = 0;
    _duration = Duration.zero;
  }

  // For count repetitions
  int _reps = 0;

  /// Count repetitions
  int get repitions => _reps;

  // Check last 5 poses whether they match to the pattern
  void _countReps([List<String>? pattern]) {
    pattern ??= ['low', 'middle', 'high', 'middle', 'low'];

    if (pattern.length > poses.length) return;

    // Take last poses
    final lastPoses = poses.sublist(poses.length - pattern.length);

    // Check the match
    bool match = true;
    for (var i = 0; i < pattern.length; i++) {
      if (lastPoses[i] != pattern[i]) {
        match = false;
        break;
      }
    }
    if (match) {
      _reps++;
    }

    // poses.clear();
  }

  Duration _duration = Duration.zero;

  /// Get time in milliseconds
  int get ms => _duration.inMilliseconds;

  /// Count time
  ///
  /// [frameDurationInMs] - duration in milliseconds.
  void _countTime(int frameDurationInMs) =>
      _duration += Duration(milliseconds: frameDurationInMs);
}
