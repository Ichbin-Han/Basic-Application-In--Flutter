import 'dart:math';
import '../models/vector.dart';
import '../models/body_parts.dart';

// Получить VectorInfo из мапы по имени ключа
Vector? _vecFromMap(Map<BodyParts, List<double>> pts, BodyParts name) {
  final v = pts[name];
  if (v != null && v.length >= 3) return Vector(v[0], v[1], v[2]);
  return null;
}

// Получить точку [x, y] из мапы по имени
List<double>? _pointFromMap(Map<BodyParts, List<double>> pts, BodyParts name) {
  final v = pts[name];
  if (v != null && v.length >= 2) return v;
  return null;
}

// Анализ карты векторов (значения [dx,dy]) и составление подсказок.
// threshold — минимальная значимая длина (по умолчанию 0.05).
List<String> analyzeLandmarks(
  Map<BodyParts, List<double>> pts, {
  double threshold = 0.05,
}) {
  final hints = <String>[];

  // Руки — движение запястий
  final leftWrist = _vecFromMap(pts, BodyParts.LEFT_WRIST);
  final rightWrist = _vecFromMap(pts, BodyParts.RIGHT_WRIST);

  if (leftWrist != null && rightWrist != null) {
    final lwOk = leftWrist.length >= threshold;
    final rwOk = rightWrist.length >= threshold;
    if (lwOk || rwOk) {
      final leftUp = leftWrist.directionLabel().contains('up');
      final rightUp = rightWrist.directionLabel().contains('up');
      if (leftUp && rightUp) {
        final avg = (leftWrist.length + rightWrist.length) / 2;
        if (avg > 0.12) {
          hints.add('Raise your arms high');
        } else if (avg > 0.06) {
          hints.add('Raise your arms slightly');
        } else {
          hints.add('Raise your arms a bit higher');
        }
      } else if (leftUp && !rightUp) {
        hints.add('Raise your right arm to balance');
      } else if (!leftUp && rightUp) {
        hints.add('Raise your left arm to balance');
      }

      // Баланс движений рук
      if (lwOk && rwOk) {
        final ratio = (leftWrist.length + 1e-9) / (rightWrist.length + 1e-9);
        if (ratio > 1.7) hints.add('Left arm moves more — balance movements');
        if (ratio < 1 / 1.7) {
          hints.add('Right arm moves more — balance movements');
        }
      } else {
        if (lwOk) hints.add('Left arm: ${leftWrist.shortHint()}');
        if (rwOk) hints.add('Right arm: ${rightWrist.shortHint()}');
      }
    }
  } else {
    if (leftWrist != null && leftWrist.length >= threshold) {
      hints.add('Left arm: ${leftWrist.shortHint()}');
    }
    if (rightWrist != null && rightWrist.length >= threshold) {
      hints.add('Right arm: ${rightWrist.shortHint()}');
    }
  }

  // Ноги / ширина стойки
  final leftAnkle = _pointFromMap(pts, BodyParts.LEFT_ANKLE);
  final rightAnkle = _pointFromMap(pts, BodyParts.RIGHT_ANKLE);
  final leftHip = _pointFromMap(pts, BodyParts.LEFT_HIP);
  final rightHip = _pointFromMap(pts, BodyParts.RIGHT_HIP);

  if (leftAnkle != null && rightAnkle != null) {
    final dx = (leftAnkle[0] - rightAnkle[0]).abs();
    if (dx < 0.08) {
      hints.add('Place your feet wider');
    } else if (dx > 0.28) {
      hints.add('Feet are too wide — bring them closer');
    }
  } else if (leftHip != null && rightHip != null) {
    final dx = (leftHip[0] - rightHip[0]).abs();
    if (dx < 0.06) hints.add('Widen your hips for stability');
  }

  // Баланс корпуса
  final nose = _pointFromMap(pts, BodyParts.NOSE);
  if (nose != null && leftHip != null && rightHip != null) {
    final midHipX = (leftHip[0] + rightHip[0]) / 2;
    final diff = nose[0] - midHipX;
    if (diff > 0.04) {
      hints.add('Body leaning to the right — center yourself');
    } else if (diff < -0.04) {
      hints.add('Body leaning to the left — center yourself');
    }
  }

  // Плечи и спина
  final leftShoulder = _pointFromMap(pts, BodyParts.LEFT_SHOULDER);
  if (leftShoulder != null && leftHip != null) {
    final shoulderY = leftShoulder[1];
    final hipY = leftHip[1];
    final gap = hipY - shoulderY;
    if (gap < 0.06) {
      hints.add('Straighten your back — pull your shoulders up');
    } else if (gap > 0.35) {
      hints.add('You are leaning too much — straighten up');
    }
  }

  // Колени
  final leftKnee = _pointFromMap(pts, BodyParts.LEFT_KNEE);
  final rightKnee = _pointFromMap(pts, BodyParts.RIGHT_KNEE);
  if (leftKnee != null &&
      rightKnee != null &&
      leftAnkle != null &&
      rightAnkle != null) {
    final feetSpread = (leftAnkle[0] - rightAnkle[0]).abs();
    final kneesSpread = (leftKnee[0] - rightKnee[0]).abs();
    if (feetSpread < 0.09 && kneesSpread > 0.06) {
      hints.add('Knees splay with close feet — place feet wider');
    }
  }

  // Уровень плеч
  final rightShoulder = _pointFromMap(pts, BodyParts.RIGHT_SHOULDER);
  if (leftShoulder != null && rightShoulder != null) {
    final dy = (leftShoulder[1] - rightShoulder[1]).abs();
    if (dy > 0.06) hints.add('Shoulders uneven — level your shoulders');
  }

  // Убираем дубликаты
  final unique = <String>{};
  final out = <String>[];
  for (final h in hints) {
    if (!unique.contains(h)) {
      unique.add(h);
      out.add(h);
    }
  }
  if (out.isEmpty) out.add('Pose is good or not enough data for hints');
  return out;
}

