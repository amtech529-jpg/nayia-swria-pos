import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class DiscountsScreen extends StatefulWidget {
  const DiscountsScreen({super.key});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MainLayout(
      currentRoute: '/discounts',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Discounts']),
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
                    const Text('All Discounts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: PosButton(label: '+ Add Discount', onTap: () {})),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PosSearchField(controller: _searchCtrl, hint: 'Search Discount', width: double.infinity, onChanged: (_) => setState(() {})),
                  ],
                )
              : Row(
                  children: [
                    const Text('All Discounts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const Spacer(),
                    PosButton(label: '+ Add Discount', onTap: () {}),
                    const SizedBox(width: 12),
                    PosSearchField(controller: _searchCtrl, hint: 'Search Discount', onChanged: (_) => setState(() {})),
                  ],
                ),
          ),
          PosTable(
            columns: const ['', 'NAME', 'BUSINESS LOCATION', 'DISCOUNT TYPE', 'DISCOUNT AMOUNT', 'STARTS AT', 'ENDS AT', 'ACTIONS'],
            rows: [
              ['', 'Eid Offer', 'Default', 'Percentage', '10%', 'May 10, 2026', 'May 20, 2026', const Icon(Icons.more_vert, size: 18, color: AppColors.tableSubText)],
            ],
          ),
        ],
      ),
    );
  }
}
