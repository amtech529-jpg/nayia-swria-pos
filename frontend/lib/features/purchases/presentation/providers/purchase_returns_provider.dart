import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/purchases/data/models/purchase_return_model.dart';
import 'package:frontend/features/purchases/data/repositories/purchase_returns_repository_impl.dart';

final purchaseReturnsRepositoryProvider = Provider<PurchaseReturnsRepositoryImpl>((ref) {
  final dio = ref.watch(apiClientProvider);
  return PurchaseReturnsRepositoryImpl(dio);
});

class PurchaseReturnsNotifier extends StateNotifier<AsyncValue<List<PurchaseReturnModel>>> {
  final PurchaseReturnsRepositoryImpl _repository;

  PurchaseReturnsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPurchaseReturns();
  }

  Future<void> loadPurchaseReturns() async {
    try {
      state = const AsyncValue.loading();
      final returns = await _repository.getPurchaseReturns();
      state = AsyncValue.data(returns);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addPurchaseReturn(PurchaseReturnModel model) async {
    try {
      final newReturn = await _repository.createPurchaseReturn(model);
      if (state.hasValue) {
        state = AsyncValue.data([newReturn, ...state.value!]);
      }
      return true;
    } catch (e) {
      print('Failed to add purchase return: $e');
      return false;
    }
  }
}

final purchaseReturnsProvider = StateNotifierProvider<PurchaseReturnsNotifier, AsyncValue<List<PurchaseReturnModel>>>((ref) {
  final repository = ref.watch(purchaseReturnsRepositoryProvider);
  return PurchaseReturnsNotifier(repository);
});
