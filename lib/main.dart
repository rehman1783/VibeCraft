import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibe_craft/core/theme/app_theme.dart';
import 'package:vibe_craft/core/theme/theme_cubit.dart';
import 'package:vibe_craft/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:vibe_craft/features/ai_creator/presentation/cubit/ai_chat_cubit.dart';
import 'package:vibe_craft/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vibe_craft/features/auth/domain/repositories/auth_repository.dart';
import 'package:vibe_craft/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vibe_craft/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:vibe_craft/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:vibe_craft/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vibe_craft/features/wallpaper_explore/domain/repositories/wallpaper_repository.dart';
import 'package:vibe_craft/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:vibe_craft/injection_container.dart';
import 'package:vibe_craft/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  await Firebase.initializeApp();

  // Initialize Unsplash API & clean architecture dependencies
  await initDependencyInjection();

  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );

  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  runApp(VibeCraftApp(authRepository: authRepository));
}

class VibeCraftApp extends StatelessWidget {
  final AuthRepository authRepository;

  const VibeCraftApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<WallpaperRepository>(
      create: (_) => sl<WallpaperRepository>(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(authRepository: authRepository),
          ),
          BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
          BlocProvider<WallpaperCubit>(create: (_) => sl<WallpaperCubit>()),
          BlocProvider<FavoritesCubit>(
            create: (_) => sl<FavoritesCubit>()..loadFavorites(),
          ),
          BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
          BlocProvider<AiChatCubit>(create: (_) => sl<AiChatCubit>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'VibeCraft',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}
