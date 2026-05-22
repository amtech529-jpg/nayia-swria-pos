import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class BarcodesScreen extends StatefulWidget {
  const BarcodesScreen({super.key});

  @override
  State<BarcodesScreen> createState() => _BarcodesScreenState();
}

class _BarcodesScreenState extends State<BarcodesScreen> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MainLayout(
      currentRoute: '/barcodes',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Barcodes']),
            const SizedBox(height: 16),
            _buildActionCard(isMobile),
            const SizedBox(height: 16),
            _buildTableCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Print Barcodes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          isMobile 
            ? Column(
                children: [
                  PosSearchField(controller: _searchCtrl, hint: 'Add product...', width: double.infinity),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: PosButton(label: 'Print', onTap: () {})),
                ],
              )
            : Row(
                children: [
                  Expanded(child: PosSearchField(controller: _searchCtrl, hint: 'Add product to generate barcode', width: double.infinity)),
                  const SizedBox(width: 12),
                  PosButton(label: 'Print', onTap: () {}),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        children: [
          PosTable(
            columns: const ['PRODUCT', 'SKU', 'BARCODE TYPE', 'NO. OF BARCODES', 'PREVIEW'],
            rows: [
              ['Fine Paddy', 'fine', 'C128', '1', _BarcodePlaceholder()],
              ['Tarka 500 gm', 'tarka', 'C128', '1', _BarcodePlaceholder()],
            ],
          ),
        ],
      ),
    );
  }
}

class _BarcodePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.view_week_outlined, size: 30, color: Colors.grey.shade400),
        const Text('12345678', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}
