import 'package:flutter/material.dart';

extension DurationX on Duration {
  String get mmss {
    final total = inSeconds.clamp(0, 9999);
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

extension BuildContextX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isCompact => screenSize.shortestSide < 360;
}

extension IntX on int {
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}
