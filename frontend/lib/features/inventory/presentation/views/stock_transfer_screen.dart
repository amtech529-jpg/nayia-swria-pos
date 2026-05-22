import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({super.key});

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MainLayout(
      currentRoute: '/stock-transfer',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Stock Transfers']),
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
                    const Text('All Stock Transfers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: PosButton(label: '+ Add Transfer', onTap: () {})),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PosSearchField(controller: _searchCtrl, hint: 'Search Transfer', width: double.infinity, onChanged: (_) => setState(() {})),
                  ],
                )
              : Row(
                  children: [
                    const Text('All Stock Transfers', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const Spacer(),
                    PosButton(label: '+ Add Transfer', onTap: () {}),
                    const SizedBox(width: 12),
                    PosSearchField(controller: _searchCtrl, hint: 'Search Transfer', onChanged: (_) => setState(() {})),
                  ],
                ),
          ),
          PosTable(
            columns: const ['', 'DATE', 'REFERENCE NO', 'LOCATION (FROM)', 'LOCATION (TO)', 'STATUS', 'SHIPPING CHARGES', 'TOTAL AMOUNT', 'ADDED BY'],
            rows: [
              ['', 'May 07, 2026', 'ST0001', 'Default', 'Warehouse A', 'Completed', 'Rs 200', 'Rs 15,000', 'Admin'],
            ],
          ),
        ],
      ),
    );
  }
}
