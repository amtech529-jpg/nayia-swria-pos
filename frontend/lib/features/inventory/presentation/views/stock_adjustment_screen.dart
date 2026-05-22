import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MainLayout(
      currentRoute: '/stock-adjustments',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Stock Adjustments']),
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
            child: isMobile 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('All Stock Adjustments', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: PosButton(label: '+ Add Adjustment', onTap: () {})),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PosSearchField(controller: _searchCtrl, hint: 'Search Adjustment', width: double.infinity, onChanged: (_) => setState(() {})),
                  ],
                )
              : Row(
                  children: [
                    const Text('All Stock Adjustments', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const Spacer(),
                    PosButton(label: '+ Add Adjustment', onTap: () {}),
                    const SizedBox(width: 12),
                    PosSearchField(controller: _searchCtrl, hint: 'Search Adjustment', onChanged: (_) => setState(() {})),
                  ],
                ),
          ),
          PosTable(
            columns: const ['', 'DATE', 'REFERENCE NO', 'LOCATION', 'ADJUSTMENT TYPE', 'TOTAL AMOUNT', 'ADDED BY'],
            rows: [
              ['', 'May 06, 2026', 'SA0001', 'Default', 'Normal', 'Rs 2,000', 'Admin'],
            ],
          ),
        ],
      ),
    );
  }
}
