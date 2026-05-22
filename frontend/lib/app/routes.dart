import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Auth
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/auth/presentation/views/login_screen.dart';

// Home
import 'package:frontend/features/home/presentation/views/home_screen.dart';

// Inventory
import 'package:frontend/features/inventory/presentation/views/products_screen.dart';
import 'package:frontend/features/inventory/presentation/views/categories_screen.dart';
import 'package:frontend/features/inventory/presentation/views/stock_transfer_screen.dart';
import 'package:frontend/features/inventory/presentation/views/stock_adjustment_screen.dart';
import 'package:frontend/features/inventory/presentation/views/barcodes_screen.dart';
import 'package:frontend/features/inventory/presentation/views/product_history_screen.dart';
import 'package:frontend/features/inventory/presentation/views/units_screen.dart';

// Sales
import 'package:frontend/features/sales/presentation/views/sales_screen.dart';
import 'package:frontend/features/sales/presentation/views/sales_return_screen.dart';
import 'package:frontend/features/sales/presentation/views/discounts_screen.dart';
import 'package:frontend/features/pos/presentation/views/pos_screen.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';

// Purchases
import 'package:frontend/features/purchases/presentation/views/purchases_screen.dart';
import 'package:frontend/features/purchases/presentation/views/purchase_return_screen.dart';
import 'package:frontend/features/purchases/presentation/views/add_purchase_return_screen.dart';
import 'package:frontend/features/purchases/data/models/purchase_model.dart';

// Expenses
import 'package:frontend/features/expenses/presentation/views/expenses_screen.dart';

// Customers
import 'package:frontend/features/customers/presentation/views/customers_screen.dart';
import 'package:frontend/features/customers/presentation/views/create_customer_screen.dart';
import 'package:frontend/features/customers/presentation/views/customer_payments_screen.dart';
import 'package:frontend/features/customers/presentation/views/area_managers_screen.dart';
import 'package:frontend/features/customers/presentation/views/add_area_manager_screen.dart';
import 'package:frontend/features/customers/presentation/views/view_area_manager_screen.dart';
import 'package:frontend/features/customers/data/models/area_manager_model.dart';
import 'package:frontend/features/customers/presentation/views/view_customer_screen.dart';

// Reports
import 'package:frontend/features/reports/presentation/views/profit_loss_report_screen.dart';
import 'package:frontend/features/reports/presentation/views/sales_report_screen.dart';
import 'package:frontend/features/reports/presentation/views/purchase_report_screen.dart';
import 'package:frontend/features/reports/presentation/views/stock_report_screen.dart';

// Settings
import 'package:frontend/features/settings/presentation/views/business_settings_screen.dart';
import 'package:frontend/features/settings/presentation/views/business_locations_screen.dart';
import 'package:frontend/features/settings/presentation/views/invoice_schemes_screen.dart';

import 'package:frontend/features/purchases/presentation/views/add_purchase_screen.dart';
import 'package:frontend/features/inventory/presentation/views/create_product_screen.dart';

import 'package:frontend/features/sales/presentation/views/add_sales_return_screen.dart';

import 'package:frontend/features/suppliers/presentation/views/suppliers_screen.dart';
import 'package:frontend/features/suppliers/presentation/views/add_supplier_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: auth.isLoggedIn ? '/dashboard' : '/login',
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/products', builder: (_, __) => const ProductsScreen()),
      GoRoute(path: '/products/create', builder: (_, __) => const CreateProductScreen()),
      GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
      GoRoute(path: '/sales', builder: (_, __) => const SalesScreen()),
      GoRoute(path: '/sales-return', builder: (_, __) => const SalesReturnScreen()),
      GoRoute(path: '/sales-return/create', builder: (_, __) => const AddSalesReturnScreen()),
      GoRoute(
        path: '/pos',
        builder: (context, state) {
          final sale = state.extra as SaleModel?;
          return PosScreen(editSale: sale);
        },
      ),
      GoRoute(path: '/purchases', builder: (_, __) => const PurchasesScreen()),
      GoRoute(path: '/purchases/create', builder: (_, __) => const AddPurchaseScreen()),
      GoRoute(
        path: '/purchases/edit/:id',
        builder: (context, state) {
          final purchase = state.extra as PurchaseModel?;
          return AddPurchaseScreen(editPurchase: purchase);
        },
      ),
      GoRoute(path: '/expenses', builder: (_, __) => const ExpensesScreen()),
      GoRoute(path: '/stock-transfer', builder: (_, __) => const StockTransferScreen()),
      GoRoute(path: '/stock-adjustment', builder: (_, __) => const StockAdjustmentScreen()),
      GoRoute(path: '/stock-adjustments', builder: (_, __) => const StockAdjustmentScreen()),
      GoRoute(path: '/discounts', builder: (_, __) => const DiscountsScreen()),
      GoRoute(path: '/customers', builder: (_, __) => const CustomersScreen()),
      GoRoute(path: '/customers/create', builder: (_, __) => const CreateCustomerScreen()),
      GoRoute(path: '/customers/payments', builder: (_, __) => const CustomerPaymentsScreen()),
      GoRoute(
        path: '/customers/view/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ViewCustomerScreen(customerId: id);
        },
      ),
      GoRoute(path: '/suppliers', builder: (_, __) => const SuppliersScreen()),
      GoRoute(path: '/suppliers/create', builder: (_, __) => const AddSupplierScreen()),
      GoRoute(path: '/area-managers', builder: (_, __) => const AreaManagersScreen()),
      GoRoute(path: '/add-area-manager', builder: (_, __) => const AddAreaManagerScreen()),
      GoRoute(
        path: '/edit-area-manager',
        builder: (context, state) {
          final manager = state.extra as AreaManagerModel?;
          return AddAreaManagerScreen(manager: manager);
        },
      ),
      GoRoute(
        path: '/view-area-manager',
        builder: (context, state) {
          final manager = state.extra as AreaManagerModel;
          return ViewAreaManagerScreen(manager: manager);
        },
      ),
      GoRoute(path: '/units', builder: (_, __) => const UnitsScreen()),
      GoRoute(path: '/barcodes', builder: (_, __) => const BarcodesScreen()),
      GoRoute(path: '/product-history', builder: (_, __) => const ProductHistoryScreen()),
      GoRoute(path: '/purchase-return', builder: (_, __) => const PurchaseReturnScreen()),
      GoRoute(path: '/purchase-return/create', builder: (_, __) => const AddPurchaseReturnScreen()),
      
      // Reports
      GoRoute(path: '/reports/profit-loss', builder: (_, __) => const ProfitLossReportScreen()),
      GoRoute(path: '/reports/sales', builder: (_, __) => const SalesReportScreen()),
      GoRoute(path: '/reports/purchase', builder: (_, __) => const PurchaseReportScreen()),
      GoRoute(path: '/reports/stock', builder: (_, __) => const StockReportScreen()),

      // Settings
      GoRoute(path: '/settings/business', builder: (_, __) => const BusinessSettingsScreen()),
      GoRoute(path: '/settings/locations', builder: (_, __) => const BusinessLocationsScreen()),
      GoRoute(path: '/settings/invoices', builder: (_, __) => const InvoiceSchemesScreen()),
    ],
    errorBuilder: (_, __) => const _Placeholder(title: 'Page Not Found'),
  );
});

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_outlined, size: 52, color: Color(0xFF94a3b8)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            const SizedBox(height: 6),
            const Text('Coming soon', style: TextStyle(fontSize: 14, color: Color(0xFF94a3b8))),
          ],
        ),
      ),
    );
  }
}
