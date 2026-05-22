import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../network/sync_service.dart';

// Dependency Injection Registry using Riverpod
// Exposes core infrastructure layers to the presentation layers in a decoupled manner

final syncServiceDI = Provider<SyncService>((ref) {
  return ref.watch(syncServiceProvider);
});
