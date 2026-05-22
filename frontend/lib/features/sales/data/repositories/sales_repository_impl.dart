import 'package:hive/hive.dart';
import '../datasources/sales_local_datasource.dart';
import '../datasources/sales_remote_datasource.dart';
import '../models/sale_model.dart';

class SalesRepositoryImpl {
  final SalesRemoteDataSource _remoteDS;
  final SalesLocalDataSource _localDS;

  SalesRepositoryImpl(this._remoteDS, this._localDS);

  Future<List<SaleModel>> getSales() async {
    try {
      final response = await _remoteDS.getSales();
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await _localDS.saveSaleLocally(map);
        }
      }
    } catch (_) {
      // Silently fallback to cache
    }
    return _localDS
        .getCachedSales()
        .map((e) => SaleModel.fromMap(e))
        .toList();
  }

  List<SaleModel> getCachedSales() {
    return _localDS
        .getCachedSales()
        .map((e) => SaleModel.fromMap(e))
        .toList();
  }

  Future<void> saveSale(SaleModel sale) async {
    final map = sale.toMap();
    await _localDS.saveSaleLocally(map);
    await syncPendingSales();
  }

  Future<void> deleteSale(String id) async {
    await _localDS.deleteSaleLocally(id);
    await syncPendingSales();
  }

  Future<void> syncPendingSales() async {
    final unsynced = _localDS.getUnsyncedSales();
    for (var item in unsynced) {
      final id = item['id'] as String;
      if (item['deleted'] == true || item['deleted'] == 1) {
        try {
          final res = await _remoteDS.deleteSale(id);
          if (res.statusCode == 200 || res.statusCode == 204) {
            final box = Hive.box(SalesLocalDataSource.boxName);
            await box.delete(id);
          }
        } catch (_) {}
      } else {
        try {
          final payload = Map<String, dynamic>.from(item);
          payload.remove('synced');
          payload.remove('deleted');
          
          // Try to update first (in case of partial payment edit)
          try {
            final res = await _remoteDS.updateSale(id, payload);
            if (res.statusCode == 200 || res.statusCode == 201) {
              await _localDS.markAsSynced(id);
              continue; // Success, go to next item
            }
          } catch (e) {
            // If 404 Not Found, it means it's a new sale that hasn't been synced yet
            // Fall through to POST
          }

          // Fallback to Create
          final res = await _remoteDS.createSale(payload);
          if (res.statusCode == 200 || res.statusCode == 201) {
            await _localDS.markAsSynced(id);
          }
        } catch (_) {}
      }
    }
  }
}
