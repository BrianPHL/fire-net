import 'package:flutter_dotenv/flutter_dotenv.dart';

// Central API configuration and endpoint paths.
class ApiConfig {
  ApiConfig._();

  // Base URL for backend requests. Empty string means local/mock mode.
  static String get baseUrl =>
      (dotenv.env['API_BASE_URL'] ?? '').trim();

  // Whether a real API base URL is configured.
  static bool get hasBaseUrl => baseUrl.isNotEmpty;

  // Auth endpoints
  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String logoutPath = '/auth/logout';

  // User endpoints
  static const String alertsPath = '/alerts';
  static const String sensorsPath = '/sensors';

  // Engineer endpoints
  static const String diagnosticsPath = '/engineer/diagnostics';
  static const String systemConfigPath = '/engineer/system-config';

  static String buildUrl(String path) {
    if (!hasBaseUrl) {
      return path;
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return '$normalizedBase$normalizedPath';
  }
}
