import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/features/auth/data/models/auth_model.dart';
import 'package:frontend/features/auth/domain/auth_state.dart';
import 'package:frontend/core/network/api_client.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  static const _boxName = 'auth';
  final Dio _dio;

  AuthNotifier(this._dio) : super(const AuthState()) {
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final box = await Hive.openBox(_boxName);
      final data = box.get('user');
      if (data != null) {
        state = state.copyWith(
          user: AuthUser.fromMap(Map<String, dynamic>.from(data)),
        );
      }
    } catch (e) {
      debugPrint('Session load error: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.post(
        '/api/v1/auth/login/',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final userJson = data['user'];
        final token = data['token'] as String;

        final user = AuthUser.fromJson(userJson, token);

        // Update Dio baseOptions with JWT token for future requests
        _dio.options.headers['Authorization'] = 'Bearer $token';

        state = state.copyWith(user: user, isLoading: false);

        // Persist session
        final box = await Hive.openBox(_boxName);
        await box.put('user', user.toMap());

        return true;
      }

      final errMsg = response.data['message'] ?? 'Invalid credentials.';
      state = state.copyWith(isLoading: false, error: errMsg);
      return false;
    } on DioException catch (e) {
      String errMsg = 'Login failed. Check your connection.';
      if (e.response != null) {
        final resData = e.response?.data;
        if (resData is Map && resData['message'] != null) {
          errMsg = resData['message'];
        } else if (e.response?.statusCode == 400) {
          errMsg = 'Invalid email or password.';
        }
      }
      state = state.copyWith(isLoading: false, error: errMsg);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    // Clear auth header
    _dio.options.headers.remove('Authorization');
    state = state.copyWith(clearUser: true);
    final box = await Hive.openBox(_boxName);
    await box.delete('user');
  }

  /// Call this on app start to restore JWT from saved session
  void restoreToken() {
    final token = state.user?.token;
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final dio = ref.watch(apiClientProvider);
    final notifier = AuthNotifier(dio);
    notifier.restoreToken();
    return notifier;
  },
);
