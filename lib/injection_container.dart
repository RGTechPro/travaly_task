import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

// Features - Hotels
import 'features/hotels/data/datasources/hotel_remote_data_source.dart';
import 'features/hotels/data/repositories/hotel_repository_impl.dart';
import 'features/hotels/domain/repositories/hotel_repository.dart';
import 'features/hotels/domain/usecases/get_popular_hotels.dart';
import 'features/hotels/domain/usecases/search_hotels.dart';
import 'features/hotels/presentation/cubit/hotel_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ===== Features =====

  // Cubits
  sl.registerFactory(
    () => AuthCubit(
      signInWithGoogle: sl(),
      signOut: sl(),
      checkAuthStatus: sl(),
      getCurrentUser: sl(),
    ),
  );

  sl.registerFactory(
    () => HotelCubit(
      getPopularHotels: sl(),
      searchHotels: sl(),
    ),
  );

  // Use Cases - Auth
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Use Cases - Hotels
  sl.registerLazySingleton(() => GetPopularHotels(sl()));
  sl.registerLazySingleton(() => SearchHotels(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<HotelRepository>(
    () => HotelRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data Sources - Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(googleSignIn: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Data Sources - Hotels
  sl.registerLazySingleton<HotelRemoteDataSource>(
    () => HotelRemoteDataSourceImpl(client: sl()),
  );

  // ===== External =====
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => GoogleSignIn(scopes: ['email', 'profile']));
}
