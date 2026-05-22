import 'package:dio/dio.dart';
import 'package:frontend/features/purchases/data/models/purchase_return_model.dart';
import 'package:uuid/uuid.dart';

class PurchaseReturnsRepositoryImpl {
  final Dio _dio;

  PurchaseReturnsRepositoryImpl(this._dio);

  Future<List<PurchaseReturnModel>> getPurchaseReturns() async {
    try {
      final response = await _dio.get('/api/v1/purchase-returns/');
      if (response.statusCode == 200) {
        final data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        return (data as List)
            .map((json) => PurchaseReturnModel.fromMap(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting purchase returns: $e');
      return [];
    }
  }

  Future<PurchaseReturnModel> createPurchaseReturn(PurchaseReturnModel model) async {
    try {
      final payload = model.toMap();
      if (payload['id'] == null || payload['id'].toString().isEmpty) {
        payload['id'] = const Uuid().v4();
      }
      final response = await _dio.post('/api/v1/purchase-returns/', data: payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return PurchaseReturnModel.fromMap(response.data['data']);
      }
      throw Exception('Failed to create purchase return');
    } catch (e) {
      print('Error creating purchase return: $e');
      throw e;
    }
  }
}
