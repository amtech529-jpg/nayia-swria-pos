import 'package:frontend/core/storage/offline_service.dart';

class SuppliersLocalDataSource {
  static const String boxName = OfflineService.suppliersBoxName;

  Future<void> saveSupplierLocally(Map<String, dynamic> data) async {
    await OfflineService.saveItem(boxName, data);
  }

  List<Map<String, dynamic>> getCachedSuppliers() {
    return OfflineService.getItems(boxName);
  }

  List<Map<String, dynamic>> getUnsyncedSuppliers() {
    return OfflineService.getUnsynced(boxName);
  }

  Future<void> deleteSupplierLocally(String id) async {
    await OfflineService.deleteItem(boxName, id);
  }

  Future<void> markAsSynced(String id) async {
    await OfflineService.markAsSynced(boxName, id);
  }
}
