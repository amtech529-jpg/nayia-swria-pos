import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/domain/auth_state.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  bool _customersExpanded = false;
  bool _salesExpanded = false;
  bool _productsExpanded = false;
  bool _purchasesExpanded = false;
  bool _reportsExpanded = false;
  bool _settingsExpanded = false;

  @override
  void initState() {
    super.initState();
    _customersExpanded = widget.currentRoute.startsWith('/customers') || widget.currentRoute == '/area-managers';
    _salesExpanded = widget.currentRoute.startsWith('/sales') || widget.currentRoute == '/pos';
    _productsExpanded = widget.currentRoute.startsWith('/products') || 
                        widget.currentRoute == '/categories' || 
                        widget.currentRoute == '/units' || 
                        widget.currentRoute == '/barcodes' || 
                        widget.currentRoute == '/product-history';
    _purchasesExpanded = widget.currentRoute.startsWith('/purchases') || widget.currentRoute == '/purchase-return';
    _reportsExpanded = widget.currentRoute.startsWith('/reports');
    _settingsExpanded = widget.currentRoute.startsWith('/settings');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isWide = MediaQuery.of(context).size.width > 1100;

    if (isWide) {
      return Scaffold(
        backgroundColor: AppColors.contentBg,
        body: Row(
          children: [
            _buildSidebar(context, auth),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(context, auth),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.contentBg,
      appBar: AppBar(
        backgroundColor: AppColors.topBarBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.sidebarBg),
        title: const Text('Nayia Swaria', style: TextStyle(color: AppColors.sidebarBg, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [_buildTopBarActions(context, auth)],
      ),
      drawer: Drawer(child: _buildSidebarContent(context, auth), width: 260),
      body: widget.child,
    );
  }

  Widget _buildSidebar(BuildContext context, AuthState auth) {
    return Container(width: 260, color: AppColors.sidebarBg, child: _buildSidebarContent(context, auth));
  }

  Widget _buildSidebarContent(BuildContext context, AuthState auth) {
    return Container(
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFfbbf24), borderRadius: BorderRadius.circular(8)),
                child: const Text('Nayia Swaria', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1e3a5f))),
              ),
            ),
          ),
          const Divider(color: Color(0xFF2d4d7a), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _sidebarItem(context, icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/dashboard'),
                
                _sidebarExpandable(
                  context,
                  icon: Icons.people_alt_outlined,
                  label: 'Customers',
                  isExpanded: _customersExpanded,
                  onTap: () => setState(() => _customersExpanded = !_customersExpanded),
                  children: [
                    _sidebarSubItem(context, 'All Customers', '/customers'),
                    _sidebarSubItem(context, 'Area Managers', '/area-managers'),
                  ],
                ),

                _sidebarItem(context, icon: Icons.local_shipping_outlined, label: 'Suppliers', route: '/suppliers'),

                _sidebarExpandable(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  label: 'Sales',
                  isExpanded: _salesExpanded,
                  onTap: () => setState(() => _salesExpanded = !_salesExpanded),
                  children: [
                    _sidebarSubItem(context, 'All Sales', '/sales'),
                    _sidebarSubItem(context, 'Sales Return', '/sales-return'),
                    _sidebarSubItem(context, 'POS', '/pos'),
                  ],
                ),

                _sidebarExpandable(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  label: 'Purchases',
                  isExpanded: _purchasesExpanded,
                  onTap: () => setState(() => _purchasesExpanded = !_purchasesExpanded),
                  children: [
                    _sidebarSubItem(context, 'All Purchases', '/purchases'),
                    _sidebarSubItem(context, 'Purchase Return', '/purchase-return'),
                  ],
                ),

                _sidebarItem(context, icon: Icons.attach_money_outlined, label: 'Expenses', route: '/expenses'),

                _sidebarExpandable(
                  context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Products',
                  isExpanded: _productsExpanded,
                  onTap: () => setState(() => _productsExpanded = !_productsExpanded),
                  children: [
                    _sidebarSubItem(context, 'All Products', '/products'),
                    _sidebarSubItem(context, 'Categories', '/categories'),
                    _sidebarSubItem(context, 'Units', '/units'),
                    _sidebarSubItem(context, 'Barcodes', '/barcodes'),
                    _sidebarSubItem(context, 'Product history', '/product-history'),
                  ],
                ),

                _sidebarItem(context, icon: Icons.swap_horiz_outlined, label: 'Stock Transfer', route: '/stock-transfer'),
                _sidebarItem(context, icon: Icons.tune_outlined, label: 'Stock Adjustments', route: '/stock-adjustment'),
                _sidebarItem(context, icon: Icons.local_offer_outlined, label: 'Discounts', route: '/discounts'),

                _sidebarExpandable(
                  context,
                  icon: Icons.bar_chart_outlined,
                  label: 'Reports',
                  isExpanded: _reportsExpanded,
                  onTap: () => setState(() => _reportsExpanded = !_reportsExpanded),
                  children: [
                    _sidebarSubItem(context, 'Profit & Loss', '/reports/profit-loss'),
                    _sidebarSubItem(context, 'Sales Report', '/reports/sales'),
                    _sidebarSubItem(context, 'Purchase Report', '/reports/purchase'),
                    _sidebarSubItem(context, 'Stock Report', '/reports/stock'),
                  ],
                ),

                _sidebarExpandable(
                  context,
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isExpanded: _settingsExpanded,
                  onTap: () => setState(() => _settingsExpanded = !_settingsExpanded),
                  children: [
                    _sidebarSubItem(context, 'Business Settings', '/settings/business'),
                    _sidebarSubItem(context, 'Business Locations', '/settings/locations'),
                    _sidebarSubItem(context, 'Invoice Schemes', '/settings/invoices'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(BuildContext context, {required IconData icon, required String label, required String route}) {
    final isActive = widget.currentRoute == route;
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : AppColors.sidebarIcon, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.sidebarIcon, fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _sidebarExpandable(BuildContext context, {required IconData icon, required String label, required bool isExpanded, required VoidCallback onTap, required List<Widget> children}) {
    final isActive = (label == 'Customers' && (widget.currentRoute.startsWith('/customers') || widget.currentRoute == '/area-managers')) ||
                     (label == 'Suppliers' && widget.currentRoute.startsWith('/suppliers')) ||
                     (label == 'Sales' && widget.currentRoute.startsWith('/sales')) ||
                     (label == 'Products' && (widget.currentRoute.startsWith('/products') || widget.currentRoute == '/categories' || widget.currentRoute == '/units' || widget.currentRoute == '/barcodes')) ||
                     (label == 'Purchases' && widget.currentRoute.startsWith('/purchases')) ||
                     (label == 'Reports' && widget.currentRoute.startsWith('/reports')) ||
                     (label == 'Settings' && widget.currentRoute.startsWith('/settings'));

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(icon, color: isActive ? Colors.white : AppColors.sidebarIcon, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.sidebarIcon, fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400))),
                Icon(isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right, color: AppColors.sidebarIcon, size: 18),
              ],
            ),
          ),
        ),
        if (isExpanded) ...children,
      ],
    );
  }

  Widget _sidebarSubItem(BuildContext context, String label, String route) {
    final isActive = widget.currentRoute == route;
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.only(left: 44, right: 12, top: 2, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isActive ? Colors.white.withOpacity(0.12) : Colors.transparent, borderRadius: BorderRadius.circular(6)),
        child: Row(
          children: [
            if (isActive) Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            if (isActive) const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.sidebarIcon, fontSize: 13, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AuthState auth) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: AppColors.topBarBg, border: Border(bottom: BorderSide(color: AppColors.topBarBorder))),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [_buildTopBarActions(context, auth)]),
    );
  }

  Widget _buildTopBarActions(BuildContext context, AuthState auth) {
    return Row(
      children: [
        _TopAction(label: 'POS', icon: Icons.point_of_sale, onTap: () => context.go('/pos')),
        const SizedBox(width: 16),
        PopupMenuButton(
          offset: const Offset(0, 45),
          child: Row(
            children: [
              CircleAvatar(radius: 16, backgroundColor: AppColors.sidebarBg, child: Text(auth.user?.fullName?[0] ?? 'A', style: const TextStyle(color: Colors.white, fontSize: 12))),
              const SizedBox(width: 8),
              Text(auth.user?.fullName ?? 'Admin', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'profile', child: Text('Profile')),
            const PopupMenuItem(value: 'logout', child: Text('Logout', style: TextStyle(color: Colors.red))),
          ],
          onSelected: (v) { if (v == 'logout') ref.read(authProvider.notifier).logout(); },
        ),
      ],
    );
  }
}

class _TopAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _TopAction({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primaryBtn),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.tableText, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
