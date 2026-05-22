import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class InvoiceSchemesScreen extends StatelessWidget {
  const InvoiceSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MainLayout(
      currentRoute: '/settings/invoices',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Settings', 'Invoice Schemes']),
            const SizedBox(height: 16),
            _buildTableCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('All Invoice Schemes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const Spacer(),
                PosButton(label: '+ Add Scheme', onTap: () {}),
              ],
            ),
          ),
          PosTable(
            columns: const ['NAME', 'PREFIX', 'START NUMBER', 'TOTAL DIGITS', 'ACTIONS'],
            rows: [
              ['Default', 'INV-', '0001', '4', const Icon(Icons.more_vert)],
            ],
          ),
        ],
      ),
    );
  }
}
