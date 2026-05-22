import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/features/home/presentation/widgets/payment_method_cards.dart';
import 'package:frontend/features/home/presentation/widgets/pos_stats_chart.dart';
import 'package:frontend/features/home/presentation/widgets/expenses_chart.dart';
import 'package:frontend/features/home/presentation/widgets/stock_alerts_section.dart';
import 'package:frontend/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      currentRoute: '/dashboard',
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends ConsumerStatefulWidget {
  const _DashboardContent();
  @override
  ConsumerState<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<_DashboardContent> {
  String _selectedPeriod = 'Today';
  String _selectedLocation = 'All Locations';

  final List<String> _periods = ['Today', 'This Week', 'This Month', 'This Year', 'All Time'];
  final List<String> _locations = ['All Locations', 'Default', 'Warehouse A'];

  bool _isSaleInPeriod(SaleModel sale) {
    try {
      final saleDate = DateTime.parse(sale.saleDate);
      final now = DateTime.now();
      switch (_selectedPeriod) {
        case 'Today':
          return saleDate.year == now.year &&
                 saleDate.month == now.month &&
                 saleDate.day == now.day;
        case 'This Week':
          final difference = now.difference(saleDate).inDays;
          return difference >= 0 && difference <= 7;
        case 'This Month':
          return saleDate.year == now.year &&
                 saleDate.month == now.month;
        case 'This Year':
          return saleDate.year == now.year;
        case 'All Time':
        default:
          return true;
      }
    } catch (e) {
      return true;
    }
  }

  bool _isSaleInLocation(SaleModel sale) {
    if (_selectedLocation == 'All Locations') return true;
    return sale.location.toLowerCase() == _selectedLocation.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 600;

    final statsQuery = '?period=$_selectedPeriod&location=$_selectedLocation';
    final statsState = ref.watch(dashboardStatsProvider(statsQuery));

    return statsState.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Error loading stats: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (stats) {
        final double totalSale = (stats['total_sales'] ?? 0.0).toDouble();
        final double totalSaleDue = (stats['total_sales_due'] ?? 0.0).toDouble();
        final double paymentReceived = (stats['sales_received'] ?? 0.0).toDouble();
        final double totalDiscount = (stats['total_discount'] ?? 0.0).toDouble();
        final double totalPurchase = (stats['total_purchases'] ?? 0.0).toDouble();
        final double totalPurchaseDue = (stats['total_purchases_due'] ?? 0.0).toDouble();
        final double purchasePayment = (stats['purchases_paid'] ?? 0.0).toDouble();
        final double totalSaleReturn = (stats['total_sale_returns'] ?? 0.0).toDouble();
        final double totalPurchaseReturn = (stats['total_purchase_returns'] ?? 0.0).toDouble();
        final double grossProfit = (stats['gross_profit'] ?? 0.0).toDouble();
        final double netProfit = (stats['net_profit'] ?? 0.0).toDouble();
        const double staticExpense = 0.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ───────────────────────────────
              isMobile
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.tableText)),
                      const SizedBox(height: 12),
                      _buildFilters(isMobile),
                    ])
                  : Row(children: [
                      const Text('Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.tableText)),
                      const Spacer(),
                      _buildFilters(isMobile),
                    ]),
              const SizedBox(height: 20),

              // ─── Stats Cards ──────────────────────────
              GridView.count(
                crossAxisCount: isMobile ? 1 : (sw < 1100 ? 2 : 4),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isMobile ? 2.8 : 2.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(title: 'Total Purchase', value: 'Rs ${totalPurchase.toStringAsFixed(0)}', icon: Icons.shopping_bag_outlined, iconColor: AppColors.iconCircleBlue, valueColor: AppColors.amountBlue),
                  _StatCard(title: 'Total Purchase Return', value: 'Rs ${totalPurchaseReturn.toStringAsFixed(0)}', icon: Icons.assignment_return_outlined, iconColor: AppColors.iconCircleBlue, valueColor: AppColors.amountBlue),
                  _StatCard(title: 'Purchase Payment', value: 'Rs ${purchasePayment.toStringAsFixed(0)}', icon: Icons.payment_outlined, iconColor: AppColors.iconCircleGreen, valueColor: AppColors.amountGreen),
                  _StatCard(title: 'Total Sale', value: 'Rs ${totalSale.toStringAsFixed(1)}', icon: Icons.point_of_sale_outlined, iconColor: AppColors.iconCircleBlue, valueColor: AppColors.amountBlue),
                  _StatCard(title: 'Total Sale Return', value: 'Rs ${totalSaleReturn.toStringAsFixed(0)}', icon: Icons.keyboard_return_outlined, iconColor: AppColors.iconCircleBlue, valueColor: AppColors.amountBlue),
                  _StatCard(title: 'Total Expense', value: 'Rs ${staticExpense.toStringAsFixed(0)}', icon: Icons.receipt_long_outlined, iconColor: AppColors.iconCircleRed, valueColor: AppColors.amountRed),
                  _StatCard(title: 'Gross Profit', subtitle: 'Sale - Product Cost', value: 'Rs ${grossProfit.toStringAsFixed(1)}', icon: Icons.trending_up, iconColor: AppColors.iconCircleGreen, valueColor: AppColors.amountGreen),
                  _StatCard(title: 'Net Profit', subtitle: 'Gross Profit - Expenses', value: 'Rs ${netProfit.toStringAsFixed(1)}', icon: Icons.account_balance_wallet_outlined, iconColor: AppColors.iconCircleGreen, valueColor: AppColors.amountGreen),
                  _StatCard(title: 'Payment Received', value: 'Rs ${paymentReceived.toStringAsFixed(1)}', icon: Icons.attach_money, iconColor: AppColors.iconCircleGreen, valueColor: AppColors.amountGreen),
                  _StatCard(title: 'Total Purchase Due', value: 'Rs ${totalPurchaseDue.toStringAsFixed(0)}', icon: Icons.pending_actions_outlined, iconColor: AppColors.iconCircleRed, valueColor: AppColors.amountRed),
                  _StatCard(title: 'Total Sale Due', value: 'Rs ${totalSaleDue.toStringAsFixed(1)}', icon: Icons.hourglass_empty_outlined, iconColor: AppColors.iconCircleRed, valueColor: AppColors.amountRed),
                  _StatCard(title: 'Opening Balance Dues', value: 'Rs 0', icon: Icons.account_balance_outlined, iconColor: AppColors.iconCircleRed, valueColor: AppColors.amountRed),
                  _StatCard(title: 'Total Discount', value: 'Rs ${totalDiscount.toStringAsFixed(1)}', icon: Icons.local_offer_outlined, iconColor: AppColors.iconCircleRed, valueColor: AppColors.amountRed),
                ],
              ),
              const SizedBox(height: 28),

              // ─── Payment Method Cards ─────────────────
              const PaymentMethodCards(),
              const SizedBox(height: 28),

              // ─── POS Stats Chart ──────────────────────
              const PosStatsChart(),
              const SizedBox(height: 20),

              // ─── Expenses Chart ───────────────────────
              const ExpensesChart(),
              const SizedBox(height: 20),

              // ─── Stock Alerts ─────────────────────────
              const StockAlertsSection(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilters(bool isMobile) {
    return Row(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      children: [
        _FilterDrop(value: _selectedLocation, items: _locations, icon: Icons.location_on_outlined, onChanged: (v) => setState(() => _selectedLocation = v)),
        const SizedBox(width: 8),
        _FilterDrop(value: _selectedPeriod, items: _periods, icon: Icons.calendar_today_outlined, onChanged: (v) => setState(() => _selectedPeriod = v)),
      ],
    );
  }
}

