import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Fallback if dotenv fails or file missing in production build
    }
  }

  static String get unsplashAccessKey {
    return dotenv.env['UNSPLASH_ACCESS_KEY'] ??
        'Zz6yLdjip1oQw0TbyzcLiRx2ODOXBj_OyQNVDodvtZQ';
  }

  static String get unsplashBaseUrl {
    return dotenv.env['UNSPLASH_BASE_URL'] ?? 'https://api.unsplash.com';
  }

  static Map<String, String> get unsplashHeaders => {
        'Authorization': 'Client-ID $unsplashAccessKey',
        'Accept-Version': 'v1',
      };

  static String get pixabayApiKey {
    return dotenv.env['PIXABAY_API_Key'] ??
        dotenv.env['PIXABAY_API_KEY'] ??
        '56960138-8f6838837d6391021984504e9';
  }

  static String get pixabayBaseUrl {
    return dotenv.env['PIXABAY_BASE_URL'] ?? 'https://pixabay.com/api/';
  }
}
