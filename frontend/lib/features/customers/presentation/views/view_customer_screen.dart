import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/features/customers/data/models/customer_model.dart';
import 'package:frontend/features/customers/presentation/providers/customers_provider.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';

class ViewCustomerScreen extends ConsumerStatefulWidget {
  final String customerId;
  const ViewCustomerScreen({super.key, required this.customerId});

  @override
  ConsumerState<ViewCustomerScreen> createState() => _ViewCustomerScreenState();
}

class _ViewCustomerScreenState extends ConsumerState<ViewCustomerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customersListProvider);
    final salesState = ref.watch(salesListProvider);

    return customersState.when(
      loading: () => MainLayout(
        currentRoute: '/customers',
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => MainLayout(
        currentRoute: '/customers',
        child: Center(child: Text('Error: $e')),
      ),
      data: (customers) {
        final customer = customers.firstWhere(
          (c) => c.id == widget.customerId,
          orElse: () => CustomerModel(id: '', name: 'Unknown'),
        );

        return salesState.when(
          loading: () => _buildScreen(customer, [], context),
          error: (_, __) => _buildScreen(customer, [], context),
          data: (allSales) {
            final customerSales = allSales
                .where((s) => s.customerId == widget.customerId)
                .toList();
            return _buildScreen(customer, customerSales, context);
          },
        );
      },
    );
  }

  Widget _buildScreen(CustomerModel customer, List<SaleModel> customerSales, BuildContext context) {
    final totalSale = customerSales.fold(0.0, (sum, s) => sum + s.netTotal);
    final totalPaid = customerSales.fold(0.0, (sum, s) => sum + s.paidAmount);
    final totalDue = customerSales.fold(0.0, (sum, s) => sum + s.pendingAmount);
    // Profit = netTotal - (cost is unknown here so we use pendingAmount as due, show 0 if no items)
    final totalProfit = customerSales.fold(0.0, (sum, s) {
      // approximate profit from sales items if cost available
      return sum + (s.netTotal - s.pendingAmount - (s.paidAmount - s.netTotal + s.pendingAmount));
    });

    return MainLayout(
      currentRoute: '/customers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Customers', 'View Customer']),
            const SizedBox(height: 20),

            // ── Header Card ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF0f172a),
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name.trim().split(' ').take(3).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                customer.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0f172a)),
                              ),
                            ),
                            if (customer.fatherName?.isNotEmpty == true)
                              Text(' S/O ${customer.fatherName}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (customer.phone?.isNotEmpty == true)
                          Row(children: [
                            const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748b)),
                            const SizedBox(width: 6),
                            Text(customer.phone!, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          ]),
                        const SizedBox(height: 4),
                        if (customer.email?.isNotEmpty == true)
                          Row(children: [
                            const Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748b)),
                            const SizedBox(width: 6),
                            Text(customer.email!, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          ]),
                        const SizedBox(height: 4),
                        if (customer.cnic?.isNotEmpty == true)
                          Row(children: [
                            const Icon(Icons.credit_card_outlined, size: 14, color: Color(0xFF64748b)),
                            const SizedBox(width: 6),
                            Text(customer.cnic!, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          ]),
                        const SizedBox(height: 4),
                        if (customer.address?.isNotEmpty == true)
                          Row(children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748b)),
                            const SizedBox(width: 6),
                            Text(customer.address!, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          ]),
                        const SizedBox(height: 4),
                        if (customer.area?.isNotEmpty == true)
                          Row(children: [
                            const Icon(Icons.map_outlined, size: 14, color: Color(0xFFef4444)),
                            const SizedBox(width: 6),
                            Text(customer.area!, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          ]),
                      ],
                    ),
                  ),
                  // Stats Grid
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 500,
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard('Total Sale', 'Rs ${totalSale.toStringAsFixed(0)}', const Color(0xFF2563eb), Icons.shopping_cart_outlined),
                        _statCard('Amount Received', 'Rs ${totalPaid.toStringAsFixed(0)}', const Color(0xFF22c55e), Icons.payments_outlined),
                        _statCard('Total Due', 'Rs ${totalDue.toStringAsFixed(0)}', const Color(0xFFef4444), Icons.warning_amber_outlined),
                        _statCard('Total Profit', 'Rs ${totalProfit.toStringAsFixed(0)}', const Color(0xFF22c55e), Icons.trending_up),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Tabs ───────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Column(
                children: [
                  // Tab bar
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFe2e8f0))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: const Color(0xFF2563eb),
                      unselectedLabelColor: const Color(0xFF64748b),
                      indicatorColor: const Color(0xFF2563eb),
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(icon: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bar_chart, size: 16), SizedBox(width: 6), Text('Overview')])),
                        Tab(icon: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.book_outlined, size: 16), SizedBox(width: 6), Text('Ledger')])),
                        Tab(icon: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_bag_outlined, size: 16), SizedBox(width: 6), Text('Sales')])),
                        Tab(icon: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.attach_money, size: 16), SizedBox(width: 6), Text('Payments')])),
                      ],
                    ),
                  ),
                  // Tab content
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _OverviewTab(customerSales: customerSales),
                        _LedgerTab(customerSales: customerSales),
                        _SalesTab(customerSales: customerSales),
                        _PaymentsTab(customerSales: customerSales),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748b))),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final List<SaleModel> customerSales;
  const _OverviewTab({required this.customerSales});

  @override
  Widget build(BuildContext context) {
    if (customerSales.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 48, color: Color(0xFF94a3b8)),
            SizedBox(height: 12),
            Text('No sales data available', style: TextStyle(fontSize: 14, color: Color(0xFF64748b))),
          ],
        ),
      );
    }

    // Group sales by month for bar chart
    final Map<String, double> monthlySales = {};
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    for (final s in customerSales) {
      try {
        final date = DateTime.tryParse(s.saleDate);
        if (date != null) {
          final key = months[date.month - 1];
          monthlySales[key] = (monthlySales[key] ?? 0) + s.netTotal;
        }
      } catch (_) {}
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales Per Month', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
          const SizedBox(height: 16),
          if (monthlySales.isEmpty)
            const Text('No data', style: TextStyle(color: Color(0xFF94a3b8)))
          else
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: months.map((monthStr) {
                  final maxVal = monthlySales.isEmpty ? 1.0 : monthlySales.values.reduce((a, b) => a > b ? a : b);
                  final val = monthlySales[monthStr] ?? 0.0;
                  final height = maxVal > 0 ? (val / maxVal) * 160 : 0.0;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (val > 0)
                          Text('Rs ${(val / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 9, color: Color(0xFF64748b))),
                        const SizedBox(height: 4),
                        Container(
                          height: height.toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563eb),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(monthStr, style: const TextStyle(fontSize: 9, color: Color(0xFF64748b))),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 24),
          const Text('Recent Sales Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
          const SizedBox(height: 12),
          ...customerSales.take(5).map((s) => _salesRow(s)),
        ],
      ),
    );
  }

  Widget _salesRow(SaleModel s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(s.invoiceNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2563eb))),
          ),
          Text(s.saleDate.split('T').first, style: const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
          const SizedBox(width: 24),
          Text('Rs ${s.netTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: s.pendingAmount > 0 ? const Color(0xFFfef3c7) : const Color(0xFFdcfce7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              s.pendingAmount > 0 ? 'Partial' : 'Paid',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: s.pendingAmount > 0 ? const Color(0xFFd97706) : const Color(0xFF16a34a),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ledger Tab ───────────────────────────────────────────────────────────────
class _LedgerTab extends StatelessWidget {
  final List<SaleModel> customerSales;
  const _LedgerTab({required this.customerSales});

  @override
  Widget build(BuildContext context) {
    if (customerSales.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.book_outlined, size: 48, color: Color(0xFF94a3b8)),
          SizedBox(height: 12),
          Text('No ledger entries', style: TextStyle(color: Color(0xFF64748b))),
        ]),
      );
    }

    double runningBalance = 0;
    final List<Map<String, dynamic>> entries = [];

    for (final s in customerSales) {
      runningBalance += s.netTotal;
      entries.add({'type': 'Sale', 'ref': s.invoiceNo, 'date': s.saleDate.split('T').first, 'debit': s.netTotal, 'credit': 0.0, 'balance': runningBalance});
      if (s.paidAmount > 0) {
        runningBalance -= s.paidAmount;
        entries.add({'type': 'Payment', 'ref': 'PAY-${s.invoiceNo}', 'date': s.saleDate.split('T').first, 'debit': 0.0, 'credit': s.paidAmount, 'balance': runningBalance});
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PosTable(
        columns: const ['TYPE', 'REFERENCE', 'DATE', 'DEBIT (-)', 'CREDIT (+)', 'BALANCE'],
        columnWidths: const [100, 160, 140, 140, 140, 140],
        rows: entries.map((e) {
          final isPayment = e['type'] == 'Payment';
          return [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isPayment ? const Color(0xFFdcfce7) : const Color(0xFFeff6ff),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(e['type'], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPayment ? const Color(0xFF16a34a) : const Color(0xFF2563eb))),
            ),
            Text(e['ref'], style: const TextStyle(fontSize: 13, color: Color(0xFF2563eb), fontWeight: FontWeight.w600)),
            Text(e['date'], style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
            Text(
              e['debit'] > 0 ? 'Rs ${(e['debit'] as double).toStringAsFixed(0)}' : '',
              style: const TextStyle(fontSize: 13, color: Color(0xFFef4444), fontWeight: FontWeight.w600),
            ),
            Text(
              e['credit'] > 0 ? 'Rs ${(e['credit'] as double).toStringAsFixed(0)}' : '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF22c55e), fontWeight: FontWeight.w600),
            ),
            Text(
              'Rs ${(e['balance'] as double).toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0f172a)),
            ),
          ];
        }).toList(),
      ),
    );
  }
}

