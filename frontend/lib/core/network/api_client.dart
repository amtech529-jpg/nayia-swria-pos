import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final apiClientProvider = Provider<Dio>((ref) {
  String baseUrl = 'http://127.0.0.1:8000';
  try {
    if (dotenv.isInitialized) {
      baseUrl = dotenv.get('API_URL', fallback: 'http://127.0.0.1:8000');
    }
  } catch (_) {}

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add interceptors here (logging, auth, etc.)
  dio.interceptors.add(LogInterceptor(responseBody: true));

  return dio;
});
