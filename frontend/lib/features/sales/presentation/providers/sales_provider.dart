import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';
import 'package:frontend/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:frontend/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:frontend/features/sales/data/repositories/sales_repository_impl.dart';

// ── Data Source Providers ──────────────────────────────────────────────────────
final salesLocalDSProvider  = Provider((ref) => SalesLocalDataSource());
final salesRemoteDSProvider = Provider((ref) => SalesRemoteDataSource(ref.watch(apiClientProvider)));

// ── Repository Provider ────────────────────────────────────────────────────────
final salesRepositoryProvider = Provider((ref) => SalesRepositoryImpl(
  ref.watch(salesRemoteDSProvider),
  ref.watch(salesLocalDSProvider),
));

// ── State Notifier ─────────────────────────────────────────────────────────────
class SalesListNotifier extends StateNotifier<AsyncValue<List<SaleModel>>> {
  final SalesRepositoryImpl _repository;

  SalesListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSales();
  }

  Future<void> loadSales({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        state = const AsyncValue.loading();
        final list = await _repository.getSales();
        state = AsyncValue.data(list);
      } else {
        // Return local cache immediately to give 0ms instant updates!
        final cached = _repository.getCachedSales();
        state = AsyncValue.data(cached);

        // Fetch updates from Django server in the background
        _repository.getSales().then((list) {
          if (mounted) {
            state = AsyncValue.data(list);
          }
        }).catchError((_) {});
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addSale(SaleModel sale) async {
    try {
      await _repository.saveSale(sale);
      await loadSales();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateSale(SaleModel sale) async {
    try {
      await _repository.saveSale(sale);
      await loadSales();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeSale(String id) async {
    try {
      await _repository.deleteSale(id);
      await loadSales();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── StateNotifierProvider ──────────────────────────────────────────────────────
final salesListProvider =
    StateNotifierProvider<SalesListNotifier, AsyncValue<List<SaleModel>>>(
  (ref) => SalesListNotifier(ref.watch(salesRepositoryProvider)),
);
