import 'package:flutter/material.dart';

/// Presence App Color System — Material Design 3
/// Anchored around safety-first design: teal primary, semantic alert colors.

class PresenceColors {
  PresenceColors._();

  // ── Primary Palette (Deep Teal / Emerald) ────────────────────────────────
  static const Color primary = Color(0xFF00897B);       // Teal 600
  static const Color primaryContainer = Color(0xFFB2DFDB); // Teal 100
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF00352F);

  static const Color primaryDark = Color(0xFF26A69A);   // Teal 400 — dark mode
  static const Color primaryContainerDark = Color(0xFF004D45);

  // ── Secondary Palette (Slate Blue) ───────────────────────────────────────
  static const Color secondary = Color(0xFF546E7A);     // Blue Grey 600
  static const Color secondaryContainer = Color(0xFFCFD8DC);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1A2B32);

  // ── Tertiary (Warm Indigo — Profile/CTA) ─────────────────────────────────
  static const Color tertiary = Color(0xFF5C6BC0);
  static const Color tertiaryContainer = Color(0xFFE8EAF6);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ── Safety Semantic Colors ────────────────────────────────────────────────
  static const Color safeGreen = Color(0xFF2E7D32);    // Safe streets
  static const Color safeGreenLight = Color(0xFF66BB6A);
  static const Color safeGreenSurface = Color(0xFFE8F5E9);

  static const Color cautionAmber = Color(0xFFF57F17); // Caution areas
  static const Color cautionAmberLight = Color(0xFFFFCA28);
  static const Color cautionAmberSurface = Color(0xFFFFF8E1);

  static const Color dangerRed = Color(0xFFC62828);    // Danger zones
  static const Color dangerRedLight = Color(0xFFEF5350);
  static const Color dangerRedSurface = Color(0xFFFFEBEE);

  static const Color alertOrange = Color(0xFFE64A19);  // Active alerts
  static const Color alertOrangeLight = Color(0xFFFF7043);
  static const Color alertOrangeSurface = Color(0xFFFBE9E7);

  // ── SOS ──────────────────────────────────────────────────────────────────
  static const Color sosRed = Color(0xFFD32F2F);
  static const Color sosRedPulse = Color(0xFFFF5252);
  static const Color sosRedDark = Color(0xFFB71C1C);

  // ── Map Layer Colors ──────────────────────────────────────────────────────
  static const Color mapSafeRoute = Color(0xFF00897B);
  static const Color mapCautionRoute = Color(0xFFF9A825);
  static const Color mapDangerZone = Color(0xFFE53935);
  static const Color mapPoliceStation = Color(0xFF1565C0);
  static const Color mapPoorLighting = Color(0xFF6D4C41);
  static const Color mapCrowdDensity = Color(0xFF7B1FA2);

  // ── Surface & Background ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F7F6);      // Light neutral gray
  static const Color backgroundDark = Color(0xFF0E1412);

  static const Color surface = Color(0xFFFFFFFF);          // Cards
  static const Color surfaceDark = Color(0xFF1C2422);

  static const Color surfaceVariant = Color(0xFFDAE5E2);
  static const Color surfaceVariantDark = Color(0xFF3F4946);

  static const Color surfaceContainer = Color(0xFFEAF0EE);
  static const Color surfaceContainerDark = Color(0xFF212A27);

  static const Color surfaceContainerHigh = Color(0xFFE0EDEA);
  static const Color surfaceContainerHighDark = Color(0xFF2C3531);

  // ── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFB3261E);
  static const Color errorContainer = Color(0xFFF9DEDC);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410E0B);

  // ── Outline ──────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF6F7975);
  static const Color outlineVariant = Color(0xFFBEC9C5);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color onBackground = Color(0xFF191C1B);
  static const Color onSurface = Color(0xFF191C1B);
  static const Color onSurfaceVariant = Color(0xFF3F4946);
  static const Color onSurfaceDim = Color(0xFF6B7775);

  // ── Overlay / Scrim ──────────────────────────────────────────────────────
  static const Color scrim = Color(0xFF000000);
  static const Color mapOverlay = Color(0x1A00897B); // 10% teal

  // ── Gradient Definitions ─────────────────────────────────────────────────
  static const LinearGradient safeGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF004D45), Color(0xFF00897B), Color(0xFF26A69A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sosGradient = LinearGradient(
    colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mapBottomFade = LinearGradient(
    colors: [Colors.transparent, Color(0xCCF5F7F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
