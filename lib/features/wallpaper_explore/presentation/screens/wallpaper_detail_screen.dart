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

  WallpaperTarget _selectedTarget = WallpaperTarget.both;
  bool _isApplying = false;

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
    final isAlreadyDownloaded = await cubit.checkIfDownloaded(
      widget.wallpaper.id,
    );
    final localExists =
        !widget.wallpaper.highResUrl.startsWith('http') &&
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

  Future<void> _handleSetWallpaper(BuildContext context) async {
    if (_isApplying) return;

    final cubit = context.read<WallpaperCubit>();
    WallpaperRepository repository;
    try {
      repository = context.read<WallpaperRepository>();
    } catch (_) {
      repository = sl<WallpaperRepository>();
    }

    setState(() {
      _isApplying = true;
    });

    try {
      String localPath = _localSavedPath ?? '';

      // If wallpaper has not been downloaded yet, download automatically first
      if (!_isDownloaded ||
          localPath.isEmpty ||
          !File(localPath).existsSync()) {
        if (context.mounted) {
          AppSnackBar.showInfo(context, 'Downloading wallpaper...');
        }
        await cubit.downloadWallpaper(widget.wallpaper);
        if (!mounted) return;

        final updatedPath = cubit.state.downloadedFilePath;
        if (updatedPath != null && File(updatedPath).existsSync()) {
          localPath = updatedPath;
          setState(() {
            _isDownloaded = true;
            _localSavedPath = updatedPath;
          });
        } else {
          localPath = widget.wallpaper.highResUrl;
        }
      }

      final success = await repository.applyWallpaper(
        imagePathOrUrl: localPath,
        target: _selectedTarget,
      );

      if (context.mounted) {
        if (success) {
          final targetName = _selectedTarget == WallpaperTarget.home
              ? 'Home Screen'
              : (_selectedTarget == WallpaperTarget.lock
                    ? 'Lock Screen'
                    : 'Home & Lock Screens');
          AppSnackBar.showSuccess(
            context,
            'Wallpaper successfully applied to $targetName!',
          );
        } else {
          AppSnackBar.showError(context, 'Failed to set wallpaper on device.');
        }
        setState(() {
          _isApplying = false;
        });
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          'Failed to set wallpaper: ${e.toString()}',
        );
        setState(() {
          _isApplying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocalFile =
        !widget.wallpaper.highResUrl.startsWith('http') &&
        File(widget.wallpaper.highResUrl).existsSync();

    final altDesc = widget.wallpaper.altDescription.isEmpty
        ? 'white draft'
        : widget.wallpaper.altDescription
              .replaceAll('walls', 'white draft')
              .replaceAll('Walls', 'white draft');

    return BlocListener<WallpaperCubit, WallpaperState>(
      listener: (context, state) {
        if (state.lastDownloadedId == widget.wallpaper.id &&
            state.downloadedFilePath != null) {
          setState(() {
            _isDownloaded = true;
            _localSavedPath = state.downloadedFilePath;
          });
          context.read<FavoritesCubit>().onWallpaperDownloaded(
            widget.wallpaper.id,
            state.downloadedFilePath!,
          );
          AppSnackBar.showSuccess(context, 'Wallpaper saved to app storage!');
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
            // Background Wallpaper Image
            Positioned.fill(
              child: isLocalFile
                  ? Image.file(
                      File(widget.wallpaper.highResUrl),
                      fit: BoxFit.cover,
                    )
                  : (widget.wallpaper.highResUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: widget.wallpaper.highResUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (context, url) =>
                                widget.wallpaper.thumbnailUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: widget.wallpaper.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        _buildShimmerPlaceholder(isDark),
                                    errorWidget: (context, url, error) =>
                                        _buildShimmerPlaceholder(isDark),
                                  )
                                : _buildShimmerPlaceholder(isDark),
                            errorWidget: (context, url, error) =>
                                widget.wallpaper.thumbnailUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: widget.wallpaper.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        _buildShimmerPlaceholder(isDark),
                                    errorWidget: (context, url, error) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.white54,
                                            size: 48,
                                          ),
                                        ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                      size: 48,
                                    ),
                                  ),
                          )
                        : Image.file(
                            File(widget.wallpaper.highResUrl),
                            fit: BoxFit.cover,
                          )),
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

            // PREVIEW OVERLAY MODE (Lock Screen & Home Screen PageView)
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
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _isPreviewModeActive = false);
                        },
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
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
                                  color: _activePreviewPage == 0
                                      ? AppColors.primary
                                      : Colors.white60,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Lock Screen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _activePreviewPage == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _activePreviewPage == 0
                                        ? Colors.white
                                        : Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 12,
                            color: Colors.white30,
                          ),
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
                                  color: _activePreviewPage == 1
                                      ? AppColors.primary
                                      : Colors.white60,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Home Screen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _activePreviewPage == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _activePreviewPage == 1
                                        ? Colors.white
                                        : Colors.white60,
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

              // Preview Floating Action Overlay Button
              Positioned(
                bottom: mediaQuery.padding.bottom + 20,
                left: 20,
                right: 20,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      elevation: 6,
                    ),
                    onPressed: _isApplying
                        ? null
                        : () {
                            _handleSetWallpaper(context);
                          },
                    icon: _isApplying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.wallpaper_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                    label: Text(
                      _isApplying ? 'Setting Wallpaper...' : 'Set Wallpaper',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Standard Top Navigation Bar with Favorite & Preview Buttons
              Positioned(
                top: mediaQuery.padding.top + 10,
                left: 16,
                right: 16,
                child: DetailActionBar(
                  wallpaper: widget.wallpaper,
                  onBackTap: () => Navigator.pop(context),
                  onPreviewTap: () =>
                      setState(() => _isPreviewModeActive = true),
                ),
              ),

              // Bottom Wallpaper Setup Card (Matching Reference UI)
              Positioned(
                bottom: mediaQuery.padding.bottom + 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141624).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Photographer & Metadata Info Row (Clean Default Profile Icon Fallback)
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.person_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.wallpaper.photographer.isNotEmpty
                                      ? widget.wallpaper.photographer
                                      : 'Jeremy Hynes',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  altDesc,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.wallpaper.likes > 0 ? widget.wallpaper.likes : '1.2k'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 2. Target Screen Selection Row (HOME / LOCK / BOTH)
                      Row(
                        children: [
                          _buildTargetOption(
                            target: WallpaperTarget.home,
                            icon: Icons.smartphone_rounded,
                            label: 'HOME',
                            isSelected: _selectedTarget == WallpaperTarget.home,
                          ),
                          const SizedBox(width: 10),
                          _buildTargetOption(
                            target: WallpaperTarget.lock,
                            icon: Icons.lock_rounded,
                            label: 'LOCK',
                            isSelected: _selectedTarget == WallpaperTarget.lock,
                          ),
                          const SizedBox(width: 10),
                          _buildTargetOption(
                            target: WallpaperTarget.both,
                            icon: Icons.layers_rounded,
                            label: 'BOTH',
                            isSelected: _selectedTarget == WallpaperTarget.both,
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 3. Action Buttons Row (Set Wallpaper + Save/Saved + Preview Option)
                      BlocBuilder<WallpaperCubit, WallpaperState>(
                        builder: (context, state) {
                          final isDownloading = state.isDownloading(
                            widget.wallpaper.id,
                          );

                          return Row(
                            children: [
                              // 3a. Set Wallpaper Primary Button
                              Expanded(
                                flex: 5,
                                child: SizedBox(
                                  height: 50,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF8B5CF6),
                                          Color(0xFF6366F1),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF6366F1,
                                          ).withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      onPressed: (_isApplying || isDownloading)
                                          ? null
                                          : () => _handleSetWallpaper(context),
                                      icon: _isApplying
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.auto_awesome_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                      label: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _isApplying
                                              ? 'Applying...'
                                              : 'Set Wallpaper',
                                          maxLines: 1,
                                          softWrap: false,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 3b. Save / Saved Secondary Button
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isDownloaded
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : const Color(0xFF202336),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: isDownloading
                                        ? null
                                        : () {
                                            if (_isDownloaded) {
                                              AppSnackBar.showInfo(
                                                context,
                                                'Wallpaper is already saved!',
                                              );
                                            } else {
                                              AppSnackBar.showInfo(
                                                context,
                                                'Downloading wallpaper...',
                                              );
                                              context
                                                  .read<WallpaperCubit>()
                                                  .downloadWallpaper(
                                                    widget.wallpaper,
                                                  );
                                            }
                                          },
                                    icon: isDownloading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            _isDownloaded
                                                ? Icons.check_circle_rounded
                                                : Icons.download_rounded,
                                            color: _isDownloaded
                                                ? const Color(0xFF00E676)
                                                : Colors.white,
                                            size: 18,
                                          ),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        _isDownloaded ? 'Saved' : 'Save',
                                        maxLines: 1,
                                        softWrap: false,
                                        style: TextStyle(
                                          color: _isDownloaded
                                              ? Colors.white
                                              : Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // 3c. Dedicated Preview Option Button
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                  ),
                                  child: IconButton(
                                    tooltip: 'Preview Wallpaper',
                                    icon: const Icon(
                                      Icons.remove_red_eye_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPreviewModeActive = true;
                                      });
                                    },
                                  ),
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

  Widget _buildTargetOption({
    required WallpaperTarget target,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTarget = target;
          });
        },
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF222438)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white60,
                size: 22,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
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
