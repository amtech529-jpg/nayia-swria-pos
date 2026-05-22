import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/purchases/presentation/providers/purchases_provider.dart';

class PurchaseReportScreen extends ConsumerStatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  ConsumerState<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends ConsumerState<PurchaseReportScreen> {
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
    final purchasesState = ref.watch(purchasesProvider);

    return MainLayout(
      currentRoute: '/reports/purchase',
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Reports', 'Purchase Report']),
            const SizedBox(height: 16),
            purchasesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading purchases: $err')),
              data: (purchases) {
                final filtered = purchases.where((p) {
                  final query = _searchQuery.toLowerCase();
                  return (p.refNo ?? '').toLowerCase().contains(query) ||
                         (p.supplierName ?? '').toLowerCase().contains(query);
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
                            const Text('Purchase Report', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const Spacer(),
                            SizedBox(
                              width: isMobile ? 180 : 250,
                              height: 40,
                              child: TextField(
                                controller: _searchCtrl,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search Ref/Supplier',
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
                          child: Center(child: Text('No Purchases Found matching search criteria')),
                        )
                      else
                        PosTable(
                          columns: const ['DATE', 'REF NO', 'SUPPLIER', 'LOCATION', 'PURCHASE STATUS', 'PAYMENT STATUS', 'GRAND TOTAL', 'TOTAL DUE'],
                          rows: filtered.map((p) {
                            final payStatus = p.pendingAmount <= 0 ? 'Paid' : 'Partial';
                            final purStatus = p.pendingAmount <= 0 ? 'Received' : 'Pending';
                            return [
                              p.purchaseDate.split('T')[0],
                              p.refNo ?? p.invoiceNo,
                              p.supplierName,
                              p.location,
                              purStatus,
                              payStatus,
                              'Rs ${p.netTotal.toStringAsFixed(0)}',
                              'Rs ${p.pendingAmount.toStringAsFixed(0)}',
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
