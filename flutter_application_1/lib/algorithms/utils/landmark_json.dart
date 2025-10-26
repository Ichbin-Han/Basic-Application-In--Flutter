import '../models/landmark.dart';

extension LandmarkJson on Landmark {
  Map<String, dynamic> toJson() => {
    'index': index,
    'name': name,
    'x': x,
    'y': y,
    'z': z,
    'visibility': visibility,
  };
}
