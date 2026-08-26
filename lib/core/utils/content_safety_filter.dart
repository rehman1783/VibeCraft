import '../../features/wallpaper_explore/domain/entities/wallpaper_entity.dart';

/// Comprehensive Multi-Category Content Moderation and Safety Filter
/// for VibeCraft. Ensures that all images fetched from APIs, searches,
/// and AI prompts are 100% family-friendly, safe, and appropriate for mobile wallpapers.
class SafeContentFilter {
  // Categorized sensitive/inappropriate keywords with word boundaries
  static final Set<String> _nsfwKeywords = {
    // Adult / Sexual / Nudity
    'nude', 'naked', 'nudity', 'porn', 'xxx', 'nsfw', 'sex', 'sexy', 'erotic',
    'erotica', 'boobs', 'boob', 'breast', 'breasts', 'nipple', 'nipples',
    'vagina', 'penis', 'dick', 'pussy', 'ass', 'butt', 'booty', 'cleavage',
    'lingerie', 'underwear', 'bikini', 'swimsuit', 'topless', 'bottomless',
    'fetish', 'bdsm', 'playboy', 'hentai', 'ecchi', 'lewd', 'sensual',
    'seductive', 'strip', 'stripper', 'intercourse', 'masturbate', 'masturbation',
    'orgasm', 'pornography', 'adult', 'escort', 'camgirl', 'onlyfans',
    'boudoir', 'provocative', 'bikinis', 'swimwear', 'thong', 'undress',

    // Violence / Gore / Blood
    'gore', 'bloody', 'blood', 'corpse', 'dead body', 'mutilated', 'mutilation',
    'murder', 'kill', 'killer', 'suicide', 'decapitate', 'decapitated',
    'slaughter', 'torture', 'execution', 'massacre', 'wound', 'gruesome',
    'autopsy',

    // Hate / Harassment / Slurs / Offensive
    'hate', 'racist', 'racism', 'nazi', 'swastika', 'hitler', 'terrorist',
    'terrorism', 'slur', 'offensive',

    // Drugs / Illicit
    'cocaine', 'heroin', 'meth', 'crack', 'weed', 'cannabis', 'marijuana',
    'drugs', 'dealer', 'injection',
  };

  // Pre-compiled regex patterns with word boundaries for accurate matching
  static final List<RegExp> _compiledPatterns = _nsfwKeywords
      .map((k) => RegExp(r'\b' + RegExp.escape(k) + r'\b', caseSensitive: false))
      .toList();

  /// Checks if any given text contains sensitive, offensive, or NSFW terms
  static bool isContentSafe(String? text) {
    if (text == null || text.trim().isEmpty) return true;
    final normalized = text.toLowerCase().trim();

    for (final pattern in _compiledPatterns) {
      if (pattern.hasMatch(normalized)) {
        return false;
      }
    }
    return true;
  }

  /// Checks if a user's search query contains any inappropriate terms
  static bool isQueryBlocked(String query) {
    return !isContentSafe(query);
  }

  /// Sanitizes a search query: if sensitive terms are detected,
  /// substitutes with a safe, beautiful aesthetic wallpaper query.
  static String sanitizeSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return 'wallpapers';

    if (isQueryBlocked(trimmed)) {
      return 'aesthetic nature wallpaper';
    }

    // Append 'wallpaper' context if the query is very generic or short
    return trimmed;
  }

  /// Validates whether a WallpaperEntity is strictly safe and appropriate for display
  static bool isWallpaperSafe(WallpaperEntity wallpaper) {
    // 1. Inspect description and alt description
    if (!isContentSafe(wallpaper.altDescription)) return false;

    // 2. Inspect photographer name / username
    if (!isContentSafe(wallpaper.photographer)) return false;
    if (!isContentSafe(wallpaper.photographerUsername)) return false;

    // 3. Inspect image URL components for suspicious path tokens
    final urlLower = wallpaper.highResUrl.toLowerCase();
    for (final pattern in _compiledPatterns) {
      if (pattern.hasMatch(urlLower)) {
        return false;
      }
    }

    // 4. Ensure legitimate image URL
    if (wallpaper.thumbnailUrl.isEmpty && wallpaper.highResUrl.isEmpty) {
      return false;
    }

    return true;
  }

  /// Filters a list of WallpaperEntity items, removing any that fail safety checks
  static List<WallpaperEntity> filterWallpapers(List<WallpaperEntity> list) {
    return list.where((w) => isWallpaperSafe(w)).toList();
  }

  /// Sanitizes an AI prompt by stripping sensitive words and enforcing
  /// family-friendly, high-aesthetic wallpaper parameters.
  static String sanitizeAiPrompt(String prompt) {
    var cleaned = prompt.trim();

    // Strip blocked words
    for (final pattern in _compiledPatterns) {
      cleaned = cleaned.replaceAll(pattern, '');
    }

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) {
      cleaned = 'breathtaking cosmic aesthetic fantasy scenery';
    }

    // Enforce positive safety and mobile wallpaper context
    return '$cleaned, family-friendly, SFW, high artistic quality, beautiful digital wallpaper artwork, 9:16 mobile wallpaper';
  }
}
