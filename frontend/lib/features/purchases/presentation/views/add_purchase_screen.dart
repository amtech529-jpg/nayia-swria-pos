import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/suppliers/presentation/providers/suppliers_provider.dart';
import 'package:frontend/features/purchases/presentation/providers/purchases_provider.dart';
import 'package:frontend/features/purchases/data/models/purchase_model.dart';
import 'package:frontend/features/inventory/data/models/product_model.dart';
import 'package:frontend/features/suppliers/data/models/supplier_model.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

class AddPurchaseScreen extends ConsumerStatefulWidget {
  final PurchaseModel? editPurchase;

  const AddPurchaseScreen({super.key, this.editPurchase});

  @override
  ConsumerState<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends ConsumerState<AddPurchaseScreen> {
  final _refCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _shippingCtrl = TextEditingController(text: '0');
  final _labourCtrl = TextEditingController(text: '0');
  final _discountAmountCtrl = TextEditingController(text: '0');
  final _paymentAmountCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  final _productSearchCtrl = TextEditingController();

  SupplierModel? _selectedSupplier;
  String _selectedLocation = 'Default';
  String _selectedStatus = 'Received';
  String _selectedPaymentMethod = 'Cash';

  List<PurchaseItemModel> _items = [];
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.editPurchase != null;
    
    if (_isEdit) {
      final p = widget.editPurchase!;
      _refCtrl.text = p.refNo ?? '';
      _dateCtrl.text = p.purchaseDate.split('T')[0];
      _shippingCtrl.text = '0'; // default / not stored directly or derived
      _labourCtrl.text = '0';
      _discountAmountCtrl.text = p.discount.toStringAsFixed(0);
      _paymentAmountCtrl.text = p.paidAmount.toStringAsFixed(0);
      _items = List.from(p.items);
      _selectedLocation = p.location;
      _selectedPaymentMethod = p.paymentMethod;
      _selectedStatus = p.pendingAmount <= 0 ? 'Received' : 'Pending';
    } else {
      _dateCtrl.text = DateTime.now().toString().split(' ')[0];
    }
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _dateCtrl.dispose();
    _shippingCtrl.dispose();
    _labourCtrl.dispose();
    _discountAmountCtrl.dispose();
    _paymentAmountCtrl.dispose();
    _notesCtrl.dispose();
    _productSearchCtrl.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  double get _discount {
    return double.tryParse(_discountAmountCtrl.text) ?? 0.0;
  }

  double get _shipping {
    return double.tryParse(_shippingCtrl.text) ?? 0.0;
  }

  double get _labour {
    return double.tryParse(_labourCtrl.text) ?? 0.0;
  }

  double get _netTotal {
    final val = _subtotal - _discount + _shipping + _labour;
    return val < 0 ? 0 : val;
  }

  double get _paidAmount {
    return double.tryParse(_paymentAmountCtrl.text) ?? 0.0;
  }

  double get _pendingAmount {
    final val = _netTotal - _paidAmount;
    return val < 0 ? 0 : val;
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsListProvider);
    final suppliersState = ref.watch(suppliersListProvider);

    // Find supplier if edit
    if (_isEdit && _selectedSupplier == null && suppliersState.hasValue) {
      final sups = suppliersState.value ?? [];
      final match = sups.where((s) => s.id == widget.editPurchase!.supplierId || s.name == widget.editPurchase!.supplierName);
      if (match.isNotEmpty) {
        _selectedSupplier = match.first;
      }
    }

    return MainLayout(
      currentRoute: _isEdit ? '/purchases' : '/purchases/create',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbWidget(items: ['Home', 'Purchases', _isEdit ? 'Edit Purchase' : 'Add Purchase']),
            const SizedBox(height: 24),

            // 1. General Info Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_isEdit ? 'Edit Purchase' : 'Add Purchase', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Supplier*', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            suppliersState.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (e, s) => Text('Error loading suppliers: $e'),
                              data: (sups) {
                                if (_selectedSupplier == null && sups.isNotEmpty && !_isEdit) {
                                  _selectedSupplier = sups.first;
                                }
                                return Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<SupplierModel>(
                                      value: _selectedSupplier,
                                      isExpanded: true,
                                      items: sups.map((s) => DropdownMenuItem(value: s, child: Text(s.name, style: const TextStyle(fontSize: 13)))).toList(),
                                      onChanged: (val) => setState(() => _selectedSupplier = val),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Business Location*', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLocation,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'Default', child: Text('Default Location', style: TextStyle(fontSize: 13))),
                                  ],
                                  onChanged: (val) => setState(() => _selectedLocation = val ?? 'Default'),
                                ),
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
                      Expanded(child: _buildField('Reference*', _refCtrl, hint: 'Reference / Bill No')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('Purchase Date', _dateCtrl, hint: 'YYYY-MM-DD')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedStatus,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'Received', child: Text('Received', style: TextStyle(fontSize: 13))),
                                    DropdownMenuItem(value: 'Pending', child: Text('Pending', style: TextStyle(fontSize: 13))),
                                  ],
                                  onChanged: (val) => setState(() => _selectedStatus = val ?? 'Received'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('Shipping Charges', _shippingCtrl, prefix: 'Rs ', onChanged: (_) => setState(() {}))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildField('Labour Charges', _labourCtrl, prefix: 'Rs ', onChanged: (_) => setState(() {}))),
                      const SizedBox(width: 24),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Product Search & Table Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Products', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                  const SizedBox(height: 16),
                  
                  // Product autocomplete/search field
                  productsState.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => Text('Error loading products: $e'),
                    data: (prods) {
                      return LayoutBuilder(
                        builder: (context, constraints) => RawAutocomplete<ProductModel>(
                          textEditingController: _productSearchCtrl,
                          focusNode: FocusNode(),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<ProductModel>.empty();
                            }
                            return prods.where((ProductModel option) {
                              return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                     (option.sku ?? '').toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          displayStringForOption: (ProductModel option) => option.name,
                          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                            return TextField(
                              controller: textController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Type product name or SKU to search...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                filled: true,
                                fillColor: const Color(0xFFf8fafc),
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: 200,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final ProductModel option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option.name),
                                        subtitle: Text('SKU: ${option.sku ?? ""} - Cost: Rs ${option.cost}'),
                                        onTap: () {
                                          onSelected(option);
                                          _addProductToTable(option);
                                          _productSearchCtrl.clear();
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_items.isEmpty)
                    _buildEmptyState('No Products Added', 'Search and select products to purchase above.')
                  else ...[
                    PosTable(
                      columns: const ['REMOVE', 'SR. #', 'NAME', 'QTY', 'UNIT COST', 'TOTAL COST'],
                      columnWidths: const [80, 80, 400, 150, 150, 150],
                      rows: _items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        final qtyCtrl = TextEditingController(text: item.qty.toString());
                        final costCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
                        
                        return [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            onPressed: () => setState(() => _items.removeAt(idx)),
                          ),
                          Text('${idx + 1}', style: const TextStyle(fontSize: 13)),
                          Text(item.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: qtyCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                              onChanged: (val) {
                                final parsedQty = int.tryParse(val) ?? 0;
                                setState(() {
                                  _items[idx] = PurchaseItemModel(
                                    id: item.id,
                                    productName: item.productName,
                                    sku: item.sku,
                                    qty: parsedQty,
                                    price: item.price,
                                    totalPrice: parsedQty * item.price,
                                  );
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: costCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                              onChanged: (val) {
                                final parsedPrice = double.tryParse(val) ?? 0.0;
                                setState(() {
                                  _items[idx] = PurchaseItemModel(
                                    id: item.id,
                                    productName: item.productName,
                                    sku: item.sku,
                                    qty: item.qty,
                                    price: parsedPrice,
                                    totalPrice: item.qty * parsedPrice,
                                  );
                                });
                              },
                            ),
                          ),
                          Text('Rs ${item.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ];
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Discount Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discount & Payments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildField('Discount Amount', _discountAmountCtrl, prefix: 'Rs ', onChanged: (_) => setState(() {}))),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('Amount Paid', _paymentAmountCtrl, prefix: 'Rs ', onChanged: (_) => setState(() {}))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Payment Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPaymentMethod,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'Cash', child: Text('Cash', style: TextStyle(fontSize: 13))),
                                    DropdownMenuItem(value: 'Card', child: Text('Card', style: TextStyle(fontSize: 13))),
                                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer', style: TextStyle(fontSize: 13))),
                                  ],
                                  onChanged: (val) => setState(() => _selectedPaymentMethod = val ?? 'Cash'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Summary & Save Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                        const SizedBox(height: 16),
                        _summaryRow('Subtotal:', 'Rs ${_subtotal.toStringAsFixed(0)}'),
                        _summaryRow('Discount:', 'Rs ${_discount.toStringAsFixed(0)}'),
                        _summaryRow('Shipping:', 'Rs ${_shipping.toStringAsFixed(0)}'),
                        _summaryRow('Labour:', 'Rs ${_labour.toStringAsFixed(0)}'),
                        const Divider(),
                        _summaryRow('Net Total:', 'Rs ${_netTotal.toStringAsFixed(0)}'),
                        _summaryRow('Paid Amount:', 'Rs ${_paidAmount.toStringAsFixed(0)}'),
                        _summaryRow('Balance Due:', 'Rs ${_pendingAmount.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0f172a),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _savePurchase,
                child: Text(_isEdit ? 'Update Purchase' : 'Save Purchase', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addProductToTable(ProductModel prod) {
    // Check if product already exists in items
    final existingIndex = _items.indexWhere((item) => item.productName == prod.name);
    if (existingIndex != -1) {
      final existingItem = _items[existingIndex];
      setState(() {
        _items[existingIndex] = PurchaseItemModel(
          id: existingItem.id,
          productName: existingItem.productName,
          sku: existingItem.sku,
          qty: existingItem.qty + 1,
          price: existingItem.price,
          totalPrice: (existingItem.qty + 1) * existingItem.price,
        );
      });
    } else {
      setState(() {
        _items.add(PurchaseItemModel(
          productName: prod.name,
          sku: prod.sku,
          qty: 1,
          price: prod.cost,
          totalPrice: prod.cost,
        ));
      });
    }
  }

  Future<void> _savePurchase() async {
    if (_refCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter reference number')));
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one product')));
      return;
    }
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select supplier')));
      return;
    }

    final p = PurchaseModel(
      id: _isEdit ? widget.editPurchase!.id : const Uuid().v4(),
      invoiceNo: _isEdit ? widget.editPurchase!.invoiceNo : 'PR${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      supplierId: _selectedSupplier!.id,
      supplierName: _selectedSupplier!.name,
      purchaseDate: _dateCtrl.text.contains('T') ? _dateCtrl.text : '${_dateCtrl.text}T00:00:00Z',
      location: _selectedLocation,
      refNo: _refCtrl.text,
      paymentMethod: _selectedPaymentMethod,
      subtotal: _subtotal,
      discount: _discount,
      netTotal: _netTotal,
      paidAmount: _paidAmount,
      pendingAmount: _pendingAmount,
      items: _items,
    );

    final success = await ref.read(purchasesProvider.notifier).addPurchase(p);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase saved successfully')));
      context.go('/purchases');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save purchase')));
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: child,
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String hint = '', String prefix = '', void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
        ],
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
          child: Row(
            children: [
              if (prefix.isNotEmpty) Text(prefix, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  style: const TextStyle(fontSize: 13),
                  onChanged: onChanged,
                  decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13), border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748b), fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1e293b), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFFe2e8f0).withOpacity(0.5), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.folder_open_outlined, size: 30, color: Color(0xFF94a3b8))),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
        ],
      ),
    );
  }
}
