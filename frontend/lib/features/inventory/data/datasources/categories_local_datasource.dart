import 'package:frontend/core/storage/offline_service.dart';

class CategoriesLocalDataSource {
  static const String boxName = OfflineService.categoriesBoxName;

  Future<void> saveCategoryLocally(Map<String, dynamic> data) async {
    await OfflineService.saveItem(boxName, data);
  }

  List<Map<String, dynamic>> getCachedCategories() {
    return OfflineService.getItems(boxName);
  }

  List<Map<String, dynamic>> getUnsyncedCategories() {
    return OfflineService.getUnsynced(boxName);
  }

  Future<void> deleteCategoryLocally(String id) async {
    await OfflineService.deleteItem(boxName, id);
  }

  Future<void> markAsSynced(String id) async {
    await OfflineService.markAsSynced(boxName, id);
  }
}
