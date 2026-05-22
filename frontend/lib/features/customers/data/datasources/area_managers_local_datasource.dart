import 'package:frontend/core/storage/offline_service.dart';

class AreaManagersLocalDataSource {
  static const String boxName = OfflineService.areaManagersBoxName;

  Future<void> saveAreaManagerLocally(Map<String, dynamic> data) async {
    await OfflineService.saveItem(boxName, data);
  }

  List<Map<String, dynamic>> getCachedAreaManagers() {
    return OfflineService.getItems(boxName);
  }

  List<Map<String, dynamic>> getUnsyncedAreaManagers() {
    return OfflineService.getUnsynced(boxName);
  }

  Future<void> deleteAreaManagerLocally(String id) async {
    await OfflineService.deleteItem(boxName, id);
  }

  Future<void> markAsSynced(String id) async {
    await OfflineService.markAsSynced(boxName, id);
  }
}
