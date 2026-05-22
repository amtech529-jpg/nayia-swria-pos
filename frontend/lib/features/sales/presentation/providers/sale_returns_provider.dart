import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/sales/data/models/sale_return_model.dart';
import 'package:frontend/features/sales/data/repositories/sale_returns_repository_impl.dart';

final saleReturnsRepositoryProvider = Provider<SaleReturnsRepositoryImpl>((ref) {
  final dio = ref.watch(apiClientProvider);
  return SaleReturnsRepositoryImpl(dio);
});

class SaleReturnsNotifier extends StateNotifier<AsyncValue<List<SaleReturnModel>>> {
  final SaleReturnsRepositoryImpl _repository;

  SaleReturnsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSaleReturns();
  }

  Future<void> loadSaleReturns() async {
    try {
      state = const AsyncValue.loading();
      final returns = await _repository.getSaleReturns();
      state = AsyncValue.data(returns);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addSaleReturn(SaleReturnModel model) async {
    try {
      final newReturn = await _repository.createSaleReturn(model);
      if (state.hasValue) {
        state = AsyncValue.data([newReturn, ...state.value!]);
      }
      return true;
    } catch (e) {
      print('Failed to add sale return: $e');
      return false;
    }
  }
}

final saleReturnsProvider = StateNotifierProvider<SaleReturnsNotifier, AsyncValue<List<SaleReturnModel>>>((ref) {
  final repository = ref.watch(saleReturnsRepositoryProvider);
  return SaleReturnsNotifier(repository);
});
