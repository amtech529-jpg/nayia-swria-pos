import 'package:frontend/core/storage/offline_service.dart';

class CustomersLocalDataSource {
  static const String boxName = OfflineService.customersBoxName;

  Future<void> saveCustomerLocally(Map<String, dynamic> data) async {
    await OfflineService.saveItem(boxName, data);
  }

  List<Map<String, dynamic>> getCachedCustomers() {
    return OfflineService.getItems(boxName);
  }

  List<Map<String, dynamic>> getUnsyncedCustomers() {
    return OfflineService.getUnsynced(boxName);
  }

  Future<void> deleteCustomerLocally(String id) async {
    await OfflineService.deleteItem(boxName, id);
  }

  Future<void> markAsSynced(String id) async {
    await OfflineService.markAsSynced(boxName, id);
  }
}
