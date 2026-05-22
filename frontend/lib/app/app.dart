import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/app/routes.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/features/settings/presentation/providers/config_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final config = ref.watch(configProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Mobile base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: config.shopName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(config.primaryColor),
          darkTheme: AppTheme.darkTheme(config.primaryColor),
          themeMode: config.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
