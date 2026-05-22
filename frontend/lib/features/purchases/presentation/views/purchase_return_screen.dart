import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/purchases/presentation/providers/purchase_returns_provider.dart';

class PurchaseReturnScreen extends ConsumerStatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  ConsumerState<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends ConsumerState<PurchaseReturnScreen> {
  final _searchCtrl = TextEditingController();
  final List<String> _columnLabels = [
    '', 'RETURN NO', 'PURCHASE NO', 'DATE', 'TOTAL AMOUNT', 'REASON'
  ];
  List<bool> _visibleColumns = [];

  @override
  void initState() {
    super.initState();
    _visibleColumns = List.generate(_columnLabels.length, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    final returnsAsync = ref.watch(purchaseReturnsProvider);

    return MainLayout(
      currentRoute: '/purchase-return',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Purchase Return']),
            const SizedBox(height: 24),

            // Main Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Column(
                children: [
                  // Toolbar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text('All Purchase Return', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                        const SizedBox(width: 8),
                        returnsAsync.maybeWhen(
                          data: (items) => Text('${items.length} items', style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                          orElse: () => const Text('...', style: TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                        ),
                        const Spacer(),
                        PosButton(label: '+ Add Purchase Return', onTap: () => context.go('/purchase-return/create')),
                        const SizedBox(width: 12),
                        PosSearchField(controller: _searchCtrl, hint: 'Search Return', width: 200, onChanged: (_) => setState(() {})),
                      ],
                    ),
                  ),

                  // Table
                  returnsAsync.when(
                    loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Padding(padding: const EdgeInsets.all(40), child: Text('Error: $e')),
                    data: (returns) {
                      final filtered = returns.where((r) => r.returnNo.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
                      return PosTable(
                        columns: _columnLabels,
                        visibleColumns: _visibleColumns,
                        columnWidths: const [50, 150, 150, 180, 150, 200],
                        rows: filtered.map((r) => [
                          '',
                          Text(r.returnNo, style: const TextStyle(fontSize: 13, color: Color(0xFF22c55e), fontWeight: FontWeight.w600)),
                          Text(r.purchaseId ?? '-', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                          Text(r.returnDate.split('T')[0], style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                          Text('Rs ${r.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          Text(r.reason ?? '-', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                        ]).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _pageNode(String label, {bool active = false}) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: active ? const Color(0xFF0f172a) : Colors.transparent, shape: BoxShape.circle),
      child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : const Color(0xFF64748b), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
    );
  }
}
