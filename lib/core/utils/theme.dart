import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// VR Safe Modern Theme - Based on Design Screenshots
class AppTheme {
  const AppTheme();

  // VR Safe Brand Colors - Based on New UI Screenshots
  static const Color primaryBlue = Color(0xFFFF6B35); // Main orange from Continue button
  static const Color gradientBlue = Color(0xFFFF6B35); // Orange gradient for dashboard
  static const Color accentOrange = Color(0xFF6B9EFF); // Orange blue streak/fire/tips
  static const Color streakOrange = Color(0xFF4A90E2); // Fire/streak orange
  static const Color successGreen = Color(0xFF10B981); // Green checkmarks/success
  static const Color warningRed = Color(0xFFEF4444); // Red for scam alerts  
  static const Color lightGray = Color(0xFFF8F9FA); // Ultra light background
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white cards
  static const Color textPrimary = Color(0xFF1F2937); // Dark text
  static const Color textSecondary = Color(0xFF6B7280); // Gray text
  static const Color purple = Color(0xFF8B5CF6); // Purple for premium/support
  static const Color yellow = Color(0xFFFBBF24); // Yellow for tips/quiz

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      
      // Primary colors - Main brand blue
      primary: primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: Color(0xFF1565C0),
      
      // Secondary colors - Orange accent
      secondary: accentOrange,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFEF3F2),
      onSecondaryContainer: Color(0xFFEA580C),
      
      // Tertiary colors - Green for success
      tertiary: successGreen,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF0FDF4),
      onTertiaryContainer: Color(0xFF059669),
      
      // Error colors - Red for warnings
      error: warningRed,
      onError: Colors.white,
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFD32F2F),
      
      // Surface colors - Clean whites and light grays
      surface: cardBackground,
      onSurface: textPrimary,
      surfaceVariant: lightGray,
      onSurfaceVariant: textSecondary,
      
      // Background
      background: lightGray,
      onBackground: textPrimary,
      
      // Outline and borders
      outline: Color(0xFFE0E6ED),
      outlineVariant: Color(0xFFF0F4F8),
      
      // Surface containers for cards and elevated elements
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFFAFBFC),
      surfaceContainer: Color(0xFFF5F7FA),
      surfaceContainerHigh: Color(0xFFEBF0F5),
      surfaceContainerHighest: Color(0xFFE1E8ED),
      
      // Inverse colors
      inverseSurface: textPrimary,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF90CAF9),
      
      // Utility colors
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: primaryBlue,
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff051423),
      surfaceTint: Color(0xff516071),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff253443),
      onPrimaryContainer: Color(0xffe7f0ff),
      secondary: Color(0xff0035ac),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4265de),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff1d0d1d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3e2c3e),
      onTertiaryContainer: Color(0xffffe8fa),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffbf9fa),
      onSurface: Color(0xff1b1c1d),
      onSurfaceVariant: Color(0xff404348),
      outline: Color(0xff5c5f64),
      outlineVariant: Color(0xff787b80),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303032),
      inversePrimary: Color(0xffb8c8dc),
      primaryFixed: Color(0xff677688),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4e5d6e),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff496be4),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2b51ca),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff846e82),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff6a5569),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdbd9db),
      surfaceBright: Color(0xfffbf9fa),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f3f4),
      surfaceContainer: Color(0xffefedee),
      surfaceContainerHigh: Color(0xffeae7e9),
      surfaceContainerHighest: Color(0xffe4e2e3),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff051423),
      surfaceTint: Color(0xff516071),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff253443),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff001a61),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff0035ac),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff1d0d1d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3e2c3e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffbf9fa),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff212429),
      outline: Color(0xff404348),
      outlineVariant: Color(0xff404348),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303032),
      inversePrimary: Color(0xffe0edff),
      primaryFixed: Color(0xff354454),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff1f2e3d),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff0035ac),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff002379),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff503d4f),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff382738),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffdbd9db),
      surfaceBright: Color(0xfffbf9fa),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff5f3f4),
      surfaceContainer: Color(0xffefedee),
      surfaceContainerHigh: Color(0xffeae7e9),
      surfaceContainerHighest: Color(0xffe4e2e3),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb8c8dc),
      surfaceTint: Color(0xffb8c8dc),
      onPrimary: Color(0xff233241),
      primaryContainer: Color(0xff0f1e2d),
      onPrimaryContainer: Color(0xff9aa9bd),
      secondary: Color(0xffb7c4ff),
      onSecondary: Color(0xff002682),
      secondaryContainer: Color(0xff375bd4),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xffd9bfd5),
      onTertiary: Color(0xff3c2a3c),
      tertiaryContainer: Color(0xff271728),
      onTertiaryContainer: Color(0xffb9a0b6),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff131315),
      onSurface: Color(0xffe4e2e3),
      onSurfaceVariant: Color(0xffc4c6cc),
      outline: Color(0xff8e9196),
      outlineVariant: Color(0xff44474c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e3),
      inversePrimary: Color(0xff516071),
      primaryFixed: Color(0xffd4e4f8),
      onPrimaryFixed: Color(0xff0d1d2b),
      primaryFixedDim: Color(0xffb8c8dc),
      onPrimaryFixedVariant: Color(0xff394858),
      secondaryFixed: Color(0xffdce1ff),
      onSecondaryFixed: Color(0xff001552),
      secondaryFixedDim: Color(0xffb7c4ff),
      onSecondaryFixedVariant: Color(0xff0239b4),
      tertiaryFixed: Color(0xfff6daf2),
      onTertiaryFixed: Color(0xff261626),
      tertiaryFixedDim: Color(0xffd9bfd5),
      onTertiaryFixedVariant: Color(0xff544153),
      surfaceDim: Color(0xff131315),
      surfaceBright: Color(0xff39393a),
      surfaceContainerLowest: Color(0xff0e0e0f),
      surfaceContainerLow: Color(0xff1b1c1d),
      surfaceContainer: Color(0xff1f2021),
      surfaceContainerHigh: Color(0xff292a2b),
      surfaceContainerHighest: Color(0xff343536),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffbdcce0),
      surfaceTint: Color(0xffb8c8dc),
      onPrimary: Color(0xff071726),
      primaryContainer: Color(0xff8392a5),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffbdc8ff),
      onSecondary: Color(0xff001045),
      secondaryContainer: Color(0xff6989ff),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffdec3da),
      onTertiary: Color(0xff201121),
      tertiaryContainer: Color(0xffa1899f),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff131315),
      onSurface: Color(0xfffcfafb),
      onSurfaceVariant: Color(0xffc8cbd0),
      outline: Color(0xffa0a3a8),
      outlineVariant: Color(0xff808389),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e3),
      inversePrimary: Color(0xff3b495a),
      primaryFixed: Color(0xffd4e4f8),
      onPrimaryFixed: Color(0xff031220),
      primaryFixedDim: Color(0xffb8c8dc),
      onPrimaryFixedVariant: Color(0xff293747),
      secondaryFixed: Color(0xffdce1ff),
      onSecondaryFixed: Color(0xff000c3a),
      secondaryFixedDim: Color(0xffb7c4ff),
      onSecondaryFixedVariant: Color(0xff002b8f),
      tertiaryFixed: Color(0xfff6daf2),
      onTertiaryFixed: Color(0xff1b0b1c),
      tertiaryFixedDim: Color(0xffd9bfd5),
      onTertiaryFixedVariant: Color(0xff433042),
      surfaceDim: Color(0xff131315),
      surfaceBright: Color(0xff39393a),
      surfaceContainerLowest: Color(0xff0e0e0f),
      surfaceContainerLow: Color(0xff1b1c1d),
      surfaceContainer: Color(0xff1f2021),
      surfaceContainerHigh: Color(0xff292a2b),
      surfaceContainerHighest: Color(0xff343536),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffafaff),
      surfaceTint: Color(0xffb8c8dc),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffbdcce0),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffcfaff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffbdc8ff),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffff9fa),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffdec3da),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff131315),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfffafaff),
      outline: Color(0xffc8cbd0),
      outlineVariant: Color(0xffc8cbd0),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e2e3),
      inversePrimary: Color(0xff1c2b3a),
      primaryFixed: Color(0xffd9e8fd),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffbdcce0),
      onPrimaryFixedVariant: Color(0xff071726),
      secondaryFixed: Color(0xffe2e5ff),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffbdc8ff),
      onSecondaryFixedVariant: Color(0xff001045),
      tertiaryFixed: Color(0xfffbdff6),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffdec3da),
      onTertiaryFixedVariant: Color(0xff201121),
      surfaceDim: Color(0xff131315),
      surfaceBright: Color(0xff39393a),
      surfaceContainerLowest: Color(0xff0e0e0f),
      surfaceContainerLow: Color(0xff1b1c1d),
      surfaceContainer: Color(0xff1f2021),
      surfaceContainerHigh: Color(0xff292a2b),
      surfaceContainerHighest: Color(0xff343536),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    
    // Enhanced AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      surfaceTintColor: colorScheme.surfaceTint.withOpacity(0.05),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    
    // Enhanced Card theme
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: colorScheme.shadow.withOpacity(0.08),
      surfaceTintColor: colorScheme.surfaceTint.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Enhanced ElevatedButton theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shadowColor: colorScheme.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Enhanced OutlinedButton theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Enhanced TextButton theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Enhanced InputDecoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    ),
    
    // Enhanced FloatingActionButton theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Enhanced Dialog theme
    dialogTheme: DialogThemeData(
      elevation: 8,
      shadowColor: colorScheme.shadow.withOpacity(0.15),
      surfaceTintColor: colorScheme.surfaceTint.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    ),
    
    // Enhanced BottomSheet theme
    bottomSheetTheme: BottomSheetThemeData(
      elevation: 8,
      shadowColor: colorScheme.shadow.withOpacity(0.15),
      surfaceTintColor: colorScheme.surfaceTint.withOpacity(0.05),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    
    // Enhanced ListTile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    ),
    
    // Enhanced Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      deleteIconColor: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      selectedColor: colorScheme.secondaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSecondaryContainer,
      ),
    ),
    
    // Enhanced Divider theme
    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withOpacity(0.2),
      thickness: 1,
      space: 1,
    ),
    
    // Enhanced Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.onPrimary;
        }
        return colorScheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        return colorScheme.outline.withOpacity(0.3);
      }),
    ),
    
    // Enhanced ProgressIndicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceContainerHighest,
      circularTrackColor: colorScheme.surfaceContainerHighest,
    ),
    
    // Enhanced Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onInverseSurface,
      ),
      actionTextColor: colorScheme.inversePrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
    ),
  );


  List<ExtendedColor> get extendedColors => [
  ];

  // Display Styles - For large scale headings
