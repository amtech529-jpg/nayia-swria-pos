import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/customers/data/models/customer_model.dart';
import 'package:frontend/features/customers/data/datasources/customers_local_datasource.dart';
import 'package:frontend/features/customers/data/datasources/customers_remote_datasource.dart';
import 'package:frontend/features/customers/data/repositories/customers_repository_impl.dart';

// Local and Remote Data Source providers
final customersLocalDSProvider = Provider((ref) => CustomersLocalDataSource());
final customersRemoteDSProvider = Provider((ref) => CustomersRemoteDataSource(ref.watch(apiClientProvider)));

// Repository Provider
final customersRepositoryProvider = Provider((ref) {
  final remoteDS = ref.watch(customersRemoteDSProvider);
  final localDS = ref.watch(customersLocalDSProvider);
  return CustomersRepositoryImpl(remoteDS, localDS);
});

class CustomerListNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  final CustomersRepositoryImpl _repository;

  CustomerListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        state = const AsyncValue.loading();
        final list = await _repository.getCustomers();
        state = AsyncValue.data(list);
      } else {
        // Return cached list immediately to achieve 0ms lag
        final cached = _repository.getCachedCustomers();
        state = AsyncValue.data(cached);

        // Fetch remote updates asynchronously in the background
        _repository.getCustomers().then((list) {
          if (mounted) {
            state = AsyncValue.data(list);
          }
        }).catchError((_) {});
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addCustomer(CustomerModel customer) async {
    try {
      await _repository.saveCustomer(customer);
      await loadCustomers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      await _repository.saveCustomer(customer);
      await loadCustomers();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      await loadCustomers();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// StateNotifierProvider
final customersListProvider = StateNotifierProvider<CustomerListNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return CustomerListNotifier(repository);
});
