import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Fallback if dotenv fails or file missing in production build
    }
  }

  // Unsplash Configurations
  static String get unsplashAccessKey {
    return dotenv.env['UNSPLASH_ACCESS_KEY'] ??
        '15DhciHYOK36la7klAHADVmIx8E_LLynKw_vs6OFL8w';
  }

  static String get unsplashBaseUrl {
    return dotenv.env['UNSPLASH_BASE_URL'] ?? 'https://api.unsplash.com';
  }

  static Map<String, String> get unsplashHeaders => {
        'Authorization': 'Client-ID $unsplashAccessKey',
        'Accept-Version': 'v1',
      };

  // Pixabay Configurations
  static String get pixabayApiKey {
    return dotenv.env['PIXABAY_API_Key'] ??
        dotenv.env['PIXABAY_API_KEY'] ??
        '56960138-8f6838837d6391021984504e9';
  }

  static String get pixabayBaseUrl {
    return dotenv.env['PIXABAY_BASE_URL'] ?? 'https://pixabay.com/api/';
  }

  // Google Gemini & Imagen Configurations
  static String get geminiApiKey {
    return dotenv.env['GEMINI_API_KEY'] ??
        'AQ.Ab8RN6InhZzuo4z4WQ9sjHrzMaHCcd99eiMhOpjWUPrxU76DyQ';
  }

  static String get geminiApiVersion {
    return dotenv.env['GEMINI_API_VERSION'] ?? 'v1beta';
  }

  static String get geminiModelVersion {
    return dotenv.env['GEMINI_MODEL_VERSION'] ?? 'gemini-3.6-flash';
  }

  static String get geminiImageModel {
    return dotenv.env['GEMINI_IMAGE_MODEL'] ?? 'imagen-3.0-generate-002';
  }

  static String get geminiBaseUrl {
    return dotenv.env['GEMINI_BASE_URL'] ??
        'https://generativelanguage.googleapis.com';
  }
}
