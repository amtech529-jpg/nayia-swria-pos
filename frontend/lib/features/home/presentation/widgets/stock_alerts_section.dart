import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/customers/presentation/providers/customers_provider.dart';

class StockAlertsSection extends ConsumerStatefulWidget {
  const StockAlertsSection({super.key});
  @override
  ConsumerState<StockAlertsSection> createState() => _StockAlertsSectionState();
}

class _StockAlertsSectionState extends ConsumerState<StockAlertsSection> {
  int _tab = 0;
  int _page = 1;
  final int _perPage = 10;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- Stock Alerts (Low Stock) ---
  List<_AlertItem> _lowStockItems() {
    final products = ref.watch(productsListProvider).value ?? [];
    return products
        .where((p) => p.openingStock <= p.alertQty)
        .map((p) => _AlertItem(
              title: p.name,
              subtitle: 'SKU: ${p.sku ?? "—"}  |  Stock: ${p.openingStock.toStringAsFixed(0)}  |  Alert Level: ${p.alertQty.toStringAsFixed(0)}',
              badge: 'Low Stock',
              badgeColor: const Color(0xFFfef2f2),
              badgeTextColor: const Color(0xFFef4444),
              icon: Icons.inventory_2_outlined,
              iconColor: const Color(0xFFef4444),
            ))
        .toList();
  }

  // --- Expiry Alerts ---
  // Products with daysInExpiry > 0 are flagged.
  // daysInExpiry is treated as shelf-life in days.
  // Products with <= 30 days shelf-life are marked Critical, <= 90 Expiring Soon.
  List<_AlertItem> _expiryItems() {
    final products = ref.watch(productsListProvider).value ?? [];
    return products
        .where((p) => p.daysInExpiry > 0)
        .map((p) {
          final d = p.daysInExpiry;
          String badge;
          Color badgeBg;
          Color badgeText;
          if (d <= 30) {
            badge = 'Critical (${d}d)';
            badgeBg = const Color(0xFFfef2f2);
            badgeText = const Color(0xFFef4444);
          } else if (d <= 90) {
            badge = 'Expiring Soon (${d}d)';
            badgeBg = const Color(0xFFfff7ed);
            badgeText = const Color(0xFFf59e0b);
          } else {
            badge = 'Shelf Life: ${d}d';
            badgeBg = const Color(0xFFf0fdf4);
            badgeText = const Color(0xFF22c55e);
          }
          return _AlertItem(
            title: p.name,
            subtitle: 'SKU: ${p.sku ?? "—"}  |  Shelf Life: ${p.daysInExpiry} days',
            badge: badge,
            badgeColor: badgeBg,
            badgeTextColor: badgeText,
            icon: Icons.schedule_outlined,
            iconColor: badgeText,
          );
        })
        .toList();
  }

  // --- Payment Alerts (customers with positive balance = they owe us) ---
  List<_AlertItem> _paymentItems() {
    final customers = ref.watch(customersListProvider).value ?? [];
    return customers
        .where((c) => c.balance > 0)
        .map((c) => _AlertItem(
              title: c.name,
              subtitle: 'Phone: ${c.phone ?? "—"}  |  Area: ${c.area}',
              badge: 'Due: Rs ${c.balance.toStringAsFixed(0)}',
              badgeColor: const Color(0xFFfef2f2),
              badgeTextColor: const Color(0xFFef4444),
              icon: Icons.person_outline,
              iconColor: const Color(0xFFef4444),
            ))
        .toList();
  }

  List<_AlertItem> get _currentList {
    switch (_tab) {
      case 0: return _lowStockItems();
      case 1: return _expiryItems();
      case 2: return _paymentItems();
      default: return [];
    }
  }

  List<_AlertItem> get _filteredList {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _currentList;
    return _currentList.where((i) =>
      i.title.toLowerCase().contains(q) ||
      i.subtitle.toLowerCase().contains(q)
    ).toList();
  }

  List<_AlertItem> get _pageItems {
    final start = (_page - 1) * _perPage;
    final end = (start + _perPage).clamp(0, _filteredList.length);
    if (start >= _filteredList.length) return [];
    return _filteredList.sublist(start, end);
  }

