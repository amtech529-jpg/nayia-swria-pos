import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class OfflineService {
  static const String salesBoxName = 'sales_box';
  static const String productsBoxName = 'products_box';
  static const String categoriesBoxName = 'categories_box';
  static const String customersBoxName = 'customers_box';
  static const String suppliersBoxName = 'suppliers_box';
  static const String purchasesBoxName = 'purchases_box';
  static const String areaManagersBoxName = 'area_managers_box';

  static Future<void> init() async {
    await Hive.openBox(salesBoxName);
    await Hive.openBox(productsBoxName);
    await Hive.openBox(categoriesBoxName);
    await Hive.openBox(customersBoxName);
    await Hive.openBox(suppliersBoxName);
    await Hive.openBox(purchasesBoxName);
    await Hive.openBox(areaManagersBoxName);
  }

  static String generateId() {
    return const Uuid().v4();
  }

  // Save item locally (offline-first)
  static Future<void> saveItem(String boxName, Map<String, dynamic> data) async {
    final box = Hive.box(boxName);
    final String id = data['id'] ?? generateId();
    data['id'] = id;
    data['synced'] = false;
    await box.put(id, data);
  }

  // Get all items locally (excluding soft-deleted ones)
  static List<Map<String, dynamic>> getItems(String boxName) {
    final box = Hive.box(boxName);
    return box.values
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((item) => item['deleted'] == false || item['deleted'] == 0 || item['deleted'] == null)
        .toList();
  }

  // Get all unsynced items (including soft-deleted ones so we sync their deletion)
  static List<Map<String, dynamic>> getUnsynced(String boxName) {
    final box = Hive.box(boxName);
    return box.values
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((item) => item['synced'] == false)
        .toList();
  }

  // Soft delete item locally
  static Future<void> deleteItem(String boxName, String id) async {
    final box = Hive.box(boxName);
    final item = box.get(id);
    if (item != null) {
      final updated = Map<String, dynamic>.from(item);
      updated['deleted'] = true;
      updated['synced'] = false;
      await box.put(id, updated);
    }
  }

  // Mark an item as synced
  static Future<void> markAsSynced(String boxName, String id) async {
    final box = Hive.box(boxName);
    final item = box.get(id);
    if (item != null) {
      final updated = Map<String, dynamic>.from(item);
      updated['synced'] = true;
      await box.put(id, updated);
    }
  }
}
