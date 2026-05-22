import 'package:dio/dio.dart';

class AreaManagersRemoteDataSource {
  final Dio apiClient;

  AreaManagersRemoteDataSource(this.apiClient);

  Future<List<dynamic>> getAreaManagers() async {
    try {
      final response = await apiClient.get('/api/v1/posapi/area-managers/');
      return response.data['results'] ?? response.data['data'] ?? [];
    } catch (e) {
      // Maybe the endpoint doesn't have /api/v1 prefix, fallback
      try {
        final fallbackResponse = await apiClient.get('/posapi/area-managers/');
        return fallbackResponse.data['results'] ?? fallbackResponse.data['data'] ?? [];
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> saveAreaManager(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.post('/api/v1/posapi/area-managers/', data: data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      try {
        final fallbackResponse = await apiClient.post('/posapi/area-managers/', data: data);
        return fallbackResponse.data['data'] ?? fallbackResponse.data;
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<void> deleteAreaManager(String id) async {
    try {
      await apiClient.delete('/api/v1/posapi/area-managers/$id/');
    } catch (e) {
      try {
        await apiClient.delete('/posapi/area-managers/$id/');
      } catch (_) {
        rethrow;
      }
    }
  }
}
