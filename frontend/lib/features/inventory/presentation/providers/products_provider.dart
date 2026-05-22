import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/inventory/data/models/product_model.dart';
import 'package:frontend/features/inventory/data/datasources/products_local_datasource.dart';
import 'package:frontend/features/inventory/data/datasources/products_remote_datasource.dart';
import 'package:frontend/features/inventory/data/repositories/products_repository_impl.dart';

// ── Data Source Providers ──────────────────────────────────────────────────────
final productsLocalDSProvider  = Provider((ref) => ProductsLocalDataSource());
final productsRemoteDSProvider = Provider((ref) => ProductsRemoteDataSource(ref.watch(apiClientProvider)));

// ── Repository Provider ────────────────────────────────────────────────────────
final productsRepositoryProvider = Provider((ref) => ProductsRepositoryImpl(
  ref.watch(productsRemoteDSProvider),
  ref.watch(productsLocalDSProvider),
));

// ── State Notifier ─────────────────────────────────────────────────────────────
class ProductListNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductsRepositoryImpl _repository;

  ProductListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.getProducts();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addProduct(ProductModel product) async {
    try {
      await _repository.saveProduct(product);
      await loadProducts();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _repository.saveProduct(product);
      await loadProducts();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeProduct(String id) async {
    try {
      await _repository.deleteProduct(id);
      await loadProducts();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── StateNotifierProvider ──────────────────────────────────────────────────────
final productsListProvider =
    StateNotifierProvider<ProductListNotifier, AsyncValue<List<ProductModel>>>(
  (ref) => ProductListNotifier(ref.watch(productsRepositoryProvider)),
);
