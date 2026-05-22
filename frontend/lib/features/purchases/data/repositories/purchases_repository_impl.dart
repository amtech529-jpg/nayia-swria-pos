import 'package:dio/dio.dart';
import 'package:frontend/core/storage/offline_service.dart';
import 'package:frontend/features/purchases/data/models/purchase_model.dart';
import 'package:hive/hive.dart';

class PurchasesRepositoryImpl {
  final Dio _dio;

  PurchasesRepositoryImpl(this._dio);

  Future<List<PurchaseModel>> getPurchases() async {
    try {
      final response = await _dio.get('/api/v1/purchases/');
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        final box = Hive.box(OfflineService.purchasesBoxName);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await box.put(map['id'], map);
        }
      }
    } catch (_) {
      // Fallback silently to cache
    }
    
    final box = Hive.box(OfflineService.purchasesBoxName);
    return box.values
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((item) => item['deleted'] == false || item['deleted'] == 0 || item['deleted'] == null)
        .map((e) => PurchaseModel.fromMap(e))
        .toList();
  }

  Future<void> savePurchase(PurchaseModel purchase) async {
    final box = Hive.box(OfflineService.purchasesBoxName);
    final map = purchase.toMap();
    map['synced'] = false;
    await box.put(purchase.id, map);
    await syncPendingPurchases();
  }

  Future<void> deletePurchase(String id) async {
    final box = Hive.box(OfflineService.purchasesBoxName);
    final item = box.get(id);
    if (item != null) {
      final updated = Map<String, dynamic>.from(item);
      updated['deleted'] = true;
      updated['synced'] = false;
      await box.put(id, updated);
    }
    await syncPendingPurchases();
  }

  Future<void> syncPendingPurchases() async {
    final box = Hive.box(OfflineService.purchasesBoxName);
    final unsynced = box.values
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((item) => item['synced'] == false)
        .toList();

    for (var item in unsynced) {
      final id = item['id'] as String;
      if (item['deleted'] == true || item['deleted'] == 1) {
        try {
          final res = await _dio.delete('/api/v1/purchases/$id/');
          if (res.statusCode == 200 || res.statusCode == 204) {
            await box.delete(id);
          }
        } catch (_) {}
      } else {
        try {
          final payload = Map<String, dynamic>.from(item);
          payload.remove('synced');
          payload.remove('deleted');
          
          // Try to update first (PUT)
          try {
            final res = await _dio.put('/api/v1/purchases/$id/', data: payload);
            if (res.statusCode == 200 || res.statusCode == 201) {
              final updated = Map<String, dynamic>.from(box.get(id));
              updated['synced'] = true;
              await box.put(id, updated);
              continue;
            }
          } catch (_) {}

          // Fallback to Create (POST)
          final res = await _dio.post('/api/v1/purchases/', data: payload);
          if (res.statusCode == 200 || res.statusCode == 201) {
            final updated = Map<String, dynamic>.from(box.get(id));
            updated['synced'] = true;
            await box.put(id, updated);
          }
        } catch (_) {}
      }
    }
  }
}
