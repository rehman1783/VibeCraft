import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../domain/entities/wallpaper_entity.dart';
import '../cubit/wallpaper_cubit.dart';
import '../cubit/wallpaper_state.dart';
import '../widgets/apply_options_sheet.dart';
import '../widgets/detail_action_bar.dart';
import '../widgets/home_screen_simulator.dart';
import '../widgets/lock_screen_simulator.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/wallpaper_repository.dart';

class WallpaperDetailScreen extends StatefulWidget {
  final WallpaperEntity wallpaper;

  const WallpaperDetailScreen({super.key, required this.wallpaper});

  @override
  State<WallpaperDetailScreen> createState() => _WallpaperDetailScreenState();
}

class _WallpaperDetailScreenState extends State<WallpaperDetailScreen> {
  bool _isPreviewModeActive = false;
  late PageController _pageController;
  int _activePreviewPage = 0;
  bool _isDownloaded = false;
  String? _localSavedPath;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _checkDownloadedState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkDownloadedState() async {
    final cubit = context.read<WallpaperCubit>();
    final isAlreadyDownloaded = await cubit.checkIfDownloaded(widget.wallpaper.id);
    final localExists = !widget.wallpaper.highResUrl.startsWith('http') &&
        File(widget.wallpaper.highResUrl).existsSync();

    if (mounted) {
      setState(() {
        _isDownloaded = isAlreadyDownloaded || localExists;
        if (localExists) {
          _localSavedPath = widget.wallpaper.highResUrl;
        }
      });
    }
  }

