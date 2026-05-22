import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/utils/export_service.dart';
import 'package:frontend/features/purchases/presentation/providers/purchases_provider.dart';
import 'package:frontend/features/purchases/presentation/views/purchase_invoice_dialog.dart';
import 'package:frontend/features/purchases/data/models/purchase_model.dart';

class PurchasesScreen extends ConsumerStatefulWidget {
  const PurchasesScreen({super.key});

  @override
  ConsumerState<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends ConsumerState<PurchasesScreen> {
  final _searchCtrl = TextEditingController();
  final List<String> _columnLabels = [
    '', 'INVOICE', 'SUPPLIER', 'BUSINESS LOCATION', 'REFERENCE', 
    'PURCHASE DATE', 'TOTAL AMOUNT', 'TOTAL PAYMENT', 
    'PENDING PAYMENT', 'STATUS', 'PAYMENT STATUS', 'ACTIONS'
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesState = ref.watch(purchasesProvider);

    return MainLayout(
      currentRoute: '/purchases',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Purchases']),
            const SizedBox(height: 24),

            // Main Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: purchasesState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
                  ),
                ),
                data: (purchases) {
                  // Filter by search query
                  final query = _searchCtrl.text.toLowerCase();
                  final filtered = purchases.where((p) {
                    final inv = p.invoiceNo.toLowerCase();
                    final sup = (p.supplierName ?? '').toLowerCase();
                    final refNo = (p.refNo ?? '').toLowerCase();
                    return inv.contains(query) || sup.contains(query) || refNo.contains(query);
                  }).toList();

                  // Calculate total aggregates
                  final totalAmount = filtered.fold<double>(0, (sum, item) => sum + item.netTotal);
                  final totalPaid = filtered.fold<double>(0, (sum, item) => sum + item.paidAmount);
                  final totalPending = filtered.fold<double>(0, (sum, item) => sum + item.pendingAmount);

                  return Column(
                    children: [
                      // Toolbar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Text('All Purchases', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                            const SizedBox(width: 8),
                            Text('${filtered.length} items', style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                            const Spacer(),
                            PosButton(label: '+ Add Purchase', onTap: () => context.go('/purchases/create')),
                            const SizedBox(width: 12),
                            PosSearchField(
                              controller: _searchCtrl, 
                              hint: 'Search Purchases', 
                              width: 200, 
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.view_column_outlined, color: Color(0xFF64748b), size: 20),
                            const SizedBox(width: 12),
                            const Icon(Icons.filter_alt_outlined, color: Color(0xFF64748b), size: 20),
                            const SizedBox(width: 12),
                            _exportMenu(filtered),
                          ],
                        ),
                      ),

                      // Table
                      if (filtered.isEmpty)
                        _buildEmptyState('No Purchases Found', 'Add purchases to see them in this list.')
                      else
                        PosTable(
                          columns: _columnLabels,
                          columnWidths: const [50, 120, 180, 100, 120, 180, 120, 120, 120, 100, 100, 60],
                          rows: [
                            ...filtered.map((r) => [
                              '',
                              InkWell(
                                onTap: () => _showInvoice(context, r),
                                child: Text(r.invoiceNo, style: const TextStyle(fontSize: 13, color: Color(0xFF22c55e), fontWeight: FontWeight.w600)),
                              ),
                              Text(r.supplierName ?? 'Supplier', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                              _badge(r.location, isBlue: true),
                              Text(r.refNo ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                              Text(r.purchaseDate.split('T')[0], style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                              Text('Rs ${r.netTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                              Text('Rs ${r.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                              Text('Rs ${r.pendingAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                              _statusBadge(r.pendingAmount <= 0 ? 'Received' : 'Pending'),
                              _statusBadge(r.pendingAmount <= 0 ? 'Paid' : (r.paidAmount > 0 ? 'Partial' : 'Due'), isDue: r.pendingAmount > 0 && r.paidAmount == 0),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748b)),
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.visibility, size: 16), SizedBox(width: 8), Text('View Invoice')])),
                                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit Purchase')])),
                                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 16), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                ],
                                onSelected: (val) async {
                                  if (val == 'view') {
                                    _showInvoice(context, r);
                                  } else if (val == 'edit') {
                                    context.go('/purchases/edit/${r.id}', extra: r);
                                  } else if (val == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Purchase'),
                                        content: Text('Are you sure you want to delete invoice ${r.invoiceNo}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref.read(purchasesProvider.notifier).deletePurchase(r.id);
                                    }
                                  }
                                },
                              ),
                            ]),
                            // Totals Row
                            [
                              '',
                              const SizedBox(),
                              const SizedBox(),
                              const SizedBox(),
                              const SizedBox(),
                              const Align(alignment: Alignment.centerRight, child: Text('total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                              Text('Rs ${totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Rs ${totalPaid.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Rs ${totalPending.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(),
                              const SizedBox(),
                              const SizedBox(),
                            ]
                          ],
                        ),

                      // Footer
                      _buildFooter(filtered.length),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoice(BuildContext context, PurchaseModel p) {
    showDialog(
      context: context,
      builder: (ctx) => PurchaseInvoiceDialog(purchase: p),
    );
  }

  Widget _badge(String label, {bool isBlue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isBlue ? const Color(0xFFeff6ff) : const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: isBlue ? const Color(0xFF2563eb) : const Color(0xFF64748b), fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusBadge(String status, {bool isDue = false}) {
    Color bg = const Color(0xFFf0fdf4);
    Color fg = const Color(0xFF22c55e);
    if (isDue) {
      bg = const Color(0xFFfef2f2);
      fg = const Color(0xFFef4444);
    } else if (status == 'Pending' || status == 'Partial') {
      bg = const Color(0xFFfffbeb);
      fg = const Color(0xFFf59e0b);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptyState(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: Color(0xFF94a3b8)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(int total) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4)),
            child: const Row(children: [Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Icon(Icons.keyboard_arrow_down, size: 14)]),
          ),
          const SizedBox(width: 12),
          Text('SHOWING 1-10 OF $total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94a3b8))),
          const Spacer(),
          _pageNode('«'),
          _pageNode('‹'),
          _pageNode('1', active: true),
          _pageNode('2'),
          _pageNode('3'),
          const Text('...', style: TextStyle(color: Color(0xFF64748b))),
          _pageNode('›'),
          _pageNode('»'),
        ],
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

  Widget _exportMenu(List<PurchaseModel> data) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      icon: const Icon(Icons.more_vert, color: Color(0xFF64748b)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.file_copy, size: 16), SizedBox(width: 8), Text('Export to Excel')])),
        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, size: 16), SizedBox(width: 8), Text('Export to PDF')])),
        const PopupMenuItem(value: 'print', child: Row(children: [Icon(Icons.print, size: 16), SizedBox(width: 8), Text('Print Table')])),
      ],
      onSelected: (val) async {
        final headers = ['INVOICE', 'SUPPLIER', 'LOCATION', 'REFERENCE', 'DATE', 'TOTAL', 'PAID', 'PENDING'];
        final rows = data.map((r) => [
          r.invoiceNo, r.supplierName ?? '', r.location, r.refNo ?? '', r.purchaseDate.split('T')[0], r.netTotal.toString(), r.paidAmount.toString(), r.pendingAmount.toString()
        ]).toList();

        if (val == 'excel') {
          await ExportService.exportToCsv('Purchases_Report', [headers, ...rows]);
        } else if (val == 'pdf') {
          await ExportService.exportToPdf('Purchases_Report', headers, rows);
        } else if (val == 'print') {
          await ExportService.printTable('Purchases_Report', headers, rows);
        }
      },
    );
  }
}
