import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibe_craft/core/utils/app_snackbar.dart';
import 'package:vibe_craft/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:vibe_craft/features/ai_creator/presentation/screens/ai_studio_screen.dart';
import 'package:vibe_craft/features/downloads/presentation/screens/downloads_screen.dart';
import 'package:vibe_craft/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:vibe_craft/features/profile/presentation/screens/profile_screen.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/screens/explore_screen.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/screens/home_feed_screen.dart';

/// Root screen that contains an [IndexedStack] of tab screens and a
/// [CustomBottomNavigationBar].
///
/// Uses [NavigationCubit] to manage the selected tab index and preserve
/// screen state across tab switches.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime? _lastPressedAt;

  static final List<Widget> _screens = [
    const HomeFeedScreen(),
    const ExploreScreen(), // Dedicated Explore Tab
    const AICreatorScreen(), // AI Studio center button tab
    const DownloadsScreen(), // My Art tab
    const ProfileScreen(), // Profile tab
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;

            if (selectedIndex != 0) {
              // Case B: Non-Home tab -> switch back to Home Tab (index 0)
              context.read<NavigationCubit>().selectTab(0);
              _lastPressedAt = null;
            } else {
              // Case C: Home tab -> double back to exit application
              final now = DateTime.now();
              if (_lastPressedAt == null ||
                  now.difference(_lastPressedAt!) >
                      const Duration(seconds: 2)) {
                _lastPressedAt = now;
                AppSnackBar.showInfo(context, 'Press back again to exit');
              } else {
                await SystemNavigator.pop();
              }
            }
          },
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(index: selectedIndex, children: _screens),
            bottomNavigationBar: CustomBottomNavigationBar(
              currentIndex: selectedIndex,
              onTabSelected: (index) {
                context.read<NavigationCubit>().selectTab(index);
              },
            ),
          ),
        );
      },
    );
  }
}
