import 'package:frontend/core/storage/offline_service.dart';

class ProductsLocalDataSource {
  static const String boxName = OfflineService.productsBoxName;

  Future<void> saveProductLocally(Map<String, dynamic> data) async {
    await OfflineService.saveItem(boxName, data);
  }

  List<Map<String, dynamic>> getCachedProducts() {
    return OfflineService.getItems(boxName);
  }

  List<Map<String, dynamic>> getUnsyncedProducts() {
    return OfflineService.getUnsynced(boxName);
  }

  Future<void> deleteProductLocally(String id) async {
    await OfflineService.deleteItem(boxName, id);
  }

  Future<void> markAsSynced(String id) async {
    await OfflineService.markAsSynced(boxName, id);
  }
}