// displayLarge    - ~57sp - Very large headlines (e.g., landing pages)
// displayMedium   - ~45sp - Large headlines
// displaySmall    - ~36sp - Medium headlines

// Headline Styles - For page titles and sections
// headlineLarge   - ~32sp - Page titles
// headlineMedium  - ~28sp - Section headers
// headlineSmall   - ~24sp - Smaller section headers

// Title Styles - For cards, dialogs, and app bars
// titleLarge      - ~22sp - Prominent titles (e.g., cards)
// titleMedium     - ~16sp - Subtitles, smaller headings
// titleSmall      - ~14sp - Tab labels, small UI titles

// Body Styles - For most text content
// bodyLarge       - ~16sp - Main content text (e.g., paragraphs)
// bodyMedium      - ~14sp - Secondary text (e.g., list items)
// bodySmall       - ~12sp - Caption text, footnotes

// Label Styles - For buttons, tags, and labels
// labelLarge      - ~14sp - Button text, primary labels
// labelMedium     - ~12sp - Secondary buttons, chips
// labelSmall      - ~11sp - Helper text, timestamps, etc.
  static var textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(),
    displayMedium: GoogleFonts.inter(),
    displaySmall: GoogleFonts.inter(),
    titleLarge: GoogleFonts.inter(),
    titleMedium: GoogleFonts.inter(),
    titleSmall: GoogleFonts.inter(),
    bodyLarge: GoogleFonts.inter(),
    bodyMedium: GoogleFonts.inter(),
    bodySmall: GoogleFonts.inter(),
  );
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}