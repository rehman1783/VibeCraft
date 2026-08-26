import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/content_safety_filter.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class GeminiChatRemoteDataSource {
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> history,
    required String userMessage,
  });

  Future<String> optimizePrompt({
    required String prompt,
    String? style,
  });
}

class GeminiChatRemoteDataSourceImpl implements GeminiChatRemoteDataSource {
  final Dio dio;

  static const String _systemInstruction =
      "You are VibeCraft AI, a creative, visionary, and intuitive AI Wallpaper Architect. "
      "Chat with the user naturally like an expert digital artist and wallpaper designer. "
      "Listen carefully to their ideas, recommend inspiring aesthetic directions (e.g. Cyberpunk Neon, "
      "AMOLED Dark Fantasy, Anime Studio, Minimalist 3D, Bioluminescent Nature, Retro Synthwave), "
      "discuss lighting, mood, color palettes, and composition. "
      "Maintain full context memory of all previous messages. "
      "Strict Content Policy: You MUST only create 100% clean, family-friendly, SFW, aesthetic mobile wallpapers. "
      "Do NOT assist with any sexual, NSFW, nudity, violence, gore, or offensive concepts. "
      "Always pivot any inappropriate requests into majestic, wholesome, and artistic wallpaper themes.";

  GeminiChatRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? Dio();

