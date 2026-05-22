import 'package:dio/dio.dart';
import 'package:frontend/features/inventory/data/models/unit_model.dart';
import 'package:uuid/uuid.dart';

class UnitsRepositoryImpl {
  final Dio _dio;
  
  UnitsRepositoryImpl(this._dio);

  Future<List<UnitModel>> getUnits() async {
    try {
      final response = await _dio.get('/api/v1/units/');
      if (response.statusCode == 200) {
        final data = response.data is List
            ? response.data
            : (response.data['results'] ?? response.data['data'] ?? []);
            
        return (data as List)
            .map((json) => UnitModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting units: $e');
      return [];
    }
  }

  Future<UnitModel> createUnit(UnitModel unit) async {
    try {
      final payload = unit.toJson();
      if (payload['id'] == null || payload['id'].toString().isEmpty) {
        payload['id'] = const Uuid().v4();
      }
      final response = await _dio.post('/api/v1/units/', data: payload);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return UnitModel.fromJson(response.data);
      }
      throw Exception('Failed to create unit');
    } catch (e) {
      print('Error creating unit: $e');
      throw e;
    }
  }

  Future<UnitModel> updateUnit(UnitModel unit) async {
    try {
      final response = await _dio.put('/api/v1/units/${unit.id}/', data: unit.toJson());
      if (response.statusCode == 200) {
        return UnitModel.fromJson(response.data);
      }
      throw Exception('Failed to update unit');
    } catch (e) {
      print('Error updating unit: $e');
      throw e;
    }
  }

  Future<bool> deleteUnit(String id) async {
    try {
      final response = await _dio.delete('/api/v1/units/$id/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting unit: $e');
      return false;
    }
  }
}
