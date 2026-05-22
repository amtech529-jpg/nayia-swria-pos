import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';
import 'package:frontend/features/purchases/presentation/providers/purchases_provider.dart';

class ProfitLossReportScreen extends ConsumerWidget {
  const ProfitLossReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final productsState = ref.watch(productsListProvider);
    final salesState = ref.watch(salesListProvider);
    final purchasesState = ref.watch(purchasesProvider);

    final isLoading = productsState.isLoading || salesState.isLoading || purchasesState.isLoading;
    final hasError = productsState.hasError || salesState.hasError || purchasesState.hasError;

    if (isLoading) {
      return const MainLayout(
        currentRoute: '/reports/profit-loss',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return const MainLayout(
        currentRoute: '/reports/profit-loss',
        child: Center(child: Text('Error loading report data.')),
      );
    }

    final products = productsState.value ?? [];
    final sales = salesState.value ?? [];
    final purchases = purchasesState.value ?? [];

    // 1. Calculate Opening Stock Value
    double openingStockValue = 0.0;
    for (var prod in products) {
      openingStockValue += prod.openingStock * prod.cost;
    }

    // 2. Calculate Total Purchase Value
    double totalPurchaseValue = 0.0;
    for (var p in purchases) {
      totalPurchaseValue += p.netTotal;
    }

    // 3. Calculate Total Sale Value
    double totalSaleValue = 0.0;
    for (var s in sales) {
      totalSaleValue += s.netTotal;
    }

    // 4. Calculate Gross Profit based on cost-of-goods-sold
    double grossProfit = 0.0;
    for (var sale in sales) {
      for (var item in sale.items) {
        // Find matching product cost
        final matchingProd = products.where((p) => p.name == item.productName);
        final cost = matchingProd.isNotEmpty ? matchingProd.first.cost : 0.0;
        final profit = item.qty * (item.price - cost);
        grossProfit += profit;
      }
    }

    // 5. Total Expense (can show 0 or shipping/labour from bills)
    double totalExpenses = 0.0;

    // 6. Net Profit
    double netProfit = grossProfit - totalExpenses;

    return MainLayout(
      currentRoute: '/reports/profit-loss',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Reports', 'Profit & Loss']),
            const SizedBox(height: 16),
            
            // Stats Grid
            GridView.count(
              crossAxisCount: isMobile ? 1 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 3 : 2.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ReportStatCard(title: 'Opening Stock Value', value: 'Rs ${openingStockValue.toStringAsFixed(0)}', color: AppColors.amountBlue),
                _ReportStatCard(title: 'Total Purchase', value: 'Rs ${totalPurchaseValue.toStringAsFixed(0)}', color: AppColors.amountBlue),
                _ReportStatCard(title: 'Total Sale', value: 'Rs ${totalSaleValue.toStringAsFixed(0)}', color: AppColors.amountGreen),
                _ReportStatCard(title: 'Total Expense', value: 'Rs ${totalExpenses.toStringAsFixed(0)}', color: AppColors.amountRed),
                _ReportStatCard(title: 'Gross Profit', value: 'Rs ${grossProfit.toStringAsFixed(0)}', color: AppColors.amountGreen),
                _ReportStatCard(title: 'Net Profit', value: 'Rs ${netProfit.toStringAsFixed(0)}', color: AppColors.amountGreen),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Location Table
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Profit by Business Locations', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  PosTable(
                    columns: const ['LOCATION', 'GROSS PROFIT', 'TOTAL EXPENSE', 'NET PROFIT'],
                    rows: [
                      ['Default Location', 'Rs ${grossProfit.toStringAsFixed(0)}', 'Rs ${totalExpenses.toStringAsFixed(0)}', 'Rs ${netProfit.toStringAsFixed(0)}'],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _ReportStatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, color: AppColors.tableSubText)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
