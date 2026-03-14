import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Presence App Theme — Material Design 3
/// Provides both light and dark themes with full MD3 colour scheme.

class PresenceTheme {
  PresenceTheme._();

  // ── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: PresenceTypography.textTheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: PresenceColors.background,
    splashFactory: InkSparkle.splashFactory,

    // AppBar
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: PresenceColors.surface,
      foregroundColor: PresenceColors.onSurface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: PresenceColors.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: PresenceTypography.textTheme.titleLarge?.copyWith(
        color: PresenceColors.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),

    // Bottom Navigation
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PresenceColors.surface,
      indicatorColor: PresenceColors.primaryContainer,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return PresenceTypography.navigationLabel.copyWith(
            color: PresenceColors.primary,
          );
        }
        return PresenceTypography.navigationLabel.copyWith(
          color: PresenceColors.onSurfaceDim,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: PresenceColors.primary,
            size: 24,
          );
        }
        return const IconThemeData(
          color: PresenceColors.onSurfaceDim,
          size: 24,
        );
      }),
      elevation: 3,
      shadowColor: PresenceColors.scrim.withOpacity(0.12),
    ),

    // Cards
    cardTheme: CardThemeData(
      color: PresenceColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PresenceColors.outlineVariant, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),

    // Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PresenceColors.primary,
        foregroundColor: PresenceColors.onPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 56),
        textStyle: PresenceTypography.textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    // Filled Buttons
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PresenceColors.primary,
        foregroundColor: PresenceColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 56),
        textStyle: PresenceTypography.textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    // Text Buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PresenceColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(48, 48),
        textStyle: PresenceTypography.textTheme.labelLarge,
      ),
    ),

    // Outlined Buttons
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PresenceColors.primary,
        side: const BorderSide(color: PresenceColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 56),
        textStyle: PresenceTypography.textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PresenceColors.primary,
      foregroundColor: PresenceColors.onPrimary,
      elevation: 4,
      highlightElevation: 8,
      shape: CircleBorder(),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PresenceColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PresenceColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PresenceColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: PresenceTypography.textTheme.bodyMedium?.copyWith(
        color: PresenceColors.onSurfaceDim,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: PresenceColors.surfaceContainer,
      selectedColor: PresenceColors.primaryContainer,
      labelStyle: PresenceTypography.textTheme.labelMedium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      side: BorderSide.none,
    ),

    // BottomSheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: PresenceColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      showDragHandle: true,
      dragHandleColor: PresenceColors.outlineVariant,
      dragHandleSize: Size(32, 4),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: PresenceColors.outlineVariant,
      thickness: 1,
      space: 1,
    ),

    // List Tile
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minVerticalPadding: 12,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PresenceColors.onPrimary;
        return PresenceColors.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return PresenceColors.primary;
        return PresenceColors.surfaceVariant;
      }),
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: PresenceColors.primary,
      thumbColor: PresenceColors.primary,
      overlayColor: PresenceColors.primary.withOpacity(0.12),
      inactiveTrackColor: PresenceColors.outlineVariant,
      trackHeight: 4,
    ),

    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: PresenceColors.primary,
      linearTrackColor: PresenceColors.primaryContainer,
      linearMinHeight: 6,
      circularTrackColor: PresenceColors.primaryContainer,
    ),

    // Snack Bar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PresenceColors.onSurface,
      contentTextStyle: PresenceTypography.textTheme.bodyMedium?.copyWith(
        color: PresenceColors.surface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: PresenceColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: PresenceTypography.textTheme.headlineSmall,
      contentTextStyle: PresenceTypography.textTheme.bodyMedium,
      elevation: 6,
    ),
  );

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => light.copyWith(
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: PresenceColors.backgroundDark,
    appBarTheme: light.appBarTheme.copyWith(
      backgroundColor: PresenceColors.surfaceDark,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: PresenceColors.surfaceDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
    cardTheme: light.cardTheme.copyWith(
      color: PresenceColors.surfaceDark,
    ),
    navigationBarTheme: light.navigationBarTheme.copyWith(
      backgroundColor: PresenceColors.surfaceDark,
    ),
  );

  // ── ColorScheme — Light ──────────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: PresenceColors.primary,
    onPrimary: PresenceColors.onPrimary,
    primaryContainer: PresenceColors.primaryContainer,
    onPrimaryContainer: PresenceColors.onPrimaryContainer,
    secondary: PresenceColors.secondary,
    onSecondary: PresenceColors.onSecondary,
    secondaryContainer: PresenceColors.secondaryContainer,
    onSecondaryContainer: PresenceColors.onSecondaryContainer,
    tertiary: PresenceColors.tertiary,
    onTertiary: PresenceColors.onTertiary,
    tertiaryContainer: PresenceColors.tertiaryContainer,
    onTertiaryContainer: PresenceColors.onSurface,
    error: PresenceColors.error,
    onError: PresenceColors.onError,
    errorContainer: PresenceColors.errorContainer,
    onErrorContainer: PresenceColors.onErrorContainer,
    surface: PresenceColors.surface,
    onSurface: PresenceColors.onSurface,
    surfaceContainerHighest: PresenceColors.surfaceVariant,
    onSurfaceVariant: PresenceColors.onSurfaceVariant,
    outline: PresenceColors.outline,
    outlineVariant: PresenceColors.outlineVariant,
    scrim: PresenceColors.scrim,
    inverseSurface: PresenceColors.onSurface,
    onInverseSurface: PresenceColors.surface,
    inversePrimary: PresenceColors.primaryDark,
    surfaceTint: PresenceColors.primary,
  );

  // ── ColorScheme — Dark ───────────────────────────────────────────────────
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: PresenceColors.primaryDark,
    onPrimary: Color(0xFF003731),
    primaryContainer: PresenceColors.primaryContainerDark,
    onPrimaryContainer: Color(0xFFA7F3EB),
    secondary: Color(0xFFB0C9C5),
    onSecondary: Color(0xFF1B3430),
    secondaryContainer: Color(0xFF334B47),
    onSecondaryContainer: Color(0xFFCCE5E0),
    tertiary: Color(0xFFBBC4FF),
    onTertiary: Color(0xFF232D8A),
    tertiaryContainer: Color(0xFF3B4AA0),
    onTertiaryContainer: Color(0xFFDDE1FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: PresenceColors.surfaceDark,
    onSurface: Color(0xFFDDE4E1),
    surfaceContainerHighest: PresenceColors.surfaceVariantDark,
    onSurfaceVariant: Color(0xFFBEC9C5),
    outline: Color(0xFF899390),
    outlineVariant: PresenceColors.surfaceVariantDark,
    scrim: PresenceColors.scrim,
    inverseSurface: Color(0xFFDDE4E1),
    onInverseSurface: Color(0xFF2C3330),
    inversePrimary: PresenceColors.primary,
    surfaceTint: PresenceColors.primaryDark,
  );
}