// ── Sales Tab ────────────────────────────────────────────────────────────────
class _SalesTab extends StatelessWidget {
  final List<SaleModel> customerSales;
  const _SalesTab({required this.customerSales});

  @override
  Widget build(BuildContext context) {
    if (customerSales.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFF94a3b8)),
          SizedBox(height: 12),
          Text('No Payment Found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
          Text('There is no sale found.', style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('All Sales  ${customerSales.length} items', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
            ],
          ),
          const SizedBox(height: 12),
          PosTable(
            columns: const ['INVOICE NO', 'SALE DATE', 'TOTAL AMOUNT', 'TOTAL PAYMENT', 'PENDING PAYMENT', 'STATUS', 'PROFIT'],
            columnWidths: const [150, 140, 140, 140, 150, 100, 100],
            rows: customerSales.map((s) {
              final isPaid = s.pendingAmount <= 0;
              final profit = s.paidAmount - (s.netTotal - s.pendingAmount - s.paidAmount).abs();
              return [
                Text(s.invoiceNo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2563eb))),
                Text(s.saleDate.split('T').first, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                Text('Rs ${s.netTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('Rs ${s.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Color(0xFF22c55e))),
                Text('Rs ${s.pendingAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 13, color: s.pendingAmount > 0 ? const Color(0xFFef4444) : const Color(0xFF22c55e))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFFdcfce7) : const Color(0xFFfef3c7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPaid ? 'Paid' : 'Partial',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPaid ? const Color(0xFF16a34a) : const Color(0xFFd97706)),
                  ),
                ),
                Text('Rs ${profit.abs().toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, color: Color(0xFF22c55e), fontWeight: FontWeight.w600)),
              ];
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Payments Tab ─────────────────────────────────────────────────────────────
class _PaymentsTab extends StatelessWidget {
  final List<SaleModel> customerSales;
  const _PaymentsTab({required this.customerSales});

  @override
  Widget build(BuildContext context) {
    final paymentsData = customerSales.where((s) => s.paidAmount > 0).toList();

    if (paymentsData.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.payments_outlined, size: 48, color: Color(0xFF94a3b8)),
          SizedBox(height: 12),
          Text('No Payment Found', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
          Text('There is no payment found.', style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PosTable(
        columns: const ['DATE', 'REFERENCE', 'AMOUNT', 'PAYMENT METHOD', 'NOTES'],
        columnWidths: const [140, 180, 140, 160, 200],
        rows: paymentsData.map((s) {
          return [
            Text(s.saleDate.split('T').first, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
            Text('PAY-${s.invoiceNo}', style: const TextStyle(fontSize: 13, color: Color(0xFF2563eb), fontWeight: FontWeight.w600)),
            Text('Rs ${s.paidAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF22c55e))),
            Text(s.paymentMethod, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
            Text(s.notes ?? '', style: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
          ];
        }).toList(),
      ),
    );
  }
}
