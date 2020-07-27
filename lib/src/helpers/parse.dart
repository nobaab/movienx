import 'package:flutter/material.dart';

class Parse {
  static Color toColor(String color) {
    return Color(int.parse(color.replaceFirst('#', '0x'))).withOpacity(1.0);
  }

  static int toHex(String color) {
    return int.parse(color.replaceFirst('#', '0xFF'));
  }

  static bool toBool(dynamic value) {
    if (value is String) {
      value = int.parse(value);
    }
    return (value > 0) ? true : false;
  }

  static int checkInt(dynamic value) {
    if (value is String) {
      return int.parse(value);
    } else {
      return value;
    }
  }

  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value;
    }
  }
}
