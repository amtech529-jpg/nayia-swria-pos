import 'package:dio/dio.dart';

class SalesRemoteDataSource {
  final Dio _dio;

  SalesRemoteDataSource(this._dio);

  Future<Response> getSales() async {
    return await _dio.get('/api/v1/sales/');
  }

  Future<Response> createSale(Map<String, dynamic> data) async {
    return await _dio.post('/api/v1/sales/', data: data);
  }

  Future<Response> updateSale(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/v1/sales/$id/', data: data);
  }

  Future<Response> deleteSale(String id) async {
    return await _dio.delete('/api/v1/sales/$id/');
  }
}
