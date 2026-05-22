import 'package:hive/hive.dart';
import '../datasources/customers_local_datasource.dart';
import '../datasources/customers_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomersRepositoryImpl {
  final CustomersRemoteDataSource _remoteDS;
  final CustomersLocalDataSource _localDS;

  CustomersRepositoryImpl(this._remoteDS, this._localDS);

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final response = await _remoteDS.getCustomers();
      if (response.statusCode == 200) {
        final List data = response.data is List
            ? response.data
            : (response.data['results'] ?? response.data['data'] ?? []);
        final box = Hive.box(CustomersLocalDataSource.boxName);
        for (var item in data) {
          final map = Map<String, dynamic>.from(item);
          final String id = map['id'] ?? '';
          
          // Check if local version exists and is unsynced
          final localData = box.get(id);
          if (localData != null) {
            final localMap = Map<String, dynamic>.from(localData);
            if (localMap['synced'] == false) {
              continue; // Skip overwriting local changes
            }
          }
          
          map['synced'] = true;
          map['deleted'] = false;
          await box.put(id, map);
        }
      }
    } catch (_) {
      // Fallback silently to offline cache
    }
    return _localDS.getCachedCustomers()
        .map((e) => CustomerModel.fromMap(e))
        .toList();
  }

  List<CustomerModel> getCachedCustomers() {
    return _localDS.getCachedCustomers()
        .map((e) => CustomerModel.fromMap(e))
        .toList();
  }

  Future<void> saveCustomer(CustomerModel customer) async {
    final map = customer.toMap();
    // Offline first
    await _localDS.saveCustomerLocally(map);
    // Background sync try
    await syncPendingCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await _localDS.deleteCustomerLocally(id);
    await syncPendingCustomers();
  }

  Future<void> syncPendingCustomers() async {
    final unsynced = _localDS.getUnsyncedCustomers();
    for (var item in unsynced) {
      final id = item['id'];
      if (item['deleted'] == true || item['deleted'] == 1) {
        try {
          final res = await _remoteDS.deleteCustomer(id);
          if (res.statusCode == 200 || res.statusCode == 204) {
            // Permanently clear from local Hive db
            final box = Hive.box(CustomersLocalDataSource.boxName);
            await box.delete(id);
          }
        } catch (_) {}
      } else {
        try {
          final payload = {
            'id': item['id'],
            'name': item['name'],
            'email': item['email'],
            'phone': item['phone'],
            'cnic': item['cnic'],
            'address': item['address'],
            'area': item['area'],
            'location': item['location'],
            'balance': item['balance'],
          };
          
          dynamic res;
          try {
            res = await _remoteDS.updateCustomer(id, payload);
          } catch (_) {
            res = await _remoteDS.createCustomer(payload);
          }
          
          if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
            await _localDS.markAsSynced(id);
          }
        } catch (_) {}
      }
    }
  }
}
