import 'dart:convert';
import 'package:flutter/services.dart';
import 'landmark.dart';
import 'body_parts.dart';

class TrainerTemplate {
  /// Exercise name
  final String exerciseName;

  /// Description
  final String description;

  /// Type
  final String type;

  /// Start template
  final String startTemplate;

  /// Normalized landmarks of specific pose
  final Map<String, List<Landmark>> normPoseLandmarks;

  /// Static points, that mostly never move
  final List<BodyParts> staticPoints;

  /// Get instance from metadata.
  static Future<TrainerTemplate> fromMetadata(String exerciseName) async {

    // Read json
    final contents = await rootBundle.loadString('assets/data/metadata.json');

    // Make it list
    final data = List.from(jsonDecode(contents));

    // Search for exercise that contains the same exercise name
    for (var d in data) {
      Map<String, dynamic> item = d;
      if (item['name'].toString().toLowerCase().replaceAll(r' ', '') ==
          exerciseName.toLowerCase().replaceAll(r' ', '')) {
        // Return instance based on this json
        return TrainerTemplate._fromJson(item);
      }
    }

    throw ArgumentError("Not found such exercise : $exerciseName");
  }

  factory TrainerTemplate._fromJson(Map<String, dynamic> data) {
    // Name
    final name = data['name'].toString();

    // Static points, converting them to BodyParts enum
    final staticPoints = (data['static_points'] as List)
        .map(
          (point) => BodyParts.values.firstWhere(
            (bp) => bp.name.toUpperCase() == point.toString().toUpperCase(),
            orElse: () => throw ArgumentError('Unknown body part: $point'),
          ),
        )
        .toList(growable: false);

    // Prepare map
    final Map<String, List<Landmark>> normPoseLandmarks = {};

    // Iterate through the landmarks and add their data to class Landmakr
    final templates = data['templates'] as Map<String, dynamic>;
    templates.forEach((poseName, rawList) {
      final landmarksList = (rawList as List)
          .map((lm) {
            final landmark = lm as Map<String, dynamic>;
            return Landmark(
              index: landmark['index'] as int,
              name: landmark['name'] as String,
              x: (landmark['x'] as num).toDouble(),
              y: (landmark['y'] as num).toDouble(),
              z: (landmark['z'] as num).toDouble(),
              visibility: (landmark['visibility'] as num?)?.toDouble() ?? 1.0,
            );
          })
          .toList(growable: false);

      // Add landmark to our prepared map
      normPoseLandmarks[poseName] = List<Landmark>.from(landmarksList);
    });

    // Return instance
    return TrainerTemplate._internal(
      name,
      data['description'],
      staticPoints,
      data['type'],
      data['start_template'],
      normPoseLandmarks,
    );
  }

  /// Private constructor
  const TrainerTemplate._internal(
    this.exerciseName,
    this.description,
    this.staticPoints,
    this.type,
    this.startTemplate,
    this.normPoseLandmarks,
  );
}
