import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// A custom painter class for drawing detected poses onto a canvas.
class PosePainter extends CustomPainter {
  // The detected pose containing all the landmarks.
  final Pose pose;
  // This is used for scaling.
  final Size imageSize;

  PosePainter({required this.pose, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint object (the skeleton).
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    // Paint object (the joints).
    final dotPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
    
    // Iterate through all landmarks to draw them as dots
    pose.landmarks.forEach((_, landmark) {
     
      final dx = landmark.x * size.width / imageSize.width;
      final dy = landmark.y * size.height / imageSize.height;

      // Draw a small red circle at the landmark's scaled position.
      canvas.drawCircle(Offset(dx, dy), 3, dotPaint);
    });

    // Helper function to draw a line between two specified landmarks.
    void drawLine(PoseLandmarkType type1, PoseLandmarkType type2) {
      final PoseLandmark? landmark1 = pose.landmarks[type1];
      final PoseLandmark? landmark2 = pose.landmarks[type2];

      // If both landmarks were found, draw a line between them.
      if (landmark1 != null && landmark2 != null) {
        final dx1 = landmark1.x * size.width / imageSize.width;
        final dy1 = landmark1.y * size.height / imageSize.height;
        final dx2 = landmark2.x * size.width / imageSize.width;
        final dy2 = landmark2.y * size.height / imageSize.height;
        canvas.drawLine(Offset(dx1, dy1), Offset(dx2, dy2), paint);
      }
    }

     // --- Draw the skeleton ---

    // Torso
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

    // Arms
    drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

     // Legs
    drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Returning true forces the painter to redraw on every frame
    return true; 
  }
}