// Вычисляем дельты (user - reference)
Map<BodyParts, List<double>> computeDeltas(
  Map<BodyParts, List<double>> user,
  Map<BodyParts, List<double>> reference,
) {
  final out = <BodyParts, List<double>>{};
  for (final e in reference.entries) {
    final name = e.key;
    final ref = e.value;
    final u = user[name];
    if (u != null && ref.length >= 2 && u.length >= 2) {
      out[name] = [u[0] - ref[0], u[1] - ref[1], u[2] - ref[2]];
    }
  }
  return out;
}

// Анализ пользователя относительно референса
List<String> analyzeAgainstReference(
  Map<BodyParts, List<double>> user,
  Map<BodyParts, List<double>> reference, {
  double threshold = 0.05,
}) {
  final deltas = computeDeltas(user, reference);
  final hints = <String>[];

  hints.addAll(analyzeLandmarks(deltas, threshold: threshold));

  // Проверка ширины стойки
  final refLeftA = _pointFromMap(reference, BodyParts.LEFT_ANKLE);
  final refRightA = _pointFromMap(reference, BodyParts.RIGHT_ANKLE);
  final userLeftA = _pointFromMap(user, BodyParts.LEFT_ANKLE);
  final userRightA = _pointFromMap(user, BodyParts.RIGHT_ANKLE);

  if (refLeftA != null &&
      refRightA != null &&
      userLeftA != null &&
      userRightA != null) {
    final refSpread = (refRightA[0] - refLeftA[0]).abs();
    final userSpread = (userRightA[0] - userLeftA[0]).abs();
    final spreadDiff = userSpread - refSpread;

    if (spreadDiff > threshold) {
      hints.add('You moved feet wider than reference — stance is wider');
    } else if (spreadDiff < -threshold) {
      hints.add('Feet moved closer than reference — widen your stance');
    } else {
      final ldx = userLeftA[0] - refLeftA[0];
      final rdx = userRightA[0] - refRightA[0];
      if (ldx < -threshold && rdx > threshold) {
        hints.add('You moved feet wider than reference — stance is wider');
      }
      if (ldx > threshold && rdx < -threshold) {
        hints.add('Feet moved closer than reference — widen your stance');
      }
    }
  }

  // Смещение носа
  final noseDelta = deltas[BodyParts.NOSE];
  if (noseDelta != null) {
    if (noseDelta[0] > threshold) {
      hints.add('Body shifted right — center yourself');
    } else if (noseDelta[0] < -threshold) {
      hints.add('Body shifted left — center yourself');
    }
  }

  // Разница по вертикали плеч
  final lShoulderDelta = deltas[BodyParts.LEFT_SHOULDER];
  final rShoulderDelta = deltas[BodyParts.RIGHT_SHOULDER];
  if (lShoulderDelta != null && rShoulderDelta != null) {
    final dy = (lShoulderDelta[1] - rShoulderDelta[1]).abs();
    if (dy > threshold) {
      hints.add('Shoulder mismatch — level your shoulders');
    }
  }

  final unique = <String>{};
  final out = <String>[];
  for (final h in hints) {
    if (!unique.contains(h)) {
      unique.add(h);
      out.add(h);
    }
  }
  if (out.isEmpty) {
    out.add('Pose matches reference or not enough data for hints');
  }
  return out;
}
