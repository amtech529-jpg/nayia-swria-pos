import 'package:dio/dio.dart';

class CustomersRemoteDataSource {
  final Dio _dio;

  CustomersRemoteDataSource(this._dio);

  Future<Response> getCustomers() async {
    return await _dio.get('/api/v1/customers/');
  }

  Future<Response> createCustomer(Map<String, dynamic> data) async {
    return await _dio.post('/api/v1/customers/', data: data);
  }

  Future<Response> updateCustomer(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/v1/customers/$id/', data: data);
  }

  Future<Response> deleteCustomer(String id) async {
    return await _dio.delete('/api/v1/customers/$id/');
  }
}
