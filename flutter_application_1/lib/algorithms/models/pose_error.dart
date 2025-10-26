import 'body_parts.dart';

/// Class that represents pose name and error for each body part
class PoseError {
  /// Pose name
  final String poseName;

  /// Error(error_x, error_y, error_z) for each body part
  final Map<BodyParts, List<double>> error;

  const PoseError(this.poseName, this.error);
}
