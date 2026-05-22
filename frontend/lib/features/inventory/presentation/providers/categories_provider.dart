import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/inventory/data/models/category_model.dart';
import 'package:frontend/features/inventory/data/datasources/categories_local_datasource.dart';
import 'package:frontend/features/inventory/data/datasources/categories_remote_datasource.dart';
import 'package:frontend/features/inventory/data/repositories/categories_repository_impl.dart';

// Local and Remote Data Source providers
final categoriesLocalDSProvider = Provider((ref) => CategoriesLocalDataSource());
final categoriesRemoteDSProvider = Provider((ref) => CategoriesRemoteDataSource(ref.watch(apiClientProvider)));

// Repository Provider
final categoriesRepositoryProvider = Provider((ref) {
  final remoteDS = ref.watch(categoriesRemoteDSProvider);
  final localDS = ref.watch(categoriesLocalDSProvider);
  return CategoriesRepositoryImpl(remoteDS, localDS);
});

class CategoryListNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoriesRepositoryImpl _repository;

  CategoryListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final list = await _repository.getCategories();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addCategory(CategoryModel category) async {
    try {
      await _repository.saveCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      await _repository.saveCategory(category);
      await loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// StateNotifierProvider
final categoriesListProvider = StateNotifierProvider<CategoryListNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  final repository = ref.watch(categoriesRepositoryProvider);
  return CategoryListNotifier(repository);
});
