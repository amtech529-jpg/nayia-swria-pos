import 'package:flutter/material.dart';

class AppConfig {
  final String shopName;
  final String? logoUrl;
  final Color primaryColor;
  final bool isDarkMode;

  AppConfig({
    this.shopName = 'Nayia Swaria',
    this.logoUrl,
    this.primaryColor = Colors.deepPurple,
    this.isDarkMode = false,
  });

  AppConfig copyWith({
    String? shopName,
    String? logoUrl,
    Color? primaryColor,
    bool? isDarkMode,
  }) {
    return AppConfig(
      shopName: shopName ?? this.shopName,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
