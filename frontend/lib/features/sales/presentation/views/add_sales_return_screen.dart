import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/sales/data/models/sale_return_model.dart';
import 'package:frontend/features/sales/presentation/providers/sale_returns_provider.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/inventory/data/models/product_model.dart';
import 'package:frontend/features/customers/presentation/providers/customers_provider.dart';

class AddSalesReturnScreen extends ConsumerStatefulWidget {
  const AddSalesReturnScreen({super.key});

  @override
  ConsumerState<AddSalesReturnScreen> createState() => _AddSalesReturnScreenState();
}

class _AddSalesReturnScreenState extends ConsumerState<AddSalesReturnScreen> {
  final _refCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: 'May 20, 2026 12:00 AM');
  final _notesCtrl = TextEditingController();

  final List<SaleReturnItemModel> _items = [];
  final _productSearchCtrl = TextEditingController();
  final _productSearchFocusNode = FocusNode();

  String _selectedLocation = 'Default';
  String? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _refCtrl.text = 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final now = DateTime.now();
    _dateCtrl.text = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    _productSearchCtrl.dispose();
    _productSearchFocusNode.dispose();
    super.dispose();
  }

  void _addProductToReturn(ProductModel prod) {
    // Check if product already in return list
    final existingIdx = _items.indexWhere((item) => item.productName == prod.name);
    if (existingIdx != -1) {
      final existingItem = _items[existingIdx];
      setState(() {
        _items[existingIdx] = SaleReturnItemModel(
          productName: existingItem.productName,
          qty: existingItem.qty + 1,
          price: existingItem.price,
          totalPrice: (existingItem.qty + 1) * existingItem.price,
        );
      });
    } else {
      setState(() {
        _items.add(SaleReturnItemModel(
          productName: prod.name,
          qty: 1,
          price: prod.price, // defaults to sale price of product
          totalPrice: prod.price,
        ));
      });
    }
  }

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void _saveReturn() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product to return.')),
      );
      return;
    }

    final newReturn = SaleReturnModel(
      id: '',
      saleId: null,
      returnNo: _refCtrl.text.trim(),
      returnDate: _dateCtrl.text.trim(),
      totalAmount: _totalAmount,
      reason: _notesCtrl.text.trim(),
      items: _items,
    );

    final success = await ref.read(saleReturnsProvider.notifier).addSaleReturn(newReturn);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale Return Saved Successfully!')),
      );
      context.go('/sales-return');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save Sale Return.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsListProvider);
    final customersState = ref.watch(customersListProvider);

    // Initialize selected customer if not set
    customersState.whenData((customers) {
      if (_selectedCustomerId == null && customers.isNotEmpty) {
        setState(() {
          _selectedCustomerId = customers.first.id;
        });
      }
    });

    return MainLayout(
      currentRoute: '/sales-return/create',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Add Sale Return']),
            const SizedBox(height: 24),

            // Main Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Sale Return Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1e293b)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Business Location*',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf8fafc),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFe2e8f0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLocation,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'Default', child: Text('Default')),
                                    DropdownMenuItem(value: 'Warehouse A', child: Text('Warehouse A')),
                                  ],
                                  onChanged: (val) => setState(() => _selectedLocation = val ?? 'Default'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customer*',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFf8fafc),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFe2e8f0)),
                              ),
                              child: customersState.when(
                                data: (customers) {
                                  final hasSelected = customers.any((c) => c.id == _selectedCustomerId);
                                  final dropdownValue = hasSelected ? _selectedCustomerId : (customers.isNotEmpty ? customers.first.id : null);
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: dropdownValue,
                                      isExpanded: true,
                                      hint: const Text('Select Customer'),
                                      items: customers.map((c) {
                                        return DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedCustomerId = val),
                                    ),
                                  );
                                },
                                loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                                error: (_, __) => const Text('Error loading customers'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildField('Reference / Return No.*', _refCtrl, hint: 'Reference')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('Sale Return Date*', _dateCtrl, hint: 'YYYY-MM-DD')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Product Selection Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Products to Return',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1e293b)),
                  ),
                  const SizedBox(height: 16),

                  // Search Box
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf8fafc),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFe2e8f0)),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return RawAutocomplete<ProductModel>(
                          textEditingController: _productSearchCtrl,
                          focusNode: _productSearchFocusNode,
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<ProductModel>.empty();
                            }
                            return productsState.when(
                              data: (products) => products.where((ProductModel option) {
                                return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                    (option.sku ?? '').toLowerCase().contains(textEditingValue.text.toLowerCase());
                              }),
                              loading: () => const Iterable<ProductModel>.empty(),
                              error: (_, __) => const Iterable<ProductModel>.empty(),
                            );
                          },
                          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: textController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                hintText: 'Type product name or SKU to search and add...',
                                hintStyle: TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
                                border: InputBorder.none,
                                icon: Icon(Icons.search, color: Color(0xFF64748b), size: 20),
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: 250,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final ProductModel option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                        subtitle: Text('SKU: ${option.sku ?? ""} - Selling Price: Rs ${option.price}'),
                                        onTap: () {
                                          onSelected(option);
                                          _addProductToReturn(option);
                                          _productSearchCtrl.clear();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Returned Items Table
                  if (_items.isEmpty)
                    _buildEmptyState('No Products Added', 'Search and select products above to add them to the return list.')
                  else ...[
                    PosTable(
                      columns: const ['REMOVE', 'SR. #', 'PRODUCT NAME', 'RETURN QTY', 'RETURN UNIT PRICE', 'TOTAL PRICE'],
                      columnWidths: const [80, 80, 400, 150, 180, 150],
                      rows: _items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final qtyCtrl = TextEditingController(text: item.qty.toString());
                        final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));

                        return [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            onPressed: () => setState(() => _items.removeAt(idx)),
                          ),
                          Text('${idx + 1}', style: const TextStyle(fontSize: 13)),
                          Text(item.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          // Qty Field
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: qtyCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (val) {
                                final newQty = int.tryParse(val) ?? 0;
                                setState(() {
                                  _items[idx] = SaleReturnItemModel(
                                    productName: item.productName,
                                    qty: newQty,
                                    price: item.price,
                                    totalPrice: newQty * item.price,
                                  );
                                });
                              },
                            ),
                          ),
                          // Return Price Field
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                isDense: true,
                                prefixText: 'Rs ',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              onChanged: (val) {
                                final newPrice = double.tryParse(val) ?? 0.0;
                                setState(() {
                                  _items[idx] = SaleReturnItemModel(
                                    productName: item.productName,
                                    qty: item.qty,
                                    price: newPrice,
                                    totalPrice: item.qty * newPrice,
                                  );
                                });
                              },
                            ),
                          ),
                          Text('Rs ${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ];
                      }).toList(),
                    ),
                    const Divider(height: 40),
                    // Summary Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Return Amount: ',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        Text(
                          'Rs ${_totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0f172a)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Additional Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reason & Additional Info', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                  const SizedBox(height: 16),
                  _buildField('Reason for return', _notesCtrl, hint: 'E.g., damaged items, incorrect delivery, customer returned...', maxLines: 3),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => context.go('/sales-return'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748b))),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveReturn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0f172a),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Save Sale Return', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String hint = '', int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
        ],
        Container(
          height: maxLines > 1 ? null : 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFf8fafc),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFf1f5f9)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFe2e8f0).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.shopping_bag_outlined, size: 24, color: Color(0xFF94a3b8)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
        ],
      ),
    );
  }
}
