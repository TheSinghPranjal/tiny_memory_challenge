import 'package:flutter/material.dart' hide CardTheme;

/// Describes a single "card back" colour set: the resting (idle) colour of
/// the tile, the tone used to emboss the star into it, and the colour used
/// when the tile lights up during the memorise phase.
///
/// [blinkLight]/[blinkDark] are always picked from the opposite side of the
/// colour wheel to [idleLight]/[idleDark], so no matter which theme is
/// active for a given stage, the "lit" state is guaranteed to read as
/// visually distinct from the card's resting colour.
@immutable
class CardTheme {
  const CardTheme({
    required this.name,
    required this.idleLight,
    required this.idleDark,
    required this.idleBorder,
    required this.starColor,
    required this.starHighlight,
    required this.starShadow,
    required this.blinkLight,
    required this.blinkDark,
    required this.blinkGlow,
  });

  final String name;

  // Idle (face-down) card colours.
  final Color idleLight;
  final Color idleDark;
  final Color idleBorder;

  // Embossed star tint + bevel shadow/highlight.
  final Color starColor;
  final Color starHighlight;
  final Color starShadow;

  // "Lit up" colours — always complementary to idleLight/idleDark.
  final Color blinkLight;
  final Color blinkDark;
  final Color blinkGlow;
}

/// One theme per colour family, spread evenly around the hue wheel so
/// consecutive stages never look alike, and each theme's blink colour sits
/// ~180° away from its idle colour.
const List<CardTheme> kCardThemes = [
  // 1. Violet — matches the reference art.
  CardTheme(
    name: 'Violet',
    idleLight: Color(0xFF9C90F2),
    idleDark: Color(0xFF6F5FD8),
    idleBorder: Color(0xFFB7ADF6),
    starColor: Color(0xFF8579E8),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D3B2E90),
    blinkLight: Color(0xFFFFE38A),
    blinkDark: Color(0xFFFFC107),
    blinkGlow: Color(0xFFFFB300),
  ),
  // 2. Ocean Blue
  CardTheme(
    name: 'Ocean Blue',
    idleLight: Color(0xFF6FA6FF),
    idleDark: Color(0xFF3E72E0),
    idleBorder: Color(0xFF9CC1FF),
    starColor: Color(0xFF5C93F5),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D1B3E80),
    blinkLight: Color(0xFFFFAB91),
    blinkDark: Color(0xFFFF7043),
    blinkGlow: Color(0xFFFF5722),
  ),
  // 3. Emerald Green
  CardTheme(
    name: 'Emerald',
    idleLight: Color(0xFF5FDCA8),
    idleDark: Color(0xFF2FAE7F),
    idleBorder: Color(0xFF95EAC5),
    starColor: Color(0xFF4BC896),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D0F5C42),
    blinkLight: Color(0xFFFF9BC5),
    blinkDark: Color(0xFFFF5DA2),
    blinkGlow: Color(0xFFEC407A),
  ),
  // 4. Sunset Coral
  CardTheme(
    name: 'Coral',
    idleLight: Color(0xFFFF9C8B),
    idleDark: Color(0xFFE86A5B),
    idleBorder: Color(0xFFFFC0B4),
    starColor: Color(0xFFF3826F),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D8C2E1F),
    blinkLight: Color(0xFF80E9EF),
    blinkDark: Color(0xFF26C6DA),
    blinkGlow: Color(0xFF00BCD4),
  ),
  // 5. Golden Amber
  CardTheme(
    name: 'Amber',
    idleLight: Color(0xFFFFCE6B),
    idleDark: Color(0xFFF5A623),
    idleBorder: Color(0xFFFFE0A0),
    starColor: Color(0xFFF7B93C),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D8A5A08),
    blinkLight: Color(0xFF8C9DEB),
    blinkDark: Color(0xFF5C6BC0),
    blinkGlow: Color(0xFF3F51B5),
  ),
  // 6. Rose Pink
  CardTheme(
    name: 'Rose',
    idleLight: Color(0xFFFF93C2),
    idleDark: Color(0xFFE85A98),
    idleBorder: Color(0xFFFFC2DC),
    starColor: Color(0xFFF574AC),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D8A2E5C),
    blinkLight: Color(0xFFD4EE80),
    blinkDark: Color(0xFFB4E14D),
    blinkGlow: Color(0xFF9CCC3F),
  ),
  // 7. Teal Cyan
  CardTheme(
    name: 'Teal',
    idleLight: Color(0xFF6FE0E5),
    idleDark: Color(0xFF2AA8B0),
    idleBorder: Color(0xFFA3EEF1),
    starColor: Color(0xFF52CBD1),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D0E5A5F),
    blinkLight: Color(0xFFFF9E80),
    blinkDark: Color(0xFFFF6B4A),
    blinkGlow: Color(0xFFFF5722),
  ),
  // 8. Deep Plum
  CardTheme(
    name: 'Plum',
    idleLight: Color(0xFFC079DA),
    idleDark: Color(0xFF8A3FB0),
    idleBorder: Color(0xFFDBA8E8),
    starColor: Color(0xFFAD65C6),
    starHighlight: Color(0x59FFFFFF),
    starShadow: Color(0x4D551A6B),
    blinkLight: Color(0xFFE4F27A),
    blinkDark: Color(0xFFCFE85A),
    blinkGlow: Color(0xFFAFC93C),
  ),
];

/// Deterministically picks a theme for the given level/stage so every stage
/// gets a different card-set colour. Two different prime multipliers on
/// [level] and [stage] mean advancing either one changes the theme, so
/// back-to-back stages practically never repeat the same colour.
CardTheme cardThemeForStage({required int level, required int stage}) {
  final index = (level * 31 + stage * 17).abs() % kCardThemes.length;
  return kCardThemes[index];
}
