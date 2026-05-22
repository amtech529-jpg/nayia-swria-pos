import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';

class StockReportScreen extends ConsumerStatefulWidget {
  const StockReportScreen({super.key});

  @override
  ConsumerState<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends ConsumerState<StockReportScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final productsState = ref.watch(productsListProvider);
    final salesState = ref.watch(salesListProvider);

    return MainLayout(
      currentRoute: '/reports/stock',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Reports', 'Stock Report']),
            const SizedBox(height: 16),
            productsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading products: $err')),
              data: (products) {
                final sales = salesState.value ?? [];
                
                // Map to calculate total sold for each product name
                final Map<String, int> totalSoldMap = {};
                for (var sale in sales) {
                  for (var item in sale.items) {
                    final name = item.productName;
                    totalSoldMap[name] = (totalSoldMap[name] ?? 0) + item.qty;
                  }
                }

                final filtered = products.where((prod) {
                  final query = _searchQuery.toLowerCase();
                  return prod.name.toLowerCase().contains(query) ||
                         (prod.sku ?? '').toLowerCase().contains(query);
                }).toList();

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Text('Stock Report', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const Spacer(),
                            SizedBox(
                              width: isMobile ? 180 : 250,
                              height: 40,
                              child: TextField(
                                controller: _searchCtrl,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search Product/SKU',
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onChanged: (val) => setState(() => _searchQuery = val),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('No Products Found matching search criteria')),
                        )
                      else
                        PosTable(
                          columns: const ['SKU', 'PRODUCT', 'LOCATION', 'UNIT PRICE', 'CURRENT STOCK', 'STOCK VALUE', 'TOTAL SOLD'],
                          rows: filtered.map((prod) {
                            final totalSold = totalSoldMap[prod.name] ?? 0;
                            final stockValue = prod.openingStock * prod.cost;
                            return [
                              prod.sku ?? '-',
                              prod.name,
                              prod.location,
                              'Rs ${prod.price.toStringAsFixed(0)}',
                              '${prod.openingStock.toStringAsFixed(0)} ${prod.saleUnit}',
                              'Rs ${stockValue.toStringAsFixed(0)}',
                              '$totalSold ${prod.saleUnit}',
                            ];
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
