import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/network/network_info.dart';
import 'core/services/content_report_service.dart';
import 'core/services/wallpaper_service.dart';
import 'features/ai_creator/data/datasources/gemini_chat_remote_source.dart';
import 'features/ai_creator/data/datasources/gemini_image_remote_source.dart';
import 'features/ai_creator/data/repositories/ai_repository_impl.dart';
import 'features/ai_creator/domain/repositories/ai_repository.dart';
import 'features/ai_creator/presentation/cubit/ai_chat_cubit.dart';
import 'features/favorites/data/datasources/favorites_local_data_source.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/search/data/datasources/search_local_data_source.dart';
import 'features/wallpaper_explore/data/datasources/pixabay_remote_source.dart';
import 'features/wallpaper_explore/data/datasources/unsplash_remote_source.dart';
import 'features/wallpaper_explore/data/datasources/wallpaper_local_data_source.dart';
import 'features/wallpaper_explore/data/repositories/wallpaper_repository_impl.dart';
import 'features/wallpaper_explore/domain/repositories/wallpaper_repository.dart';
import 'features/wallpaper_explore/presentation/cubit/wallpaper_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // 1. External & Core
  await AppConfig.init();
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );
  sl.registerLazySingleton<Dio>(() => dio);

  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );

  sl.registerLazySingleton<WallpaperService>(
    () => WallpaperService(),
  );

  sl.registerLazySingleton<ContentReportService>(
    () => ContentReportServiceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // 2. Data Sources
  sl.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<UnsplashRemoteDataSource>(
    () => UnsplashRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<PixabayRemoteDataSource>(
    () => PixabayRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<WallpaperLocalDataSource>(
    () => WallpaperLocalDataSourceImpl(
      sharedPreferences: sl<SharedPreferences>(),
      dio: sl<Dio>(),
    ),
  );

  sl.registerLazySingleton<GeminiChatRemoteDataSource>(
    () => GeminiChatRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<GeminiImageRemoteDataSource>(
    () => GeminiImageRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // 3. Repositories
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl<FavoritesLocalDataSource>()),
  );

  sl.registerLazySingleton<WallpaperRepository>(
    () => WallpaperRepositoryImpl(
      unsplashRemoteDataSource: sl<UnsplashRemoteDataSource>(),
      pixabayRemoteDataSource: sl<PixabayRemoteDataSource>(),
      localDataSource: sl<WallpaperLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      wallpaperService: sl<WallpaperService>(),
    ),
  );

  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(
      chatRemoteDataSource: sl<GeminiChatRemoteDataSource>(),
      imageRemoteDataSource: sl<GeminiImageRemoteDataSource>(),
    ),
  );

  // 4. Cubit / Blocs
  sl.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(repository: sl<FavoritesRepository>()),
  );

  sl.registerFactory<WallpaperCubit>(
    () => WallpaperCubit(
      repository: sl<WallpaperRepository>(),
      searchLocalDataSource: sl<SearchLocalDataSource>(),
    ),
  );

  sl.registerFactory<AiChatCubit>(
    () => AiChatCubit(aiRepository: sl<AiRepository>()),
  );
}
