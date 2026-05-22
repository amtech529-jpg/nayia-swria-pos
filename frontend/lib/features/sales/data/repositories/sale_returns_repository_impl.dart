import 'package:dio/dio.dart';
import 'package:frontend/features/sales/data/models/sale_return_model.dart';
import 'package:uuid/uuid.dart';

class SaleReturnsRepositoryImpl {
  final Dio _dio;

  SaleReturnsRepositoryImpl(this._dio);

  Future<List<SaleReturnModel>> getSaleReturns() async {
    try {
      final response = await _dio.get('/api/v1/sale-returns/');
      if (response.statusCode == 200) {
        final data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        return (data as List)
            .map((json) => SaleReturnModel.fromMap(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting sale returns: $e');
      return [];
    }
  }

  Future<SaleReturnModel> createSaleReturn(SaleReturnModel model) async {
    try {
      final payload = model.toMap();
      if (payload['id'] == null || payload['id'].toString().isEmpty) {
        payload['id'] = const Uuid().v4();
      }
      final response = await _dio.post('/api/v1/sale-returns/', data: payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return SaleReturnModel.fromMap(response.data['data']);
      }
      throw Exception('Failed to create sale return');
    } catch (e) {
      print('Error creating sale return: $e');
      throw e;
    }
  }
}