  int get _totalPages => (_filteredList.isEmpty ? 1 : (_filteredList.length / _perPage).ceil());

  String get _tabLabel {
    switch (_tab) {
      case 0: return 'Low Stock Alerts';
      case 1: return 'Expiry Alerts';
      case 2: return 'Payment Alerts';
      default: return '';
    }
  }

  String get _emptyMessage {
    switch (_tab) {
      case 0: return 'All products are above alert quantity. ✓';
      case 1: return 'No products with expiry tracking set.';
      case 2: return 'No customers with outstanding dues. ✓';
      default: return 'No data.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _pageItems;
    final total = _filteredList.length;
    final startIdx = (_page - 1) * _perPage + 1;
    final endIdx = ((_page * _perPage).clamp(0, total));

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _TabBtn(label: 'Stock Alerts',   selected: _tab == 0, onTap: () => setState(() { _tab = 0; _page = 1; })),
                const SizedBox(width: 4),
                _TabBtn(label: 'Expiry Alerts',  selected: _tab == 1, onTap: () => setState(() { _tab = 1; _page = 1; })),
                const SizedBox(width: 4),
                _TabBtn(label: 'Payment Alerts', selected: _tab == 2, onTap: () => setState(() { _tab = 2; _page = 1; })),
              ],
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(_tabLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.tableText)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.iconCircleBlue, borderRadius: BorderRadius.circular(10)),
                  child: Text('$total items',
                      style: const TextStyle(fontSize: 11, color: AppColors.amountBlue, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                SizedBox(
                  width: 180,
                  height: 34,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() { _page = 1; }),
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search alerts...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.tableSubText),
                      prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.tableSubText),
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.inputBg,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.inputBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.inputBorder)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table header
          Container(
            color: AppColors.tableHeader,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                SizedBox(width: 36),
                Expanded(child: Text('PRODUCT / CUSTOMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tableSubText, letterSpacing: 0.5))),
                SizedBox(width: 8),
                Text('DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.tableSubText, letterSpacing: 0.5)),
              ],
            ),
          ),
          // Empty state
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: Colors.green.shade300),
                    const SizedBox(height: 8),
                    Text(_emptyMessage, style: const TextStyle(fontSize: 13, color: AppColors.tableSubText)),
                  ],
                ),
              ),
            ),
          // List items
          ...items.map((item) => Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.tableBorder))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: item.iconColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(item.icon, size: 14, color: item.iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.tableText)),
                      const SizedBox(height: 2),
                      Text(item.subtitle, style: const TextStyle(fontSize: 11, color: AppColors.tableSubText)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: item.badgeColor, borderRadius: BorderRadius.circular(10)),
                  child: Text(item.badge, style: TextStyle(fontSize: 10, color: item.badgeTextColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          )),
          // Pagination
          if (total > 0)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text('SHOWING $startIdx–$endIdx OF $total',
                      style: const TextStyle(fontSize: 11, color: AppColors.tableSubText)),
                  const Spacer(),
                  _PaginationBtn(label: '«', onTap: _page > 1 ? () => setState(() => _page = 1) : null),
                  _PaginationBtn(label: '‹', onTap: _page > 1 ? () => setState(() => _page--) : null),
                  ...List.generate(_totalPages.clamp(0, 5), (i) => _PaginationBtn(
                    label: '${i + 1}',
                    selected: _page == i + 1,
                    onTap: () => setState(() => _page = i + 1),
                  )),
                  _PaginationBtn(label: '›', onTap: _page < _totalPages ? () => setState(() => _page++) : null),
                  _PaginationBtn(label: '»', onTap: _page < _totalPages ? () => setState(() => _page = _totalPages) : null),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertItem {
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconColor;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconColor,
  });
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBtn : Colors.transparent,
        border: Border.all(color: selected ? AppColors.primaryBtn : AppColors.cardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppColors.tableText)),
    ),
  );
}

class _PaginationBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _PaginationBtn({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBtn : Colors.white,
        border: Border.all(color: selected ? AppColors.primaryBtn : AppColors.cardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.tableText, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
      ),
    ),
  );
}
