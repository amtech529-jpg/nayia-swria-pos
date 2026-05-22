import 'package:frontend/core/storage/offline_service.dart';

class SalesLocalDataSource {
  static const String boxName = OfflineService.salesBoxName;

  Future<void> saveSaleLocally(Map<String, dynamic> data) async {
    await OfflineService.saveItem(boxName, data);
  }

  List<Map<String, dynamic>> getCachedSales() {
    return OfflineService.getItems(boxName);
  }

  List<Map<String, dynamic>> getUnsyncedSales() {
    return OfflineService.getUnsynced(boxName);
  }

  Future<void> deleteSaleLocally(String id) async {
    await OfflineService.deleteItem(boxName, id);
  }

  Future<void> markAsSynced(String id) async {
    await OfflineService.markAsSynced(boxName, id);
  }
}
