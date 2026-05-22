import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/customers/data/models/area_manager_model.dart';
import 'package:frontend/features/customers/data/datasources/area_managers_local_datasource.dart';
import 'package:frontend/features/customers/data/datasources/area_managers_remote_datasource.dart';
import 'package:frontend/features/customers/data/repositories/area_managers_repository_impl.dart';

final areaManagersLocalDSProvider = Provider((ref) => AreaManagersLocalDataSource());
final areaManagersRemoteDSProvider = Provider((ref) => AreaManagersRemoteDataSource(ref.watch(apiClientProvider)));

final areaManagersRepositoryProvider = Provider((ref) {
  final remoteDS = ref.watch(areaManagersRemoteDSProvider);
  final localDS = ref.watch(areaManagersLocalDSProvider);
  return AreaManagersRepositoryImpl(remoteDS, localDS);
});

class AreaManagerListNotifier extends StateNotifier<AsyncValue<List<AreaManagerModel>>> {
  final AreaManagersRepositoryImpl _repository;

  AreaManagerListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAreaManagers();
  }

  Future<void> loadAreaManagers({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        state = const AsyncValue.loading();
        final list = await _repository.getAreaManagers();
        state = AsyncValue.data(list);
      } else {
        final cached = _repository.getCachedAreaManagers();
        state = AsyncValue.data(cached);

        _repository.getAreaManagers().then((list) {
          if (mounted) {
            state = AsyncValue.data(list);
          }
        }).catchError((_) {});
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addAreaManager(AreaManagerModel manager) async {
    try {
      await _repository.saveAreaManager(manager);
      await loadAreaManagers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAreaManager(AreaManagerModel manager) async {
    try {
      await _repository.saveAreaManager(manager);
      await loadAreaManagers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeAreaManager(String id) async {
    try {
      await _repository.deleteAreaManager(id);
      await loadAreaManagers();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final areaManagersListProvider = StateNotifierProvider<AreaManagerListNotifier, AsyncValue<List<AreaManagerModel>>>((ref) {
  final repository = ref.watch(areaManagersRepositoryProvider);
  return AreaManagerListNotifier(repository);
});
