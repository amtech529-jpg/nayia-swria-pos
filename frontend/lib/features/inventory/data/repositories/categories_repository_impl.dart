import 'package:hive/hive.dart';
import '../datasources/categories_local_datasource.dart';
import '../datasources/categories_remote_datasource.dart';
import '../models/category_model.dart';

class CategoriesRepositoryImpl {
  final CategoriesRemoteDataSource _remoteDS;
  final CategoriesLocalDataSource _localDS;

  CategoriesRepositoryImpl(this._remoteDS, this._localDS);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _remoteDS.getCategories();
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['results'] ?? response.data['data'] ?? []);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await _localDS.saveCategoryLocally(map);
        }
      }
    } catch (_) {
      // Fallback silently to offline cache
    }
    return _localDS.getCachedCategories()
        .map((e) => CategoryModel.fromMap(e))
        .toList();
  }

  Future<void> saveCategory(CategoryModel category) async {
    final map = category.toMap();
    // Offline first
    await _localDS.saveCategoryLocally(map);
    // Background sync try
    await syncPendingCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _localDS.deleteCategoryLocally(id);
    await syncPendingCategories();
  }

  Future<void> syncPendingCategories() async {
    final unsynced = _localDS.getUnsyncedCategories();
    for (var item in unsynced) {
      final id = item['id'];
      if (item['deleted'] == true || item['deleted'] == 1) {
        try {
          final res = await _remoteDS.deleteCategory(id);
          if (res.statusCode == 200 || res.statusCode == 204) {
            // Permanently clear from local Hive db
            final box = Hive.box(CategoriesLocalDataSource.boxName);
            await box.delete(id);
          }
        } catch (_) {}
      } else {
        try {
          final payload = {
            'id': item['id'],
            'name': item['name'],
            'description': item['description'],
            'parent': item['parent'],
          };
          dynamic res;
          try {
            res = await _remoteDS.updateCategory(id, payload);
          } catch (_) {
            res = await _remoteDS.createCategory(payload);
          }
          if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
            await _localDS.markAsSynced(id);
          }
        } catch (_) {}
      }
    }
  }
}
