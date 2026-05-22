import 'package:hive/hive.dart';
import '../datasources/suppliers_local_datasource.dart';
import '../datasources/suppliers_remote_datasource.dart';
import '../models/supplier_model.dart';

class SuppliersRepositoryImpl {
  final SuppliersRemoteDataSource _remoteDS;
  final SuppliersLocalDataSource _localDS;

  SuppliersRepositoryImpl(this._remoteDS, this._localDS);

  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final response = await _remoteDS.getSuppliers();
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['results'] ?? response.data['data'] ?? []);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await _localDS.saveSupplierLocally(map);
        }
      }
    } catch (_) {
      // Fallback silently to offline cache
    }
    return _localDS.getCachedSuppliers()
        .map((e) => SupplierModel.fromMap(e))
        .toList();
  }

  Future<void> saveSupplier(SupplierModel supplier) async {
    final map = supplier.toMap();
    // Offline first
    await _localDS.saveSupplierLocally(map);
    // Background sync try
    await syncPendingSuppliers();
  }

  Future<void> deleteSupplier(String id) async {
    await _localDS.deleteSupplierLocally(id);
    await syncPendingSuppliers();
  }

  Future<void> syncPendingSuppliers() async {
    final unsynced = _localDS.getUnsyncedSuppliers();
    for (var item in unsynced) {
      final id = item['id'];
      if (item['deleted'] == true || item['deleted'] == 1) {
        try {
          final res = await _remoteDS.deleteSupplier(id);
          if (res.statusCode == 200 || res.statusCode == 204) {
            // Permanently clear from local Hive db
            final box = Hive.box(SuppliersLocalDataSource.boxName);
            await box.delete(id);
          }
        } catch (_) {}
      } else {
        try {
          final payload = {
            'id': item['id'],
            'name': item['name'],
            'email': item['email'],
            'phone': item['phone'],
            'location': item['location'],
            'purchase_total': item['purchase_total'],
          };
          dynamic res;
          try {
            res = await _remoteDS.updateSupplier(id, payload);
          } catch (_) {
            res = await _remoteDS.createSupplier(payload);
          }
          if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
            await _localDS.markAsSynced(id);
          }
        } catch (_) {}
      }
    }
  }
}
