import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wall_zen/core/theme/app_theme.dart';
import 'package:wall_zen/core/theme/theme_cubit.dart';
import 'package:wall_zen/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wall_zen/features/ai_creator/presentation/cubit/ai_chat_cubit.dart';
import 'package:wall_zen/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:wall_zen/features/auth/domain/repositories/auth_repository.dart';
import 'package:wall_zen/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wall_zen/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:wall_zen/features/navigation/presentation/cubit/navigation_cubit.dart';
import 'package:wall_zen/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:wall_zen/features/wallpaper_explore/domain/repositories/wallpaper_repository.dart';
import 'package:wall_zen/features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';
import 'package:wall_zen/injection_container.dart';
import 'package:wall_zen/routes.dart';

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

  runApp(WallZenApp(authRepository: authRepository));
}

class WallZenApp extends StatelessWidget {
  final AuthRepository authRepository;

  const WallZenApp({super.key, required this.authRepository});

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
          BlocProvider<FavoritesCubit>(create: (_) => sl<FavoritesCubit>()..loadFavorites()),
          BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
          BlocProvider<AiChatCubit>(create: (_) => AiChatCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'WallZen',
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
