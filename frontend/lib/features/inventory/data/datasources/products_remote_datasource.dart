import 'package:dio/dio.dart';

class ProductsRemoteDataSource {
  final Dio _dio;

  ProductsRemoteDataSource(this._dio);

  Future<Response> getProducts() async {
    return await _dio.get('/api/v1/products/');
  }

  Future<Response> createProduct(Map<String, dynamic> data) async {
    return await _dio.post('/api/v1/products/', data: data);
  }

  Future<Response> updateProduct(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/v1/products/$id/', data: data);
  }

  Future<Response> deleteProduct(String id) async {
    return await _dio.delete('/api/v1/products/$id/');
  }
}
