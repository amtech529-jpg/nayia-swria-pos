import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/inventory/data/models/product_model.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  int _selectedTab = 0; // 0 for Products, 1 for Brands
  final _searchController = TextEditingController();
  bool _showFilters = false;

  // Initializing these directly to avoid 'late' errors
  final List<String> _productCols = ['', 'NAME', 'SKU', 'COST', 'PRICE', 'STOCK', 'UNIT', 'ALERT QUANTITY', 'LOCATION', 'ACTIONS'];
  final List<String> _brandCols = ['', 'NAME', 'DESCRIPTION', 'BUSINESS LOCATIONS', 'ACTIONS'];
  
  List<bool> _visibleProdCols = [];
  List<bool> _visibleBrandCols = [];

  final List<Map<String, dynamic>> _brands = [
    {'name': 'Default', 'description': '', 'locations': 'Default'},
  ];

  @override
  void initState() {
    super.initState();
    _visibleProdCols = List.generate(_productCols.length, (_) => true);
    _visibleBrandCols = List.generate(_brandCols.length, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/products',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                _breadcrumbItem('Home'),
                _breadcrumbDivider(),
                _breadcrumbItem('Products', isLast: true),
              ],
            ),
            const SizedBox(height: 24),

            // Tabs
            Row(
              children: [
                _tab('Products', 0),
                const SizedBox(width: 4),
                _tab('Brands', 1),
              ],
            ),
            const SizedBox(height: 20),

            if (_showFilters && _selectedTab == 0) _buildAdvancedFilters(),

            // Table Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  // Table Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          _selectedTab == 0 ? 'All Products' : 'All Brands',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedTab == 0
                              ? '${ref.watch(productsListProvider).maybeWhen(data: (p) => p.length, orElse: () => 0)} items'
                              : '${_brands.length} items',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8)),
                        ),
                        const Spacer(),
                        _btn(_selectedTab == 0 ? '+ Add Product' : '+ Add Brand', onTap: () {
                          if (_selectedTab == 0) {
                            context.go('/products/create');
                          } else {
                            _showAddBrandDialog();
                          }
                        }),
                        const SizedBox(width: 12),
                        _searchField(),
                        const SizedBox(width: 12),
                        _utilityBtn('Columns', Icons.view_column_outlined, onTap: () {}),
                        const SizedBox(width: 12),
                        if (_selectedTab == 0)
                          _utilityBtn('', Icons.filter_alt_outlined, onTap: () => setState(() => _showFilters = !_showFilters), isActive: _showFilters),
                        const SizedBox(width: 12),
                        const Icon(Icons.more_vert, color: Color(0xFF64748b), size: 20),
                      ],
                    ),
                  ),

                  // Table
                  if (_selectedTab == 0)
                    ref.watch(productsListProvider).when(
                      loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => Padding(padding: const EdgeInsets.all(24), child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
                      data: (products) => _buildProductsTable(products),
                    )
                  else
                    _buildBrandsTable(),

                  // Pagination Footer
                  _buildPaginationFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBrandDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Brand',
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 400,
            height: double.infinity,
            decoration: const BoxDecoration(color: Colors.white),
            child: Material(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: const Color(0xFF0f172a),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add Brand', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5), shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogLocationDrop('Business Locations*'),
                          const SizedBox(height: 20),
                          _buildDialogField('Name*', hint: 'Name'),
                          const SizedBox(height: 20),
                          _buildDialogTextArea('Description', hint: 'Description'),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFe2e8f0)))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _dialogBtn('Cancel', isSecondary: true, onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        _dialogBtn('Submit', onTap: () => Navigator.pop(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim1),
          child: child,
        );
      },
    );
  }

  Widget _buildDialogField(String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFf8fafc),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTextArea(String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          maxLines: 4,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFf8fafc),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogLocationDrop(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFf8fafc),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10b981), borderRadius: BorderRadius.circular(4)),
                child: const Row(
                  children: [
                    Text('Default', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.close, size: 12, color: Colors.white),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dialogBtn(String label, {bool isSecondary = false, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.white : const Color(0xFF0f172a),
        foregroundColor: isSecondary ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: isSecondary ? const BorderSide(color: Color(0xFFe2e8f0)) : BorderSide.none,
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  Widget _tab(String label, int index) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0f172a) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF64748b),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTable(List<ProductModel> products) {
    return PosTable(
      columns: _productCols,
      visibleColumns: _visibleProdCols,
      columnWidths: const [50, 200, 120, 100, 100, 120, 80, 100, 120, 80],
      rows: products.map((p) => [
        '',
        Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0f766e))),
        Text(p.sku ?? '-', style: const TextStyle(fontSize: 13)),
        Text('Rs ${p.cost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13)),
        Text('Rs ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13)),
        Text('${p.openingStock.toStringAsFixed(0)} ${p.baseUnit}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10b981))),
        Text(p.saleUnit, style: const TextStyle(fontSize: 13)),
        Text(p.alertQty.toStringAsFixed(0), style: const TextStyle(fontSize: 13)),
        _badge(p.location),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748b)),
          onSelected: (value) async {
            if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Product'),
                  content: Text('Are you sure you want to delete "${p.name}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await ref.read(productsListProvider.notifier).removeProduct(p.id);
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ]).toList(),
    );
  }

  Widget _buildBrandsTable() {
    return PosTable(
      columns: _brandCols,
      visibleColumns: _visibleBrandCols,
      columnWidths: const [50, 300, 300, 200, 80],
      rows: _brands.map((b) => [
        '',
        Text(b['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        Text(b['description'], style: const TextStyle(fontSize: 13)),
        _badge(b['locations']),
        const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748b)),
      ]).toList(),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: Row(
        children: [
          Expanded(child: _filterDrop('Product Type', ['All', 'Single', 'Variable'])),
          const SizedBox(width: 16),
          Expanded(child: _filterDrop('Category', ['All', 'Seeds', 'Fertilizers'])),
          const SizedBox(width: 16),
          Expanded(child: _filterDrop('Unit', ['All', 'Kg', 'Pc'])),
          const SizedBox(width: 16),
          _btn('Apply Filters', onTap: () {}),
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

  Widget _searchField() {
    return Container(
      width: 200,
      height: 36,
      decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(8)),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: _selectedTab == 0 ? 'Search Product' : 'Search Brands',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8)),
          prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF94a3b8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 12),
        ),
      ),
    );
  }

  Widget _utilityBtn(String label, IconData icon, {required VoidCallback onTap, bool isActive = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFf1f5f9) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF64748b)),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748b))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4)),
            child: const Row(
              children: [
                Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Icon(Icons.keyboard_arrow_down, size: 14),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (_selectedTab == 0)
            ref.watch(productsListProvider).maybeWhen(
              data: (p) => Text('SHOWING 1-${p.length} OF ${p.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94a3b8))),
              orElse: () => const SizedBox.shrink(),
            )
          else
            Text('SHOWING 1-${_brands.length} OF ${_brands.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94a3b8))),
          const Spacer(),
          _pageNode('1', active: true),
        ],
      ),
    );
  }

  Widget _pageNode(String label, {bool active = false}) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0f172a) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : const Color(0xFF64748b), fontWeight: FontWeight.bold)),
    );
  }

  Widget _badge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFeff6ff), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF2563eb), fontWeight: FontWeight.w600)),
    );
  }

  Widget _btn(String label, {required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0f172a),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  Widget _breadcrumbItem(String label, {bool isLast = false}) {
    return Text(label, style: TextStyle(fontSize: 12, fontWeight: isLast ? FontWeight.w700 : FontWeight.w400, color: isLast ? const Color(0xFF1e293b) : const Color(0xFF64748b)));
  }

  Widget _breadcrumbDivider() {
    return const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_right, size: 14, color: Color(0xFFcbd5e1)));
  }
}
