import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../storage/offline_service.dart';
import 'api_client.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../../features/suppliers/data/models/supplier_model.dart';
import '../../features/inventory/data/models/category_model.dart';
import 'package:hive/hive.dart';

class SyncService {
  final Dio _dio;

  SyncService(this._dio);

  // ================= CUSTOMERS SYNC =================
  Future<List<CustomerModel>> getCustomers() async {
    try {
      final response = await _dio.get('/api/v1/customers/');
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['results'] ?? response.data['data'] ?? []);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await OfflineService.saveItem(OfflineService.customersBoxName, map);
        }
      }
    } catch (_) {
      // Fallback to cache
    }
    return OfflineService.getItems(OfflineService.customersBoxName)
        .map((e) => CustomerModel.fromMap(e))
        .toList();
  }

  Future<void> saveCustomer(CustomerModel customer) async {
    final map = customer.toMap();
    map['deleted'] = false;
    await OfflineService.saveItem(OfflineService.customersBoxName, map);
    await syncCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await OfflineService.deleteItem(OfflineService.customersBoxName, id);
    await syncCustomers();
  }

  Future<void> syncCustomers() async {
    final unsynced = OfflineService.getUnsynced(OfflineService.customersBoxName);
    for (var item in unsynced) {
      try {
        if (item['deleted'] == true) {
          final response = await _dio.delete('/api/v1/customers/${item['id']}/');
          if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404) {
            final box = Hive.box(OfflineService.customersBoxName);
            await box.delete(item['id']);
          }
        } else {
          // Try to update via PUT first
          bool updated = false;
          try {
            final response = await _dio.put('/api/v1/customers/${item['id']}/', data: item);
            if (response.statusCode == 200 || response.statusCode == 201) {
              await OfflineService.markAsSynced(OfflineService.customersBoxName, item['id'] as String);
              updated = true;
            }
          } catch (e) {
            if (e is DioException && e.response?.statusCode == 404) {
              // Item does not exist on server yet, fall through to POST (Create)
            } else {
              rethrow;
            }
          }

          if (!updated) {
            final response = await _dio.post('/api/v1/customers/', data: item);
            if (response.statusCode == 200 || response.statusCode == 201) {
              await OfflineService.markAsSynced(OfflineService.customersBoxName, item['id'] as String);
            }
          }
        }
      } catch (_) {
        break; // Stop syncing if server is offline or unreachable
      }
    }
  }

  // ================= SUPPLIERS SYNC =================
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final response = await _dio.get('/api/v1/suppliers/');
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['results'] ?? response.data['data'] ?? []);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await OfflineService.saveItem(OfflineService.suppliersBoxName, map);
        }
      }
    } catch (_) {
      // Fallback
    }
    return OfflineService.getItems(OfflineService.suppliersBoxName)
        .map((e) => SupplierModel.fromMap(e))
        .toList();
  }

  Future<void> saveSupplier(SupplierModel supplier) async {
    final map = supplier.toMap();
    map['deleted'] = false;
    await OfflineService.saveItem(OfflineService.suppliersBoxName, map);
    await syncSuppliers();
  }

  Future<void> deleteSupplier(String id) async {
    await OfflineService.deleteItem(OfflineService.suppliersBoxName, id);
    await syncSuppliers();
  }

  Future<void> syncSuppliers() async {
    final unsynced = OfflineService.getUnsynced(OfflineService.suppliersBoxName);
    for (var item in unsynced) {
      try {
        if (item['deleted'] == true) {
          final response = await _dio.delete('/api/v1/suppliers/${item['id']}/');
          if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404) {
            final box = Hive.box(OfflineService.suppliersBoxName);
            await box.delete(item['id']);
          }
        } else {
          bool updated = false;
          try {
            final response = await _dio.put('/api/v1/suppliers/${item['id']}/', data: item);
            if (response.statusCode == 200 || response.statusCode == 201) {
              await OfflineService.markAsSynced(OfflineService.suppliersBoxName, item['id'] as String);
              updated = true;
            }
          } catch (e) {
            if (e is DioException && e.response?.statusCode == 404) {
              // Fallthrough to POST
            } else {
              rethrow;
            }
          }

          if (!updated) {
            final response = await _dio.post('/api/v1/suppliers/', data: item);
            if (response.statusCode == 200 || response.statusCode == 201) {
              await OfflineService.markAsSynced(OfflineService.suppliersBoxName, item['id'] as String);
            }
          }
        }
      } catch (_) {
        break;
      }
    }
  }

  // ================= CATEGORIES SYNC =================
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/api/v1/categories/');
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['results'] ?? response.data['data'] ?? []);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await OfflineService.saveItem(OfflineService.categoriesBoxName, map);
        }
      }
    } catch (_) {
      // Fallback
    }
    return OfflineService.getItems(OfflineService.categoriesBoxName)
        .map((e) => CategoryModel.fromMap(e))
        .toList();
  }

  Future<void> saveCategory(CategoryModel category) async {
    final map = category.toMap();
    map['deleted'] = false;
    await OfflineService.saveItem(OfflineService.categoriesBoxName, map);
    await syncCategories();
  }

  Future<void> deleteCategory(String id) async {
    await OfflineService.deleteItem(OfflineService.categoriesBoxName, id);
    await syncCategories();
  }

  Future<void> syncCategories() async {
    final unsynced = OfflineService.getUnsynced(OfflineService.categoriesBoxName);
    for (var item in unsynced) {
      try {
        if (item['deleted'] == true) {
          final response = await _dio.delete('/api/v1/categories/${item['id']}/');
          if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404) {
            final box = Hive.box(OfflineService.categoriesBoxName);
            await box.delete(item['id']);
          }
        } else {
          bool updated = false;
          try {
            final response = await _dio.put('/api/v1/categories/${item['id']}/', data: item);
            if (response.statusCode == 200 || response.statusCode == 201) {
              await OfflineService.markAsSynced(OfflineService.categoriesBoxName, item['id'] as String);
              updated = true;
            }
          } catch (e) {
            if (e is DioException && e.response?.statusCode == 404) {
              // Fallthrough to POST
            } else {
              rethrow;
            }
          }

          if (!updated) {
            final response = await _dio.post('/api/v1/categories/', data: item);
            if (response.statusCode == 200 || response.statusCode == 201) {
              await OfflineService.markAsSynced(OfflineService.categoriesBoxName, item['id'] as String);
            }
          }
        }
      } catch (_) {
        break;
      }
    }
  }

  // Universal Sync
  Future<void> syncAll() async {
    await syncCustomers();
    await syncSuppliers();
    await syncCategories();
  }
}

// Global Provider for injection
final syncServiceProvider = Provider<SyncService>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SyncService(dio);
});
