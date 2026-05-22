import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/purchases/data/models/purchase_model.dart';
import 'package:frontend/features/purchases/data/repositories/purchases_repository_impl.dart';

final purchasesRepositoryProvider = Provider<PurchasesRepositoryImpl>((ref) {
  final dio = ref.watch(apiClientProvider);
  return PurchasesRepositoryImpl(dio);
});

class PurchasesNotifier extends StateNotifier<AsyncValue<List<PurchaseModel>>> {
  final PurchasesRepositoryImpl _repository;

  PurchasesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    try {
      state = const AsyncValue.loading();
      final purchases = await _repository.getPurchases();
      state = AsyncValue.data(purchases);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addPurchase(PurchaseModel model) async {
    try {
      await _repository.savePurchase(model);
      final currentList = state.value ?? [];
      // Replace if existing, else add to top
      final index = currentList.indexWhere((x) => x.id == model.id);
      if (index != -1) {
        final updated = List<PurchaseModel>.from(currentList);
        updated[index] = model;
        state = AsyncValue.data(updated);
      } else {
        state = AsyncValue.data([model, ...currentList]);
      }
      return true;
    } catch (e) {
      print('Failed to save purchase: $e');
      return false;
    }
  }

  Future<bool> deletePurchase(String id) async {
    try {
      await _repository.deletePurchase(id);
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((x) => x.id != id).toList());
      }
      return true;
    } catch (e) {
      print('Failed to delete purchase: $e');
      return false;
    }
  }
}

final purchasesProvider = StateNotifierProvider<PurchasesNotifier, AsyncValue<List<PurchaseModel>>>((ref) {
  final repository = ref.watch(purchasesRepositoryProvider);
  return PurchasesNotifier(repository);
});
