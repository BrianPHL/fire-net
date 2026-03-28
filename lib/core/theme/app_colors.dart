import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ========== SEMANTIC COLORS - LIGHT THEME ==========
  // Primary accent colors (light mode = dark green)
  static const Color lightPrimary = Color(0xFF007766);
  static const Color lightPrimaryDark = Color(0xFF005555);

  // Status colors (light mode)
  static const Color lightDanger = Color(0xFFFF5757);
  static const Color lightWarning = Color(0xFFFFB800);
  static const Color lightSafe = Color(0xFF007766);

  // Sensor indicator colors (light mode)
  static const Color lightTemperatureColor = Color(0xFFFF5757);
  static const Color lightSmokeColor = Color(0xFFFF5757);
  static const Color lightGasColor = Color(0xFF007766);

  // Badge colors (light mode)
  static const Color lightActiveEmergency = Color(0xFFFF5757);
  static const Color lightResolvedStatus = Color(0xFF007766);

  // Chart line color (light mode)
  static const Color lightChartLine = Color(0xFF007766);

  // ========== SEMANTIC COLORS - DARK THEME ==========
  // Primary accent colors (dark mode = bright green)
  static const Color darkPrimary = Color(0xFF00D9A3);
  static const Color darkPrimaryDark = Color(0xFF00B887);

  // Status colors (dark mode)
  static const Color darkDanger = Color(0xFFFF5757);
  static const Color darkWarning = Color(0xFFFFB800);
  static const Color darkSafe = Color(0xFF00D9A3);

  // Sensor indicator colors (dark mode)
  static const Color darkTemperatureColor = Color(0xFFFF5757);
  static const Color darkSmokeColor = Color(0xFFFF5757);
  static const Color darkGasColor = Color(0xFF00D9A3);

  // Badge colors (dark mode)
  static const Color darkActiveEmergency = Color(0xFFFF5757);
  static const Color darkResolvedStatus = Color(0xFF00D9A3);

  // Chart line color (dark mode)
  static const Color darkChartLine = Color(0xFF00D9A3);

  // Activity status colors (dark mode)
  static const Color darkActivityIndicator = Color(0xFF00D9A3);
  static const Color darkActivityDark = Color(0xFF00B887);

  // ========== LEGACY ALIASES FOR BACKWARD COMPATIBILITY ==========
  static const Color primary = lightPrimary;
  static const Color primaryDark = lightPrimaryDark;
  static const Color danger = lightDanger;
  static const Color warning = lightWarning;
  static const Color safe = lightSafe;
  static const Color temperatureColor = lightTemperatureColor;
  static const Color smokeColor = lightSmokeColor;
  static const Color gasColor = lightGasColor;
  static const Color activeEmergency = lightActiveEmergency;
  static const Color resolvedStatus = lightResolvedStatus;
  static const Color chartLine = lightChartLine;

  // ========== DARK THEME COLORS ==========
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color darkCardBackground = Color(0xFF1A1F2E);
  static const Color darkCardBackgroundLight = Color(0xFF232938);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkBorderColor = Color(0xFF2D3648);
  static const Color darkDividerColor = Color(0xFF1F2937);
  static const Color darkChartGrid = Color(0xFF2D3648);
  static const Color darkDangerBackground = Color(0xFF2D1F1F);
  static const Color darkWarningBackground = Color(0xFF2D2A1F);
  static const Color darkSafeBackground = Color(0xFF0D4D3F);  // Darker but brighter green-tinted background for dark mode

  // ========== DARK THEME - DIAGNOSTIC COLORS ==========
  // System status card gradients and borders
  static const Color darkDiagnosticGradientTop = Color(0xFF032542);
  static const Color darkDiagnosticGradientBottom = Color(0xFF042A3B);
  static const Color darkDiagnosticBorder = Color(0xFF0A4A6A);
  
  // Diagnostic card backgrounds
  static const Color darkDiagnosticCardBackground = Color(0xFF111C39);
  static const Color darkDiagnosticStatusBackground = Color(0xFF233149);
  static const Color darkDiagnosticCardBorder = Color(0xFF1F3258);
  
  // Diagnostic accent colors (cyan/teal)
  static const Color darkDiagnosticCyanAccent = Color(0xFF00BFEA);
  static const Color darkDiagnosticCyanBright = Color(0xFF17D9FF);
  static const Color darkDiagnosticCyanLight = Color(0xFF19DFFF);
  static const Color darkDiagnosticCyanIcon = Color(0xFF22D9FF);
  static const Color darkDiagnosticTealBright = Color(0xFF00D9A3);  // Bright green for dark mode
  static const Color darkDiagnosticTealAccent = Color(0xFF00B887);  // Bright accent green for dark mode

  // ========== LIGHT THEME COLORS ==========
  static const Color lightBackground = Color(0xFFF3F4F6);  // Subtle gray background
  static const Color lightCardBackground = Color(0xFFFFFFFF);  // White cards
  static const Color lightCardBackgroundLight = Color(0xFFFAFAFA);  // Very light gray cards
  static const Color lightTextPrimary = Color(0xFF111827);  // Dark text for contrast
  static const Color lightTextSecondary = Color(0xFF4B5563);  // Medium gray
  static const Color lightTextTertiary = Color(0xFF6B7280);  // Light gray
  static const Color lightBorderColor = Color(0xFFD1D5DB);  // Subtle borders
  static const Color lightDividerColor = Color(0xFFE5E7EB);  // Light dividers
  static const Color lightChartGrid = Color(0xFFDDD9E6);  // Chart grid
  static const Color lightDangerBackground = Color(0xFFFFEBEE);  // Light red - more saturated
  static const Color lightWarningBackground = Color(0xFFFFF3E0);  // Light orange - more saturated
  static const Color lightSafeBackground = Color(0xFFD4E8DC);  // Darker green-tinted background for light mode

  // ========== LIGHT THEME - DIAGNOSTIC COLORS ==========
  // System status card gradients and borders
  static const Color lightDiagnosticGradientTop = Color(0xFFE8F4F8);
  static const Color lightDiagnosticGradientBottom = Color(0xFFDEEEF4);
  static const Color lightDiagnosticBorder = Color(0xFFA8D8E8);
  
  // Diagnostic card backgrounds
  static const Color lightDiagnosticCardBackground = Color(0xFFF5F9FC);
  static const Color lightDiagnosticStatusBackground = Color(0xFFEEF6FA);
  static const Color lightDiagnosticCardBorder = Color(0xFFC5DCEB);
  
  // Diagnostic accent colors (cyan/teal)
  static const Color lightDiagnosticCyanAccent = Color(0xFF00A8D8);
  static const Color lightDiagnosticCyanBright = Color(0xFF0088BB);
  static const Color lightDiagnosticCyanLight = Color(0xFF0099CC);
  static const Color lightDiagnosticCyanIcon = Color(0xFF0087BB);
  static const Color lightDiagnosticTealBright = Color(0xFF007766);  // Dark green for light mode
  static const Color lightDiagnosticTealAccent = Color(0xFF005555);  // Dark accent green for light mode
  
  // Activity status colors (light mode)
  static const Color lightActivityIndicator = Color(0xFF007766);
  static const Color lightActivityDark = Color(0xFF005555);

  // ========== THEME-AGNOSTIC GETTERS (Deprecated - kept for compatibility) ==========
  // These now map to dark theme by default
  static const Color background = darkBackground;
  static const Color cardBackground = darkCardBackground;
  static const Color cardBackgroundLight = darkCardBackgroundLight;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textTertiary = darkTextTertiary;
  static const Color dangerBackground = darkDangerBackground;
  static const Color warningBackground = darkWarningBackground;
  static const Color safeBackground = darkSafeBackground;
  static const Color borderColor = darkBorderColor;
  static const Color dividerColor = darkDividerColor;
  static const Color chartGrid = darkChartGrid;
}
