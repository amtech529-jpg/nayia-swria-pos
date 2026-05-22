import 'package:frontend/features/customers/data/models/area_manager_model.dart';
import 'package:frontend/features/customers/data/datasources/area_managers_local_datasource.dart';
import 'package:frontend/features/customers/data/datasources/area_managers_remote_datasource.dart';

class AreaManagersRepositoryImpl {
  final AreaManagersRemoteDataSource remoteDS;
  final AreaManagersLocalDataSource localDS;

  AreaManagersRepositoryImpl(this.remoteDS, this.localDS);

  Future<List<AreaManagerModel>> getAreaManagers() async {
    try {
      await _syncUnsyncedData();
      final remoteData = await remoteDS.getAreaManagers();
      for (var item in remoteData) {
        final Map<String, dynamic> dataMap = Map<String, dynamic>.from(item);
        dataMap['synced'] = true;
        await localDS.saveAreaManagerLocally(dataMap);
      }
    } catch (e) {
      // Offline: just use local
    }
    return getCachedAreaManagers();
  }

  List<AreaManagerModel> getCachedAreaManagers() {
    final localData = localDS.getCachedAreaManagers();
    return localData.map((e) => AreaManagerModel.fromMap(e)).toList();
  }

  Future<void> saveAreaManager(AreaManagerModel manager) async {
    final data = manager.toMap();
    try {
      final savedData = await remoteDS.saveAreaManager(data);
      savedData['synced'] = true;
      await localDS.saveAreaManagerLocally(savedData);
    } catch (e) {
      data['synced'] = false;
      await localDS.saveAreaManagerLocally(data);
    }
  }

  Future<void> deleteAreaManager(String id) async {
    try {
      await remoteDS.deleteAreaManager(id);
      await localDS.deleteAreaManagerLocally(id);
    } catch (e) {
      await localDS.deleteAreaManagerLocally(id);
    }
  }

  Future<void> _syncUnsyncedData() async {
    final unsynced = localDS.getUnsyncedAreaManagers();
    for (var item in unsynced) {
      try {
        if (item['deleted'] == true) {
          await remoteDS.deleteAreaManager(item['id']);
        } else {
          await remoteDS.saveAreaManager(item);
        }
        await localDS.markAsSynced(item['id']);
      } catch (e) {
        // Skip sync for this item if error
      }
    }
  }
}
