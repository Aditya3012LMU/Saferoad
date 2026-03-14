import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

/// Utility helpers for safety score display

class SafetyScoreUtils {
  SafetyScoreUtils._();

  static Color colorForScore(int score) {
    if (score >= 75) return PresenceColors.safeGreen;
    if (score >= 50) return PresenceColors.cautionAmber;
    return PresenceColors.dangerRed;
  }

  static Color surfaceForScore(int score) {
    if (score >= 75) return PresenceColors.safeGreenSurface;
    if (score >= 50) return PresenceColors.cautionAmberSurface;
    return PresenceColors.dangerRedSurface;
  }

  static String labelForScore(int score) {
    if (score >= 80) return 'Safe';
    if (score >= 65) return 'Mostly Safe';
    if (score >= 50) return 'Moderate';
    if (score >= 35) return 'Caution';
    return 'Unsafe';
  }

  static IconData iconForScore(int score) {
    if (score >= 75) return Icons.shield_rounded;
    if (score >= 50) return Icons.shield_outlined;
    return Icons.warning_amber_rounded;
  }

  static String descriptionForScore(int score) {
    if (score >= 80) return 'Well-lit, high pedestrian activity';
    if (score >= 65) return 'Generally safe with moderate activity';
    if (score >= 50) return 'Exercise normal caution';
    if (score >= 35) return 'Low foot traffic, stay alert';
    return 'High incident rate — consider alternate route';
  }
}

/// Map helper for formatting distances
class MapHelpers {
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    return '${km.toStringAsFixed(1)} km';
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  static String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
