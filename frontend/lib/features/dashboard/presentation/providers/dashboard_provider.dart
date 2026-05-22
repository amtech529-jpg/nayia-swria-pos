import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/api_client.dart';

final dashboardStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, query) async {
  try {
    final dio = ref.watch(apiClientProvider);
    final response = await dio.get('/api/v1/dashboard-stats/$query');
    if (response.statusCode == 200 && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
    }
    return {};
  } catch (e) {
    return {};
  }
});
