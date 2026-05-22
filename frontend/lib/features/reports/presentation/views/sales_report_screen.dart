import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';

class SalesReportScreen extends ConsumerStatefulWidget {
  const SalesReportScreen({super.key});

  @override
  ConsumerState<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends ConsumerState<SalesReportScreen> {
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
    final salesState = ref.watch(salesListProvider);

    return MainLayout(
      currentRoute: '/reports/sales',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Reports', 'Sales Report']),
            const SizedBox(height: 16),
            salesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading sales: $err')),
              data: (sales) {
                final filtered = sales.where((sale) {
                  final query = _searchQuery.toLowerCase();
                  return sale.invoiceNo.toLowerCase().contains(query) ||
                         (sale.customerName ?? '').toLowerCase().contains(query);
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
                            const Text('Sales Report', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const Spacer(),
                            SizedBox(
                              width: isMobile ? 180 : 250,
                              height: 40,
                              child: TextField(
                                controller: _searchCtrl,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search Invoice/Customer',
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
                          child: Center(child: Text('No Sales Found matching search criteria')),
                        )
                      else
                        PosTable(
                          columns: const ['DATE', 'INVOICE NO', 'CUSTOMER', 'LOCATION', 'PAYMENT STATUS', 'TOTAL AMOUNT', 'TOTAL PAID', 'TOTAL DUE'],
                          rows: filtered.map((s) {
                            final status = s.pendingAmount <= 0 ? 'Paid' : 'Partial';
                            return [
                              s.saleDate.split('T')[0],
                              s.invoiceNo,
                              s.customerName ?? 'Walk In Customer',
                              s.location,
                              status,
                              'Rs ${s.netTotal.toStringAsFixed(0)}',
                              'Rs ${s.paidAmount.toStringAsFixed(0)}',
                              'Rs ${s.pendingAmount.toStringAsFixed(0)}',
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
