import 'package:flutter/material.dart';

/// Calm teal/indigo seed (PRD §7.2): muted like Clue/Visible, never
/// clinical red or "sexy".
const seedColor = Color(0xFF3E6F8E);

/// [seed] is the wallpaper accent when dynamic colour is on.
ThemeData buildTheme(Brightness brightness, {Color? seed}) {
  final scheme = ColorScheme.fromSeed(
      seedColor: seed ?? seedColor, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    // System Roboto: no font bundling or downloading.
    visualDensity: VisualDensity.standard,
    // Faster than the default zoom transition on low-end devices.
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    }),
  );
}
