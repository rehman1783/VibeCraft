import 'package:flutter/material.dart';
import 'package:vibe_craft/core/theme/app_colors.dart';

/// A sleek pill-shaped search input bar for magic wallpapers with electric blue
/// filter button action and auto-complete keyword suggestions.
class WallpaperSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final FocusNode? focusNode;
  final List<String> recentSearches;

  const WallpaperSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.focusNode,
    this.recentSearches = const [],
  });

  static const List<String> popularKeywords = [
    'Nature',
    'Minimalist',
    'AMOLED',
    'Neon Abstract',
    '3D Wallpapers',
    'Cyberpunk',
    'Architecture',
    'Anime',
    'Space & Galaxy',
    'Dark Aesthetic',
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
      _showSuggestions =
          _effectiveFocusNode.hasFocus && _filteredSuggestions.isNotEmpty;
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

    final textColor = isDark
        ? AppColors.textPrimary
        : AppColors.lightTextPrimary;
    final hintColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final fillColor = isDark
        ? AppColors.surface.withValues(alpha: 0.8)
        : AppColors.lightSurface;
    final enabledBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.lightBorder;
    final dropdownBg = isDark ? AppColors.surface : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: TextField(
              controller: _effectiveController,
              focusNode: _effectiveFocusNode,
              onSubmitted: (val) {
                setState(() => _showSuggestions = false);
                widget.onSubmitted?.call(val);
              },
              onChanged: (val) {
                widget.onChanged?.call(val);
              },
              style: TextStyle(color: textColor, fontSize: 14),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search for magic wallpapers.',
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 10),
                  child: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.textSecondary : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_effectiveController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear_rounded, color: hintColor, size: 20),
                        onPressed: () {
                          _effectiveController.clear();
                          setState(() {
                            _filteredSuggestions = [];
                            _showSuggestions = false;
                          });
                          widget.onClear?.call();
                        },
                      ),
                    // Electric Blue Filter Button Graphic Icon
                    GestureDetector(
                      onTap: widget.onFilterTap,
                      child: Container(
                        margin: const EdgeInsets.only(right: 6, top: 5, bottom: 5),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.electricBlue,
                              AppColors.electricBlueSecondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.electricBlue.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                filled: true,
                fillColor: fillColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: enabledBorderColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.electricBlue,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Real-time Auto-Complete Dropdown Card
          if (_showSuggestions && _filteredSuggestions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: dropdownBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppColors.electricBlue.withValues(alpha: 0.25)
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
                borderRadius: BorderRadius.circular(20),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      leading: Icon(
                        isRecent ? Icons.history_rounded : Icons.search_rounded,
                        size: 18,
                        color: isRecent ? AppColors.electricBlue : hintColor,
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