// ─── Filter Dropdown ────────────────────────────────────────
class _FilterDrop extends StatelessWidget {
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const _FilterDrop({required this.value, required this.items, required this.icon, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.cardBorder), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.tableSubText),
          style: const TextStyle(fontSize: 12, color: AppColors.tableSubText, fontWeight: FontWeight.w500),
          items: items.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 13, color: AppColors.tableSubText),
              const SizedBox(width: 5),
              Text(item, style: const TextStyle(fontSize: 12, color: AppColors.tableSubText)),
            ]),
          )).toList(),
          onChanged: (v) { if (v != null) onChanged(v); },
        ),
      ),
    );
  }
}

// ─── Stat Card ──────────────────────────────────────────────
class _StatCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
  const _StatCard({required this.title, this.subtitle, required this.value, required this.icon, required this.iconColor, required this.valueColor});
  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _hovered ? widget.valueColor.withOpacity(0.4) : AppColors.cardBorder),
          boxShadow: _hovered ? [BoxShadow(color: widget.valueColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: widget.iconColor, shape: BoxShape.circle),
              child: Icon(widget.icon, color: widget.valueColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.tableText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (widget.subtitle != null) Text(widget.subtitle!, style: const TextStyle(fontSize: 9, color: AppColors.tableSubText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(widget.value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.valueColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