  void _triggerApplySheet(BuildContext parentContext, String pathOrUrl) {
    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RepositoryProvider<WallpaperRepository>.value(
        value: sl<WallpaperRepository>(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: parentContext.read<WallpaperCubit>()),
            BlocProvider.value(value: parentContext.read<FavoritesCubit>()),
          ],
          child: ApplyOptionsSheet(imagePathOrUrl: pathOrUrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocalFile = !widget.wallpaper.highResUrl.startsWith('http') && File(widget.wallpaper.highResUrl).existsSync();

    return BlocListener<WallpaperCubit, WallpaperState>(
      listener: (context, state) {
        if (state.lastDownloadedId == widget.wallpaper.id && state.downloadedFilePath != null) {
          setState(() {
            _isDownloaded = true;
            _localSavedPath = state.downloadedFilePath;
          });
          context
              .read<FavoritesCubit>()
              .onWallpaperDownloaded(widget.wallpaper.id, state.downloadedFilePath!);
          AppSnackBar.showSuccess(
            context,
            'Wallpaper saved to app storage!',
          );
        } else if (state.lastFailedId == widget.wallpaper.id) {
          AppSnackBar.showError(
            context,
            state.errorMessage ?? 'Download failed.',
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background Wallpaper Image (Supports Progressive Caching: Thumbnail -> HighRes)
            Positioned.fill(
              child: isLocalFile
                  ? Image.file(File(widget.wallpaper.highResUrl), fit: BoxFit.cover)
                  : (widget.wallpaper.highResUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: widget.wallpaper.highResUrl,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                          placeholder: (context, url) => widget.wallpaper.thumbnailUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.wallpaper.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => _buildShimmerPlaceholder(isDark),
                                  errorWidget: (context, url, error) => _buildShimmerPlaceholder(isDark),
                                )
                              : _buildShimmerPlaceholder(isDark),
                          errorWidget: (context, url, error) => widget.wallpaper.thumbnailUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.wallpaper.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => _buildShimmerPlaceholder(isDark),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                                ),
                        )
                      : Image.file(File(widget.wallpaper.highResUrl), fit: BoxFit.cover)),
            ),

            // Protection Overlay Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.25, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // DUAL-PAGE PREVIEW OVERLAY (Lock Screen & Home Screen PageView)
            if (_isPreviewModeActive) ...[
              Positioned.fill(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _activePreviewPage = index);
                  },
                  children: [
                    // Page 1: Lock Screen Simulator
                    Padding(
                      padding: EdgeInsets.only(
                        top: mediaQuery.padding.top + 50,
                        bottom: 80,
                      ),
                      child: const LockScreenSimulator(),
                    ),
                    // Page 2: Home Screen Simulator
                    Padding(
                      padding: EdgeInsets.only(
                        top: mediaQuery.padding.top + 50,
                        bottom: 80,
                      ),
                      child: const HomeScreenSimulator(),
                    ),
                  ],
                ),
              ),

              // Preview Top Header Pill Bar
              Positioned(
                top: mediaQuery.padding.top + 10,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                        onPressed: () {
                          setState(() => _isPreviewModeActive = false);
                        },
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_rounded,
                                  size: 14,
                                  color: _activePreviewPage == 0 ? AppColors.primary : Colors.white60,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Lock Screen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _activePreviewPage == 0 ? FontWeight.bold : FontWeight.normal,
                                    color: _activePreviewPage == 0 ? Colors.white : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(width: 1, height: 12, color: Colors.white30),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                1,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.home_rounded,
                                  size: 14,
                                  color: _activePreviewPage == 1 ? AppColors.primary : Colors.white60,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Home Screen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _activePreviewPage == 1 ? FontWeight.bold : FontWeight.normal,
                                    color: _activePreviewPage == 1 ? Colors.white : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Preview Floating Action Overlay Button (Full-Width Row)
              Positioned(
                bottom: mediaQuery.padding.bottom + 20,
                left: 20,
                right: 20,
                child: BlocBuilder<WallpaperCubit, WallpaperState>(
                  builder: (context, state) {
                    final isDownloading = state.isDownloading(widget.wallpaper.id);

                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: isDownloading
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                elevation: 6,
                              ),
                              onPressed: null,
                              icon: const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              label: const Text(
                                'Saving Wallpaper...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : (_isDownloaded
                              ? ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    elevation: 6,
                                  ),
                                  onPressed: () {
                                    final targetPath =
                                        _localSavedPath ?? widget.wallpaper.highResUrl;
                                    _triggerApplySheet(context, targetPath);
                                  },
                                  icon: const Icon(Icons.wallpaper_rounded, color: Colors.white, size: 22),
                                  label: const Text(
                                    'Apply Wallpaper',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    elevation: 6,
                                  ),
                                  onPressed: () {
                                    AppSnackBar.showInfo(context, 'Downloading wallpaper...');
                                    context
                                        .read<WallpaperCubit>()
                                        .downloadWallpaper(widget.wallpaper);
                                  },
                                  icon: const Icon(Icons.download_rounded, color: Colors.white, size: 22),
                                  label: const Text(
                                    'Download Wallpaper',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                )),
                    );
                  },
                ),
              ),
            ] else ...[
              // Standard Top Navigation Bar with Favorite Button
              Positioned(
                top: mediaQuery.padding.top + 10,
                left: 16,
                right: 16,
                child: DetailActionBar(
                  wallpaper: widget.wallpaper,
                  onBackTap: () => Navigator.pop(context),
                ),
              ),

              // Bottom Action & Metadata Card
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surface.withValues(alpha: 0.92)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photographer info
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.wallpaper.photographer,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '@${widget.wallpaper.photographerUsername.isNotEmpty ? widget.wallpaper.photographerUsername : 'unsplash'} • Unsplash',
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (widget.wallpaper.likes > 0)
                            Chip(
                              avatar: const Icon(Icons.favorite_rounded, color: Colors.red, size: 14),
                              label: Text(
                                '${widget.wallpaper.likes}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.transparent,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),

                      if (widget.wallpaper.altDescription.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.wallpaper.altDescription,
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 18),

                      // TWO EQUAL PRIMARY ACTION BUTTONS (Preview + Download/Apply)
                      BlocBuilder<WallpaperCubit, WallpaperState>(
                        builder: (context, state) {
                          final isDownloading = state.isDownloading(widget.wallpaper.id);

                          return Row(
                            children: [
                              // 1. PREVIEW BUTTON
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPreviewModeActive = true;
                                      });
                                    },
                                    icon: const Icon(Icons.remove_red_eye_rounded, color: AppColors.primary, size: 20),
                                    label: const Text(
                                      'Preview',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // 2. DOWNLOAD / APPLY WALLPAPER BUTTON
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: isDownloading
                                      ? ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary.withValues(alpha: 0.6),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: null,
                                          icon: const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          label: const Text(
                                            'Saving...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : (_isDownloaded
                                          ? ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: () {
                                                final targetPath =
                                                    _localSavedPath ?? widget.wallpaper.highResUrl;
                                                _triggerApplySheet(context, targetPath);
                                              },
                                              icon: const Icon(Icons.wallpaper_rounded, color: Colors.white, size: 20),
                                              label: const Text(
                                                'Apply',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            )
                                          : ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<WallpaperCubit>()
                                                    .downloadWallpaper(widget.wallpaper);
                                              },
                                              icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                                              label: const Text(
                                                'Download',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            )),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF181824) : Colors.grey.shade900,
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}