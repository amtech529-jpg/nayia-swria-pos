import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/core/utils/export_service.dart';
import 'package:frontend/features/pos/presentation/views/invoice_dialog.dart';
import 'package:frontend/features/pos/presentation/views/stock_slip_dialog.dart';
import 'package:frontend/features/pos/presentation/views/add_payment_dialog.dart';
import 'package:go_router/go_router.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;



  final List<String> _columnLabels = [
    '', 'INVOICE NO', 'STOCK SLIP', 'CUSTOMER', 'BUSINESS LOCATION', 'REFERENCE', 'SALE DATE', 'TOTAL AMOUNT', 'NET AMOUNT', 'TOTAL PAYMENT', 'PENDING PAYMENT', 'ACTIONS'
  ];
  late List<bool> _visibleColumns;

  @override
  void initState() {
    super.initState();
    _visibleColumns = List.generate(_columnLabels.length, (index) => true);
  }



  @override
  Widget build(BuildContext context) {
    if (_visibleColumns.length != _columnLabels.length) {
      _visibleColumns = List.generate(_columnLabels.length, (index) => true);
    }
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 800;

    return MainLayout(
      currentRoute: '/sales',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Sales']),
            const SizedBox(height: 16),
            if (_showFilters) _buildAdvancedFilters(),
            const SizedBox(height: 16),
            _buildTableCard(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: Row(
        children: [
          Expanded(child: _filterDrop('Location', ['All', 'Default', 'Warehouse A'])),
          const SizedBox(width: 16),
          Expanded(child: _filterDrop('Status', ['All', 'Final', 'Draft'])),
          const SizedBox(width: 16),
          Expanded(child: _filterDrop('Payment', ['All', 'Paid', 'Due'])),
          const SizedBox(width: 16),
          PosButton(label: 'Apply Filters', onTap: () {}),
        ],
      ),
    );
  }

  Widget _filterDrop(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748b))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFe2e8f0))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.first,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1e293b)),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('All Sales', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0f172a))),
                    const SizedBox(width: 8),
                    ref.watch(salesListProvider).maybeWhen(
                      data: (sales) => Text('${sales.length} items', style: const TextStyle(color: Color(0xFF64748b), fontSize: 13)),
                      orElse: () => const Text('0 items', style: TextStyle(color: Color(0xFF64748b), fontSize: 13)),
                    ),
                    const Spacer(),
                    PosButton(label: '+ Add Sale', icon: Icons.add, onTap: () => context.go('/pos')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    PosSearchField(controller: _searchCtrl, hint: 'Search Sales', onChanged: (_) => setState(() {})),
                    const SizedBox(width: 12),
                    _columnMenu(),
                    const SizedBox(width: 12),
                    _ToolIcon(icon: Icons.filter_alt_outlined, onTap: () => setState(() => _showFilters = !_showFilters), active: _showFilters),
                    const Spacer(),
                    _exportMenu(),
                  ],
                ),
              ],
            ),
          ),
          ref.watch(salesListProvider).when(
            loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Padding(padding: const EdgeInsets.all(24), child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            data: (sales) {
              final sortedSales = sales.reversed.toList();
              final filtered = sortedSales.where((s) => s.invoiceNo.toLowerCase().contains(_searchCtrl.text.toLowerCase()) || (s.customerName ?? '').toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
              return PosTable(
                columns: _columnLabels,
                columnWidths: const [50, 140, 100, 220, 150, 120, 180, 120, 120, 120, 120, 60],
                visibleColumns: _visibleColumns,
                rows: filtered.map((s) => [
                  '',
                  // INVOICE NO cell — clean clickable link only
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => InvoiceDialog(sale: s),
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        s.invoiceNo,
                        style: const TextStyle(
                          color: Color(0xFF10b981),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF10b981),
                        ),
                      ),
                    ),
                  ),
                  // STOCK SLIP cell — dedicated button
                  Tooltip(
                    message: 'View Stock Movement Slip',
                    child: GestureDetector(
                      onTap: () {
                        final products = ref.read(productsListProvider).value ?? [];
                        showDialog(
                          context: context,
                          builder: (_) => StockSlipDialog(sale: s, products: products),
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf3e8ff),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFd8b4fe)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 13, color: Color(0xFF6d28d9)),
                              SizedBox(width: 4),
                              Text('Slip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6d28d9))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // CUSTOMER cell
                  Text(s.customerName ?? 'Walk In Customer', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(20)),
                    child: Text(s.location, style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                  ),
                  Text(s.refNo ?? '-', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                  Text(s.saleDate.split('T')[0], style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                  Text('Rs ${s.netTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                  Text('Rs ${s.netTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0f172a))),
                  Text('Rs ${s.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10b981))),
                  Text('Rs ${s.pendingAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red)),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748b)),
                    onSelected: (value) async {
                      if (value == 'view') {
                        showDialog(
                          context: context,
                          builder: (_) => InvoiceDialog(sale: s),
                        );
                      } else if (value == 'stock_slip') {
                        final products = ref.read(productsListProvider).value ?? [];
                        showDialog(
                          context: context,
                          builder: (_) => StockSlipDialog(sale: s, products: products),
                        );
                      } else if (value == 'payment') {
                        showDialog(
                          context: context,
                          builder: (_) => AddPaymentDialog(sale: s),
                        );
                      } else if (value == 'edit') {
                        context.go('/pos', extra: s);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Sale'),
                            content: Text('Are you sure you want to delete invoice "${s.invoiceNo}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                           await ref.read(salesListProvider.notifier).removeSale(s.id);
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.receipt_long, size: 16, color: Color(0xFF10b981)), SizedBox(width: 8), Text('View Invoice')])),
                      const PopupMenuItem(value: 'stock_slip', child: Row(children: [Icon(Icons.inventory_2_outlined, size: 16, color: Color(0xFF6d28d9)), SizedBox(width: 8), Text('Stock Movement Slip')])),
                      const PopupMenuDivider(),
                      if (s.pendingAmount > 0)
                        const PopupMenuItem(value: 'payment', child: Row(children: [Icon(Icons.payment, size: 16, color: Color(0xFF2563eb)), SizedBox(width: 8), Text('Add Payment')])),
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16, color: Colors.orange), SizedBox(width: 8), Text('Edit Sale')])),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ]).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _columnMenu() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 45),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(6)),
        child: const Row(
          children: [
            Icon(Icons.view_column, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text('Columns', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (_) => List.generate(_columnLabels.length, (i) {
        if (_columnLabels[i].isEmpty) return const PopupMenuDivider() as PopupMenuEntry<int>;
        return CheckedPopupMenuItem(
          value: i,
          checked: _visibleColumns[i],
          child: Text(_columnLabels[i], style: const TextStyle(fontSize: 13)),
        );
      }),
      onSelected: (i) => setState(() => _visibleColumns[i] = !_visibleColumns[i]),
    );
  }

  Widget _exportMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      icon: const Icon(Icons.more_vert, color: Color(0xFF64748b)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.file_copy, size: 16), SizedBox(width: 8), Text('Export to Excel')])),
        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, size: 16), SizedBox(width: 8), Text('Export to PDF')])),
        const PopupMenuItem(value: 'print', child: Row(children: [Icon(Icons.print, size: 16), SizedBox(width: 8), Text('Print Table')])),
      ],
      onSelected: (val) async {
        final state = ref.read(salesListProvider);
        if (!state.hasValue || state.value == null) return;
        
        final sales = state.value!;
        final filtered = sales.where((s) => s.invoiceNo.toLowerCase().contains(_searchCtrl.text.toLowerCase()) || (s.customerName ?? '').toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
        
        final headers = ['INVOICE NO', 'CUSTOMER', 'LOCATION', 'SALE DATE', 'NET AMOUNT', 'PAID', 'PENDING'];
        final rows = filtered.map((s) => [
          s.invoiceNo,
          s.customerName ?? 'Walk In',
          s.location,
          s.saleDate.split('T')[0],
          s.netTotal.toStringAsFixed(2),
          s.paidAmount.toStringAsFixed(2),
          s.pendingAmount.toStringAsFixed(2),
        ]).toList();

        if (val == 'excel') {
          final csvData = [headers, ...rows];
          await ExportService.exportToCsv('Sales_Report', csvData);
        } else if (val == 'pdf') {
          await ExportService.exportToPdf('Sales_Report', headers, rows);
        } else if (val == 'print') {
          await ExportService.printTable('Sales_Report', headers, rows);
        }
      },
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _ToolIcon({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: active ? const Color(0xFF0f172a).withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 20, color: active ? const Color(0xFF0f172a) : const Color(0xFF64748b)),
      ),
    );
  }
}
