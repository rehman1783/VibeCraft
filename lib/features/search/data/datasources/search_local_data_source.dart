import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchLocalDataSource {
  Future<List<String>> getRecentSearches();
  Future<void> saveSearchQuery(String query);
  Future<void> removeSearchQuery(String query);
  Future<void> clearRecentSearches();
}

class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _recentSearchesKey = 'VibeCraft_RECENT_SEARCHES';

  SearchLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getRecentSearches() async {
    return sharedPreferences.getStringList(_recentSearchesKey) ?? [];
  }

  @override
  Future<void> saveSearchQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final current = await getRecentSearches();
    final updated = List<String>.from(current)
      ..removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    updated.insert(0, trimmed);

    if (updated.length > 10) {
      updated.removeRange(10, updated.length);
    }

    await sharedPreferences.setStringList(_recentSearchesKey, updated);
  }

  @override
  Future<void> removeSearchQuery(String query) async {
    final current = await getRecentSearches();
    final updated = List<String>.from(current)
      ..removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    await sharedPreferences.setStringList(_recentSearchesKey, updated);
  }

  @override
  Future<void> clearRecentSearches() async {
    await sharedPreferences.remove(_recentSearchesKey);
  }
}
