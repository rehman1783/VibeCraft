import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall_zen/core/theme/app_theme.dart';
import 'package:wall_zen/features/auth/domain/entities/user_entity.dart';
import 'package:wall_zen/features/auth/domain/repositories/auth_repository.dart';
import 'package:wall_zen/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wall_zen/features/search/data/datasources/search_local_data_source.dart';
import 'package:wall_zen/features/wallpaper_explore/data/models/unsplash_topic_model.dart';
import 'package:wall_zen/features/wallpaper_explore/domain/entities/wallpaper_entity.dart';
import 'package:wall_zen/features/wallpaper_explore/domain/repositories/wallpaper_repository.dart';
import 'package:wall_zen/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:wall_zen/routes.dart';

class MockAuthRepository implements AuthRepository {
  final UserEntity? user;
  MockAuthRepository({this.user});

  @override
  Future<UserEntity> signInWithEmail({required String email, required String password}) => throw UnimplementedError();

  @override
  Future<UserEntity> signUpWithEmail({required String name, required String email, required String password}) => throw UnimplementedError();

  @override
  Future<UserEntity?> getCurrentUser() async => user;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> resetPassword({required String newPassword, String? oobCode}) async {}
}

class MockWallpaperRepository implements WallpaperRepository {
  @override
  Future<List<WallpaperEntity>> getCuratedWallpapers({required int page, String? orderBy}) async => [];

  @override
  Future<List<WallpaperEntity>> searchWallpapers({required String query, required int page, String? orderBy, String? orientation, String? color}) async => [];

  @override
  Future<List<UnsplashTopicModel>> getTopics() async => [];

  @override
  Future<List<WallpaperEntity>> getTopicWallpapers({required String topicSlug, required int page, String? orientation}) async => [];

  @override
  Future<String> downloadWallpaper(WallpaperEntity wallpaper) async => '';

  @override
  Future<List<WallpaperEntity>> getDownloadedWallpapers() async => [];

  @override
  Future<bool> isWallpaperDownloaded(String wallpaperId) async => false;

  @override
  Future<bool> applyWallpaper({required String imagePathOrUrl, required WallpaperTarget target}) async => true;

  @override
  Future<void> clearAllDownloadedWallpapers() async {}
}

class MockSearchLocalDataSource implements SearchLocalDataSource {
  @override
  Future<List<String>> getRecentSearches() async => [];

  @override
  Future<void> saveSearchQuery(String query) async {}

  @override
  Future<void> removeSearchQuery(String query) async {}

  @override
  Future<void> clearRecentSearches() async {}
}

void main() {
  testWidgets('WallZen app renders splash screen on launch', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    final mockWallpaperRepo = MockWallpaperRepository();
    final mockSearchSource = MockSearchLocalDataSource();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: mockAuthRepo),
          ),
          BlocProvider<WallpaperCubit>(
            create: (_) => WallpaperCubit(
              repository: mockWallpaperRepo,
              searchLocalDataSource: mockSearchSource,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'WallZen',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );

    expect(find.text('WALLZEN'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
