import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/app/app.dart';

import 'package:frontend/core/storage/offline_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for Offline Support
  await Hive.initFlutter();
  await OfflineService.init();
  
  // Load environment variables if .env file exists
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found, continuing without it
    debugPrint("Warning: .env file not found");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
