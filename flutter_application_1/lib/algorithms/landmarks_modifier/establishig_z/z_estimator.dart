import 'dart:math' as math;
import '../../models/landmark.dart';

// кости ахахахах
class Bone {
  final int i;
  final int j;
  final String ni;
  final String nj;

  const Bone(this.i, this.j, this.ni, this.nj);
}

class BodyMeasurements {
  final Map<String, double> _len;

  const BodyMeasurements(this._len);

  double? length(String a, String b) => _len["$a-$b"] ?? _len["$b-$a"];
}

// body measurments из твоей таблицы
final BodyMeasurements bodyMeasurements = BodyMeasurements({
  "LEFT_WRIST-LEFT_ELBOW": 28.4,
  "RIGHT_WRIST-RIGHT_ELBOW": 28.4,
  "LEFT_ELBOW-LEFT_SHOULDER": 30.8,
  "RIGHT_ELBOW-RIGHT_SHOULDER": 30.8,
  "LEFT_SHOULDER-RIGHT_SHOULDER": 46.4,
  "LEFT_SHOULDER-LEFT_HIP": 60.8,
  "RIGHT_SHOULDER-RIGHT_HIP": 60.8,
  "LEFT_HIP-RIGHT_HIP": 36.0,
  "LEFT_HIP-LEFT_KNEE": 50.8,
  "RIGHT_HIP-RIGHT_KNEE": 50.8,
  "LEFT_KNEE-LEFT_ANKLE": 47.6,
  "RIGHT_KNEE-RIGHT_ANKLE": 47.6,
});

// skelet
final List<Bone> skeleton = [
  Bone(11, 13, "LEFT_SHOULDER", "LEFT_ELBOW"),
  Bone(13, 15, "LEFT_ELBOW", "LEFT_WRIST"),
  Bone(12, 14, "RIGHT_SHOULDER", "RIGHT_ELBOW"),
  Bone(14, 16, "RIGHT_ELBOW", "RIGHT_WRIST"),
  Bone(11, 12, "LEFT_SHOULDER", "RIGHT_SHOULDER"),
  Bone(23, 24, "LEFT_HIP", "RIGHT_HIP"),
  Bone(11, 23, "LEFT_SHOULDER", "LEFT_HIP"),
  Bone(12, 24, "RIGHT_SHOULDER", "RIGHT_HIP"),
  Bone(23, 25, "LEFT_HIP", "LEFT_KNEE"),
  Bone(25, 27, "LEFT_KNEE", "LEFT_ANKLE"),
  Bone(24, 26, "RIGHT_HIP", "RIGHT_KNEE"),
  Bone(26, 28, "RIGHT_KNEE", "RIGHT_ANKLE"),
];

//медиана списка, чтоб определить масштаб
double _median(List<double> v) {
  if (v.isEmpty) return 1.0;
  v.sort();
  final n = v.length;
  return n.isOdd ? v[n >> 1] : 0.5 * (v[n ~/ 2 - 1] + v[n ~/ 2]);
}

//и вот тут начинается основая функция

/// - [centerOnPelvis] центр по тазу
/// - [centerOnlyActive] центр по активным точкам
/// - [keepInactiveAtZero] точки без активности просто на ноль
/// - [scaleBoost] чуть-чуть увеличиваем длину, чтобы чаще появлялся ненулевая зетка
/// - [zGain] умножитель для выразительности глубины на графике.
List<Landmark> estimateZForImageLandmarks(
  List<Landmark> lms, {
  BodyMeasurements? bm,
  double visibilityThreshold = 0.5,
  int smoothPasses = 2,
  double smoothLambda = 0.2,
  bool centerOnPelvis = true,
  bool centerOnlyActive = true,
  bool keepInactiveAtZero = true,
  double scaleBoost = 1.12,
  double zGain = 1.6,
}) {
  final measurements = bm ?? bodyMeasurements;

  // стартовый масштаб s по медиане d_xy / L 
  final List<double> scales = [];
  for (final b in skeleton) {
    if (b.i >= lms.length || b.j >= lms.length) continue;
    final a = lms[b.i];
    final c = lms[b.j];
    final L = measurements.length(b.ni, b.nj);
    if (L == null) continue;
    if (a.visibility < visibilityThreshold ||
        c.visibility < visibilityThreshold) {
      continue;
    }
    final dx = a.x - c.x;
    final dy = a.y - c.y;
    final dxy = math.sqrt(dx * dx + dy * dy);
    if (dxy > 1e-6) {
      scales.add(dxy / L);
    }
  }
  double s = _median(scales.isEmpty ? [1.0] : scales);
  s *= scaleBoost;

  // добираем недостающую глубину по каждой кости
  final List<double> z = List<double>.filled(lms.length, 0.0);
  final List<int> count = List<int>.filled(lms.length, 0);

  for (final b in skeleton) {
    if (b.i >= lms.length || b.j >= lms.length) continue;
    final a = lms[b.i];
    final c = lms[b.j];
    final L = measurements.length(b.ni, b.nj);
    if (L == null) continue;
    if (a.visibility < visibilityThreshold ||
        c.visibility < visibilityThreshold) {
      continue;
    }

    final dx = a.x - c.x;
    final dy = a.y - c.y;
    final dxy2 = dx * dx + dy * dy;
    final target2 = (s * L) * (s * L);

    if (target2 > dxy2 + 1e-9) {
      final dz = math.sqrt(target2 - dxy2);
      // эвристика: точка с большей visibility чуть "ближе" к камере, порекомендовал чатик
      final zi = (a.visibility >= c.visibility) ? -dz * 0.5 : dz * 0.5;
      final zj = -zi;
      z[b.i] += zi;
      z[b.j] += zj;
      count[b.i]++;
      count[b.j]++;
    }
  }

  for (int i = 0; i < z.length; i++) {
    if (count[i] > 0) z[i] /= count[i];
  }

  // сглаживание по рёбрам
  for (int pass = 0; pass < smoothPasses; pass++) {
    for (final b in skeleton) {
      if (b.i >= z.length || b.j >= z.length) continue;
      final i = b.i, j = b.j;
      final avg = 0.5 * (z[i] + z[j]);
      z[i] = z[i] + smoothLambda * (avg - z[i]);
      z[j] = z[j] + smoothLambda * (avg - z[j]);
    }
  }

  // центрирование
  double pivot = 0.0;
  int pivotCnt = 0;

  if (centerOnPelvis) {
    for (final idx in [23, 24, 11, 12]) {
      if (idx < z.length) {
        pivot += z[idx];
        pivotCnt++;
      }
    }
  } else if (centerOnlyActive) {
    for (int i = 0; i < z.length; i++) {
      if (count[i] > 0) {
        pivot += z[i];
        pivotCnt++;
      }
    }
  } else {
    pivot = z.isEmpty ? 0.0 : z.reduce((a, b) => a + b);
    pivotCnt = z.length;
  }

  if (pivotCnt > 0) pivot /= pivotCnt;
  for (int i = 0; i < z.length; i++) {
    z[i] -= pivot;
  }

  if (keepInactiveAtZero) {
    for (int i = 0; i < z.length; i++) {
      if (count[i] == 0) z[i] = 0.0;
    }
  }

  // усиление глубины
  return List.generate(
    lms.length,
    (k) => lms[k].copyWith(z: z[k] * zGain),
  );
}
