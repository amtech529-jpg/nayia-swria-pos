import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';

class BreadcrumbWidget extends StatelessWidget {
  final List<String> items;
  const BreadcrumbWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (e.key == 0)
                const Icon(Icons.home_outlined, size: 16, color: AppColors.breadcrumbText),
              if (e.key > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.chevron_right, size: 16, color: AppColors.breadcrumbText),
                ),
              Text(
                e.value,
                style: TextStyle(
                  fontSize: 13,
                  color: isLast ? AppColors.breadcrumbActive : AppColors.breadcrumbText,
                  fontWeight: isLast ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
