import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class BusinessLocationsScreen extends StatelessWidget {
  const BusinessLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MainLayout(
      currentRoute: '/settings/locations',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Settings', 'Business Locations']),
            const SizedBox(height: 16),
            _buildTableCard(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('All Locations', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                PosButton(label: '+ Add Location', onTap: () {}),
              ],
            ),
          ),
          PosTable(
            columns: const ['NAME', 'LOCATION ID', 'CITY', 'STATE', 'COUNTRY', 'ACTIONS'],
            rows: [
              ['Default', 'BL001', 'Faisalabad', 'Punjab', 'Pakistan', const Icon(Icons.more_vert)],
            ],
          ),
        ],
      ),
    );
  }
}
