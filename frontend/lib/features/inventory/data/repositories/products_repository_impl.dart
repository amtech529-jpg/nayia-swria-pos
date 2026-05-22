import 'package:hive/hive.dart';
import '../datasources/products_local_datasource.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl {
  final ProductsRemoteDataSource _remoteDS;
  final ProductsLocalDataSource _localDS;

  ProductsRepositoryImpl(this._remoteDS, this._localDS);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _remoteDS.getProducts();
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          map['synced'] = true;
          map['deleted'] = false;
          await _localDS.saveProductLocally(map);
        }
      }
    } catch (_) {
      // Silently fallback to cache
    }
    return _localDS
        .getCachedProducts()
        .map((e) => ProductModel.fromMap(e))
        .toList();
  }

  Future<void> saveProduct(ProductModel product) async {
    final map = product.toMap();
    await _localDS.saveProductLocally(map);
    await syncPendingProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _localDS.deleteProductLocally(id);
    await syncPendingProducts();
  }

  Future<void> syncPendingProducts() async {
    final unsynced = _localDS.getUnsyncedProducts();
    for (var item in unsynced) {
      final id = item['id'] as String;
      if (item['deleted'] == true || item['deleted'] == 1) {
        try {
          final res = await _remoteDS.deleteProduct(id);
          if (res.statusCode == 200 || res.statusCode == 204) {
            final box = Hive.box(ProductsLocalDataSource.boxName);
            await box.delete(id);
          }
        } catch (_) {}
      } else {
        try {
          final payload = {
            'id': item['id'],
            'name': item['name'],
            'sku': item['sku'],
            'margin': item['margin'],
            'category_id': item['category_id'],
            'category_name': item['category_name'],
            'opening_stock': item['opening_stock'],
            'cost': item['cost'],
            'price': item['price'],
            'alert_qty': item['alert_qty'],
            'location': item['location'],
            'sale_unit': item['sale_unit'],
            'extra_units': item['extra_units'],
            'base_unit': item['base_unit'],
            'purchase_unit': item['purchase_unit'],
            'brand': item['brand'],
            'days_in_expiry': item['days_in_expiry'],
            'status': item['status'],
            'notes': item['notes'],
          };
          final res = await _remoteDS.createProduct(payload);
          if (res.statusCode == 200 || res.statusCode == 201) {
            await _localDS.markAsSynced(id);
          }
        } catch (_) {}
      }
    }
  }
}
