import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Modern Color Palette
class AppColors {
  // Primary Colors - Orange Theme
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color primaryOrangeLight = Color(0xFFFF8A65);
  static const Color primaryOrangeDark = Color(0xFFE65100);
  
  // Secondary Colors - Purple Theme
  static const Color secondaryPurple = Color(0xFF6A1B9A);
  static const Color secondaryPurpleLight = Color(0xFF9C27B0);
  static const Color secondaryPurpleDark = Color(0xFF4A148C);
  
  // Accent Colors
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentAmber = Color(0xFFFFC107);
  
  // Neutral Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primaryOrange,
  onPrimary: AppColors.textLight,
  secondary: AppColors.secondaryPurple,
  onSecondary: AppColors.textLight,
  tertiary: AppColors.accentGreen,
  onTertiary: AppColors.textLight,
  error: AppColors.error,
  onError: AppColors.textLight,
  background: AppColors.backgroundLight,
  onBackground: AppColors.textPrimary,
  surface: AppColors.surfaceLight,
  onSurface: AppColors.textPrimary,
  surfaceVariant: Color(0xFFF5F5F5),
  onSurfaceVariant: AppColors.textSecondary,
  outline: Color(0xFFE0E0E0),
  outlineVariant: Color(0xFFF0F0F0),
  shadow: Color(0x1A000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primaryOrangeLight,
  onPrimary: AppColors.textPrimary,
  secondary: AppColors.secondaryPurpleLight,
  onSecondary: AppColors.textLight,
  tertiary: AppColors.accentGreen,
  onTertiary: AppColors.textPrimary,
  error: AppColors.error,
  onError: AppColors.textLight,
  background: AppColors.backgroundDark,
  onBackground: AppColors.textLight,
  surface: AppColors.surfaceDark,
  onSurface: AppColors.textLight,
  surfaceVariant: Color(0xFF2C2C2C),
  onSurfaceVariant: Color(0xFFB0B0B0),
  outline: Color(0xFF404040),
  outlineVariant: Color(0xFF2C2C2C),
  shadow: Color(0x33000000),
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  fontFamily: 'Roboto',
  
  // AppBar Theme
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  ),
  
  // Card Theme
  cardTheme: CardTheme(
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: AppColors.cardLight,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryOrange,
      foregroundColor: AppColors.textLight,
      elevation: 6,
      shadowColor: AppColors.primaryOrange.withOpacity(0.3),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  
  // Text Button Theme
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryOrange,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  
  // Outlined Button Theme
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryOrange,
      side: BorderSide(color: AppColors.primaryOrange, width: 1.5),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.error),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: TextStyle(color: AppColors.textHint),
    labelStyle: TextStyle(color: AppColors.textSecondary),
  ),
  
  // Floating Action Button Theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryOrange,
    foregroundColor: AppColors.textLight,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primaryOrange,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),
  
  // Drawer Theme
  drawerTheme: DrawerThemeData(
    backgroundColor: AppColors.surfaceLight,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
  ),
  
  // List Tile Theme
  listTileTheme: ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    tileColor: Colors.transparent,
    selectedTileColor: AppColors.primaryOrange.withOpacity(0.1),
    iconColor: AppColors.textSecondary,
    textColor: AppColors.textPrimary,
  ),
  
  // Divider Theme
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade300,
    thickness: 1,
    space: 1,
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  fontFamily: 'Roboto',
  
  // AppBar Theme
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textLight,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textLight,
    ),
    iconTheme: IconThemeData(color: AppColors.textLight),
  ),
  
  // Card Theme
  cardTheme: CardTheme(
    elevation: 8,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: AppColors.cardDark,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  
  // Elevated Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryOrangeLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 8,
      shadowColor: AppColors.primaryOrangeLight.withOpacity(0.4),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  
  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade600),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: AppColors.primaryOrangeLight, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: TextStyle(color: Colors.grey.shade400),
    labelStyle: TextStyle(color: Colors.grey.shade300),
  ),
  
  // Floating Action Button Theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryOrangeLight,
    foregroundColor: AppColors.textPrimary,
    elevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  
  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primaryOrangeLight,
    unselectedItemColor: Colors.grey.shade400,
    type: BottomNavigationBarType.fixed,
    elevation: 16,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),
  
  // Drawer Theme
  drawerTheme: DrawerThemeData(
    backgroundColor: AppColors.surfaceDark,
    elevation: 24,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
    ),
  ),
  
  // List Tile Theme
  listTileTheme: ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    tileColor: Colors.transparent,
    selectedTileColor: AppColors.primaryOrangeLight.withOpacity(0.2),
    iconColor: Colors.grey.shade400,
    textColor: AppColors.textLight,
  ),
  
  // Divider Theme
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade700,
    thickness: 1,
    space: 1,
  ),
);
