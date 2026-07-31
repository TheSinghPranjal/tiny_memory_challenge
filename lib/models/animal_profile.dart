import 'package:flutter/material.dart';

/// Fixed animal profiles — cannot add, rename, or delete.
enum AnimalProfile {
  bear,
  panda,
  penguin,
  lion,
  deer,
  hawk,
  tiger;

  String get id => name;

  String get displayName {
    switch (this) {
      case AnimalProfile.bear:
        return 'Bear';
      case AnimalProfile.panda:
        return 'Panda';
      case AnimalProfile.penguin:
        return 'Penguin';
      case AnimalProfile.lion:
        return 'Lion';
      case AnimalProfile.deer:
        return 'Deer';
      case AnimalProfile.hawk:
        return 'Hawk';
      case AnimalProfile.tiger:
        return 'Tiger';
    }
  }

  IconData get icon {
    switch (this) {
      case AnimalProfile.bear:
        return Icons.pets;
      case AnimalProfile.panda:
        return Icons.cruelty_free;
      case AnimalProfile.penguin:
        return Icons.downhill_skiing;
      case AnimalProfile.lion:
        return Icons.emoji_nature;
      case AnimalProfile.deer:
        return Icons.forest;
      case AnimalProfile.hawk:
        return Icons.flight;
      case AnimalProfile.tiger:
        return Icons.whatshot;
    }
  }

  /// Distinct soft avatar colors for each animal.
  Color get color {
    switch (this) {
      case AnimalProfile.bear:
        return const Color(0xFFB08968);
      case AnimalProfile.panda:
        return const Color(0xFF6B7280);
      case AnimalProfile.penguin:
        return const Color(0xFF4A90A4);
      case AnimalProfile.lion:
        return const Color(0xFFE8A838);
      case AnimalProfile.deer:
        return const Color(0xFFC4A484);
      case AnimalProfile.hawk:
        return const Color(0xFF7BA3C9);
      case AnimalProfile.tiger:
        return const Color(0xFFE07A3D);
    }
  }

  String get emoji {
    switch (this) {
      case AnimalProfile.bear:
        return '🐻';
      case AnimalProfile.panda:
        return '🐼';
      case AnimalProfile.penguin:
        return '🐧';
      case AnimalProfile.lion:
        return '🦁';
      case AnimalProfile.deer:
        return '🦌';
      case AnimalProfile.hawk:
        return '🦅';
      case AnimalProfile.tiger:
        return '🐯';
    }
  }

  static AnimalProfile fromId(String id) {
    return AnimalProfile.values.firstWhere(
      (p) => p.id == id,
      orElse: () => AnimalProfile.panda,
    );
  }
}
