import 'package:flutter/material.dart';

import '../models/ortha_status_model.dart';

abstract final class OrthaStatusColors {
  static const Color green = Color(0xFF4CAF50);

  static const Color yellow = Color(0xFFFBC02D);

  static const Color orange = Color(0xFFFF9800);

  static const Color red = Color(0xFFD32F2F);

  static Color forLevel(OrthaStatusLevel level) {
    switch (level) {
      case OrthaStatusLevel.green:
        return green;

      case OrthaStatusLevel.yellow:
        return yellow;

      case OrthaStatusLevel.orange:
        return orange;

      case OrthaStatusLevel.red:
        return red;
    }
  }
}
