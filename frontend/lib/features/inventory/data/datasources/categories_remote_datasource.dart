import 'package:dio/dio.dart';

class CategoriesRemoteDataSource {
  final Dio _dio;

  CategoriesRemoteDataSource(this._dio);

  Future<Response> getCategories() async {
    return await _dio.get('/api/v1/categories/');
  }

  Future<Response> createCategory(Map<String, dynamic> data) async {
    return await _dio.post('/api/v1/categories/', data: data);
  }

  Future<Response> updateCategory(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/v1/categories/$id/', data: data);
  }

  Future<Response> deleteCategory(String id) async {
    return await _dio.delete('/api/v1/categories/$id/');
  }
}
