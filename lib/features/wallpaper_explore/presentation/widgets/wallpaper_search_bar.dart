import 'package:flutter/material.dart';
import 'package:wall_zen/core/theme/app_colors.dart';

/// A modern search bar for wallpapers with real-time auto-complete suggestions.
class WallpaperSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final List<String> recentSearches;

  const WallpaperSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.recentSearches = const [],
  });

  static const List<String> popularKeywords = [
    'Nature',
    'Natural Scenery',
    'Minimalist',
    'AMOLED',
    'Neon Abstract',
    '3D Wallpapers',
    'Cyberpunk',
    'Architecture',
    'Anime',
    'Cars & Supercars',
    'Space & Galaxy',
    'Dark Aesthetic',
    'Ocean & Water',
    'Mountains',
    'Urban Skyline',
    'Vintage',
    'Flowers & Flora',
    'Animals',
    'Technology',
    'Sunset',
  ];

  @override
  State<WallpaperSearchBar> createState() => _WallpaperSearchBarState();
}

class _WallpaperSearchBarState extends State<WallpaperSearchBar> {
  late FocusNode _effectiveFocusNode;
  late TextEditingController _effectiveController;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveController = widget.controller ?? TextEditingController();

    _effectiveFocusNode.addListener(_onFocusChange);
    _effectiveController.addListener(_onTextChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _effectiveFocusNode.dispose();
    if (widget.controller == null) _effectiveController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _effectiveFocusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }

  void _onTextChange() {
    final text = _effectiveController.text.trim().toLowerCase();
    if (text.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _showSuggestions = false;
      });
    } else {
      final combined = <String>{
        ...widget.recentSearches,
        ...WallpaperSearchBar.popularKeywords,
      };

      final matches = combined
          .where((keyword) => keyword.toLowerCase().contains(text))
          .take(5)
          .toList();

      setState(() {
        _filteredSuggestions = matches;
        _showSuggestions = _effectiveFocusNode.hasFocus && matches.isNotEmpty;
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    _effectiveController.text = suggestion;
    _effectiveController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    setState(() {
      _showSuggestions = false;
    });
    _effectiveFocusNode.unfocus();
    widget.onSubmitted?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final hintColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
    final fillColor = isDark
        ? AppColors.surface.withValues(alpha: 0.6)
        : AppColors.lightSurface;
    final enabledBorderColor = isDark
        ? AppColors.primary.withValues(alpha: 0.15)
        : AppColors.lightBorder;
    final dropdownBg = isDark ? AppColors.surface : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _effectiveController,
            focusNode: _effectiveFocusNode,
            onSubmitted: (val) {
              setState(() => _showSuggestions = false);
              widget.onSubmitted?.call(val);
            },
            onChanged: (val) {
              widget.onChanged?.call(val);
            },
            style: TextStyle(color: textColor),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search wallpapers...',
              hintStyle: TextStyle(color: hintColor),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: hintColor,
              ),
              suffixIcon: _effectiveController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: hintColor,
                      ),
                      onPressed: () {
                        _effectiveController.clear();
                        setState(() {
                          _filteredSuggestions = [];
                          _showSuggestions = false;
                        });
                        widget.onClear?.call();
                      },
                    )
                  : null,
              filled: true,
              fillColor: fillColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: enabledBorderColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          // Real-time Auto-Complete Dropdown Card
          if (_showSuggestions && _filteredSuggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: dropdownBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _filteredSuggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  itemBuilder: (context, index) {
                    final item = _filteredSuggestions[index];
                    final isRecent = widget.recentSearches.contains(item);

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: Icon(
                        isRecent ? Icons.history_rounded : Icons.search_rounded,
                        size: 18,
                        color: isRecent ? AppColors.primary : hintColor,
                      ),
                      title: Text(
                        item,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.north_west_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                      onTap: () => _selectSuggestion(item),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
