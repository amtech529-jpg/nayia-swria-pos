import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class BusinessSettingsScreen extends StatelessWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return MainLayout(
      currentRoute: '/settings/business',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Settings', 'Business Settings']),
            const SizedBox(height: 16),
            _buildSettingsCard('Business Details', [
              _buildTextField('Business Name', 'Nayia Swaria'),
              _buildTextField('Start Date', '2026-01-01'),
              _buildTextField('Currency', 'PKR (Rs)'),
            ], isMobile),
            const SizedBox(height: 16),
            _buildSettingsCard('Tax Settings', [
              _buildTextField('Tax Name', 'GST'),
              _buildTextField('Tax Number', '1234567-8'),
            ], isMobile),
            const SizedBox(height: 24),
            Center(child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBtn, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
              child: const Text('Update Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, List<Widget> children, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 16),
          isMobile 
            ? Column(children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList())
            : Wrap(spacing: 20, runSpacing: 16, children: children.map((w) => SizedBox(width: 280, child: w)).toList()),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.tableSubText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
          ),
        ),
      ],
    );
  }
}
