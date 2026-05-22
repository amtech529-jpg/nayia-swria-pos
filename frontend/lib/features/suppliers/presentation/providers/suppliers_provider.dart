import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/suppliers/data/models/supplier_model.dart';
import 'package:frontend/features/suppliers/data/datasources/suppliers_local_datasource.dart';
import 'package:frontend/features/suppliers/data/datasources/suppliers_remote_datasource.dart';
import 'package:frontend/features/suppliers/data/repositories/suppliers_repository_impl.dart';

// Local and Remote Data Source providers
final suppliersLocalDSProvider = Provider((ref) => SuppliersLocalDataSource());
final suppliersRemoteDSProvider = Provider((ref) => SuppliersRemoteDataSource(ref.watch(apiClientProvider)));

// Repository Provider
final suppliersRepositoryProvider = Provider((ref) {
  final remoteDS = ref.watch(suppliersRemoteDSProvider);
  final localDS = ref.watch(suppliersLocalDSProvider);
  return SuppliersRepositoryImpl(remoteDS, localDS);
});

class SupplierListNotifier extends StateNotifier<AsyncValue<List<SupplierModel>>> {
  final SuppliersRepositoryImpl _repository;

  SupplierListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.getSuppliers();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addSupplier(SupplierModel supplier) async {
    try {
      await _repository.saveSupplier(supplier);
      await loadSuppliers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateSupplier(SupplierModel supplier) async {
    try {
      await _repository.saveSupplier(supplier);
      await loadSuppliers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeSupplier(String id) async {
    try {
      await _repository.deleteSupplier(id);
      await loadSuppliers();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// StateNotifierProvider
final suppliersListProvider = StateNotifierProvider<SupplierListNotifier, AsyncValue<List<SupplierModel>>>((ref) {
  final repository = ref.watch(suppliersRepositoryProvider);
  return SupplierListNotifier(repository);
});
