import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
  Future<bool> isSignedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedUserKey = 'CACHED_USER';
  static const String isSignedInKey = 'IS_SIGNED_IN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
        cachedUserKey, json.encode(user.toJson()));
    await sharedPreferences.setBool(isSignedInKey, true);
  }

  @override
  Future<UserModel> getCachedUser() async {
    final jsonString = sharedPreferences.getString(cachedUserKey);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    } else {
      throw CacheException('No cached user found');
    }
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(cachedUserKey);
    await sharedPreferences.setBool(isSignedInKey, false);
  }

  @override
  Future<bool> isSignedIn() async {
    return sharedPreferences.getBool(isSignedInKey) ?? false;
  }
}
