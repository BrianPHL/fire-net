import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';
import 'theme_provider.dart';

/// Helper class to get theme-aware colors
class ThemeColors {
  ThemeColors._();

  /// Get color variant based on current theme
  static Color getColor(
    BuildContext context, {
    required Color darkVariant,
    required Color lightVariant,
  }) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    return isDarkMode ? darkVariant : lightVariant;
  }

  /// Gets a context-independent color based on theme mode
  static Color getColorValueOnly({
    required bool isDarkMode,
    required Color darkVariant,
    required Color lightVariant,
  }) {
    return isDarkMode ? darkVariant : lightVariant;
  }

  // ========== BASIC THEME COLORS ==========
  static Color getCardBackground(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkCardBackground,
      lightVariant: AppColors.lightCardBackground,
    );
  }

  static Color getCardBackgroundLight(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkCardBackgroundLight,
      lightVariant: AppColors.lightCardBackgroundLight,
    );
  }

  static Color getTextSecondary(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkTextSecondary,
      lightVariant: AppColors.lightTextSecondary,
    );
  }

  static Color getTextTertiary(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkTextTertiary,
      lightVariant: AppColors.lightTextTertiary,
    );
  }

  static Color getBorderColor(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkBorderColor,
      lightVariant: AppColors.lightBorderColor,
    );
  }

  static Color getDividerColor(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDividerColor,
      lightVariant: AppColors.lightDividerColor,
    );
  }

  // ========== STATUS BACKGROUNDS ==========
  static Color getDangerBackground(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDangerBackground,
      lightVariant: AppColors.lightDangerBackground,
    );
  }

  static Color getWarningBackground(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkWarningBackground,
      lightVariant: AppColors.lightWarningBackground,
    );
  }

  static Color getSafeBackground(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkSafeBackground,
      lightVariant: AppColors.lightSafeBackground,
    );
  }

  // ========== DIAGNOSTIC COLORS ==========
  static Color getDiagnosticGradientTop(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticGradientTop,
      lightVariant: AppColors.lightDiagnosticGradientTop,
    );
  }

  static Color getDiagnosticGradientBottom(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticGradientBottom,
      lightVariant: AppColors.lightDiagnosticGradientBottom,
    );
  }

  static Color getDiagnosticBorder(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticBorder,
      lightVariant: AppColors.lightDiagnosticBorder,
    );
  }

  static Color getDiagnosticCardBackground(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticCardBackground,
      lightVariant: AppColors.lightDiagnosticCardBackground,
    );
  }

  static Color getDiagnosticStatusBackground(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticStatusBackground,
      lightVariant: AppColors.lightDiagnosticStatusBackground,
    );
  }

  static Color getDiagnosticCardBorder(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticCardBorder,
      lightVariant: AppColors.lightDiagnosticCardBorder,
    );
  }

  static Color getDiagnosticCyanAccent(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticCyanAccent,
      lightVariant: AppColors.lightDiagnosticCyanAccent,
    );
  }

  static Color getDiagnosticCyanBright(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticCyanBright,
      lightVariant: AppColors.lightDiagnosticCyanBright,
    );
  }

  static Color getDiagnosticCyanLight(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticCyanLight,
      lightVariant: AppColors.lightDiagnosticCyanLight,
    );
  }

  static Color getDiagnosticCyanIcon(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDiagnosticCyanIcon,
      lightVariant: AppColors.lightDiagnosticCyanIcon,
    );
  }

  static Color getDiagnosticTealBright(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkPrimary,
      lightVariant: AppColors.lightDiagnosticTealBright,
    );
  }

  static Color getDiagnosticTealAccent(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkPrimaryDark,
      lightVariant: AppColors.lightDiagnosticTealAccent,
    );
  }

  // ========== ACTIVITY COLORS ==========
  static Color getActivityIndicator(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkActivityIndicator,
      lightVariant: AppColors.lightActivityIndicator,
    );
  }

  static Color getActivityDark(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkActivityDark,
      lightVariant: AppColors.lightActivityDark,
    );
  }

  // ========== TEXT COLORS ==========
  static Color getTextPrimary(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkTextPrimary,
      lightVariant: AppColors.lightTextPrimary,
    );
  }

  // ========== SEMANTIC STATUS COLORS ==========
  static Color getDanger(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkDanger,
      lightVariant: AppColors.lightDanger,
    );
  }

  static Color getWarning(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkWarning,
      lightVariant: AppColors.lightWarning,
    );
  }

  static Color getSafe(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkSafe,
      lightVariant: AppColors.lightSafe,
    );
  }

  static Color getPrimary(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkPrimary,
      lightVariant: AppColors.lightPrimary,
    );
  }

  // ========== SENSOR INDICATOR COLORS ==========
  static Color getTemperatureColor(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkTemperatureColor,
      lightVariant: AppColors.lightTemperatureColor,
    );
  }

  static Color getSmokeColor(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkSmokeColor,
      lightVariant: AppColors.lightSmokeColor,
    );
  }

  static Color getGasColor(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkGasColor,
      lightVariant: AppColors.lightGasColor,
    );
  }

  // ========== CHART COLORS ==========
  static Color getChartLine(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkChartLine,
      lightVariant: AppColors.lightChartLine,
    );
  }

  static Color getChartGrid(BuildContext context) {
    return getColor(
      context,
      darkVariant: AppColors.darkChartGrid,
      lightVariant: AppColors.lightChartGrid,
    );
  }
}
