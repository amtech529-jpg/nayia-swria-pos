import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/inventory/data/models/unit_model.dart';
import 'package:frontend/features/inventory/data/repositories/units_repository_impl.dart';

final unitsRepositoryProvider = Provider<UnitsRepositoryImpl>((ref) {
  final dio = ref.watch(apiClientProvider);
  return UnitsRepositoryImpl(dio);
});

class UnitsNotifier extends StateNotifier<AsyncValue<List<UnitModel>>> {
  final UnitsRepositoryImpl _repository;

  UnitsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadUnits();
  }

  Future<void> loadUnits() async {
    try {
      state = const AsyncValue.loading();
      final units = await _repository.getUnits();
      state = AsyncValue.data(units);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addUnit(UnitModel unit) async {
    try {
      final newUnit = await _repository.createUnit(unit);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newUnit]);
      }
      return true;
    } catch (e) {
      print('Failed to add unit: $e');
      return false;
    }
  }

  Future<bool> updateUnit(UnitModel unit) async {
    try {
      final updatedUnit = await _repository.updateUnit(unit);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.map((u) => u.id == unit.id ? updatedUnit : u).toList(),
        );
      }
      return true;
    } catch (e) {
      print('Failed to update unit: $e');
      return false;
    }
  }

  Future<bool> deleteUnit(String id) async {
    try {
      final success = await _repository.deleteUnit(id);
      if (success && state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((u) => u.id != id).toList(),
        );
      }
      return success;
    } catch (e) {
      print('Failed to delete unit: $e');
      return false;
    }
  }
}

final unitsProvider = StateNotifierProvider<UnitsNotifier, AsyncValue<List<UnitModel>>>((ref) {
  final repository = ref.watch(unitsRepositoryProvider);
  return UnitsNotifier(repository);
});
