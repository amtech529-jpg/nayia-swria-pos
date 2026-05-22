import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';

final configProvider = StateNotifierProvider<ConfigNotifier, AppConfig>((ref) {
  return ConfigNotifier();
});

class ConfigNotifier extends StateNotifier<AppConfig> {
  ConfigNotifier() : super(AppConfig());

  void updateShopName(String name) {
    state = state.copyWith(shopName: name);
  }

  void updateLogo(String url) {
    state = state.copyWith(logoUrl: url);
  }

  void updatePrimaryColor(Color color) {
    state = state.copyWith(primaryColor: color);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}