  @override
  Future<String> optimizePrompt({
    required String prompt,
    String? style,
  }) async {
    final apiKey = AppConfig.geminiApiKey;
    final apiVersion = AppConfig.geminiApiVersion;
    final modelVersion = AppConfig.geminiModelVersion;
    final baseUrl = AppConfig.geminiBaseUrl;

    final sanitizedPrompt = SafeContentFilter.sanitizeAiPrompt(prompt);

    final styleDirective = (style != null && style.trim().isNotEmpty)
        ? 'Incorporate the visual style: "$style". '
        : '';

    final optimizationInstruction =
        "You are an expert AI Wallpaper Prompt Engineer and Master Digital Artist. "
        "Your mission is to take the user's raw prompt/command (which might be in English, Urdu, Roman Urdu, Hindi, or a brief idea) "
        "and transform it into a single, cohesive, breathtaking, hyper-detailed English prompt designed specifically for a 9:16 vertical smartphone wallpaper.\n"
        "$styleDirective"
        "Rules:\n"
        "1. Understand the core subject and intent precisely (translate any non-English concepts into vivid visual English).\n"
        "2. Add composition details optimized for mobile screens (centered subject, balanced framing, clear top/bottom negative space).\n"
        "3. Specify cinematic lighting, volumetric atmospheric mood, reflections, and rich color palette.\n"
        "4. Include high-quality aesthetic tags (e.g., 8k resolution, vertical mobile wallpaper, octane render, masterpiece, intricate detail, clean SFW art).\n"
        "5. Strict Safety Policy: Absolutely NO sexual, nudity, NSFW, gore, or offensive imagery. Enforce 100% family-friendly mobile wallpaper aesthetics.\n"
        "6. Output ONLY the finalized prompt text. No explanations, no quotes, no markdown headers, no conversational filler.";

    try {
      final url =
          '$baseUrl/$apiVersion/models/$modelVersion:generateContent?key=$apiKey';

      final response = await dio.post(
        url,
        data: {
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text":
                      "$optimizationInstruction\n\nUser's raw command: \"$sanitizedPrompt\""
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 200,
          }
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['candidates'] != null &&
            (data['candidates'] as List).isNotEmpty) {
          final firstCandidate = data['candidates'][0];
          final parts = firstCandidate['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text
                  .trim()
                  .replaceAll('"', '')
                  .replaceAll('**', '')
                  .replaceAll('\n', ' ');
            }
          }
        }
      }
    } catch (_) {
      // Fallback handled below
    }

    return _buildLocalMasterPrompt(sanitizedPrompt, style: style);
  }

  String _buildLocalMasterPrompt(String rawPrompt, {String? style}) {
    var cleaned = rawPrompt.trim();

    // Map common Roman Urdu / shorthand descriptors to high-definition visuals
    final replacements = {
      r'\b(sher|bagh)\b': 'majestic royal roaring lion with glowing aura',
      r'\b(gari|gaari|car)\b': 'sleek high-performance hypercar',
      r'\b(larki|aurat)\b': 'ethereal anime warrior character',
      r'\b(pahad|pahar)\b': 'dramatic epic mountain peaks covered in mist',
      r'\b(samandar|pani)\b': 'bioluminescent glowing ocean waves',
      r'\b(chand)\b': 'luminous crescent glowing moon',
      r'\b(asman|badal)\b': 'twilight atmospheric sky with dramatic nebula clouds',
      r'\b(aag)\b': 'blazing dynamic fire embers and flame vortex',
      r'\b(bijli)\b': 'electrifying lightning storm with vibrant plasma arc',
      r'\b(shahar|shehar)\b': 'futuristic neon cyberpunk metropolis at night',
      r'\b(chahiye|banao|karo|wali|wala)\b': '',
    };

    replacements.forEach((pattern, replacement) {
      cleaned = cleaned.replaceAll(RegExp(pattern, caseSensitive: false), replacement);
    });

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) cleaned = rawPrompt;

    String styleModifier = '';
    if (style != null && style.isNotEmpty) {
      switch (style.toLowerCase()) {
        case 'cyberpunk neon':
          styleModifier =
              'cyberpunk aesthetic, glowing neon lights, rain-slicked asphalt reflections, cyan and magenta lighting,';
          break;
        case 'anime studio':
          styleModifier =
              'Makoto Shinkai anime style, vibrant crystal-clear sky, ethereal light particles, cel-shaded masterpiece,';
          break;
        case 'dark oled fantasy':
          styleModifier =
              'pure AMOLED #000000 true black background, vivid glowing fantasy subject, high HDR contrast,';
          break;
        case 'minimalist 3d':
          styleModifier =
              'minimalist 3D clay octane render, smooth pastel gradient lighting, clean aesthetic geometry,';
          break;
        case 'neon tokyo':
          styleModifier =
              'Tokyo night rain aesthetic, glowing kanji signs, wet reflections, cinematic photography,';
          break;
        case 'synthwave sunset':
          styleModifier =
              '80s retro synthwave horizon, glowing wireframe grid, purple-orange sunset, chrome reflections,';
          break;
        case 'bioluminescent nature':
          styleModifier =
              'bioluminescent glowing flora and fauna, mystical enchanted night forest, floating glowing spores,';
          break;
        case 'cosmic nebula':
          styleModifier =
              'deep cosmic galaxy nebula, swirling stellar dust, vivid starlight, celestial majesty,';
          break;
        default:
          styleModifier = '$style aesthetic,';
      }
    }

    return '$cleaned, $styleModifier 8k resolution, vertical 9:16 mobile wallpaper, masterpiece, intricate details, cinematic dramatic volumetric lighting, photorealistic rendering, family-friendly, clean SFW art';
  }

  @override
  Future<String> sendChatMessage({
    required List<ChatMessageEntity> history,
    required String userMessage,
  }) async {
    final apiKey = AppConfig.geminiApiKey;
    final apiVersion = AppConfig.geminiApiVersion;
    final modelVersion = AppConfig.geminiModelVersion;
    final baseUrl = AppConfig.geminiBaseUrl;

    try {
      final contents = <Map<String, dynamic>>[];

      // Initial system persona priming
      contents.add({
        "role": "user",
        "parts": [
          {"text": _systemInstruction}
        ]
      });
      contents.add({
        "role": "model",
        "parts": [
          {
            "text":
                "Greetings! I am VibeCraft AI, your Wallpaper Architect. I am ready to collaborate with you on designing breathtaking vertical mobile wallpapers."
          }
        ]
      });

      // Append multi-turn history
      for (final msg in history) {
        contents.add({
          "role": msg.isUser ? "user" : "model",
          "parts": [
            {"text": msg.text}
          ]
        });
      }

      // Append latest user message
      contents.add({
        "role": "user",
        "parts": [
          {"text": userMessage}
        ]
      });

      final url =
          '$baseUrl/$apiVersion/models/$modelVersion:generateContent?key=$apiKey';

      final response = await dio.post(
        url,
        data: {"contents": contents},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['candidates'] != null &&
            (data['candidates'] as List).isNotEmpty) {
          final firstCandidate = data['candidates'][0];
          final parts = firstCandidate['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      }
    } catch (_) {
      // Fallback handled below
    }

    return "That's a fantastic idea! What color palette or lighting vibe do you envision for this wallpaper? (e.g. Neon Cyberpunk, Dark AMOLED Glow, or Soft Sunset Pastels)";
  }
}

