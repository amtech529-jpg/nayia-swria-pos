import 'package:dio/dio.dart';

class SuppliersRemoteDataSource {
  final Dio _dio;

  SuppliersRemoteDataSource(this._dio);

  Future<Response> getSuppliers() async {
    return await _dio.get('/api/v1/suppliers/');
  }

  Future<Response> createSupplier(Map<String, dynamic> data) async {
    return await _dio.post('/api/v1/suppliers/', data: data);
  }

  Future<Response> updateSupplier(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/v1/suppliers/$id/', data: data);
  }

  Future<Response> deleteSupplier(String id) async {
    return await _dio.delete('/api/v1/suppliers/$id/');
  }
}
