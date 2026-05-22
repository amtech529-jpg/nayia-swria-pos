import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';
import 'package:frontend/features/customers/presentation/providers/customers_provider.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/inventory/data/models/product_model.dart';
import 'package:frontend/features/customers/data/models/customer_model.dart';
import 'package:frontend/features/pos/presentation/views/invoice_dialog.dart';
import 'package:go_router/go_router.dart';

class PosScreen extends ConsumerStatefulWidget {
  final SaleModel? editSale;

  const PosScreen({super.key, this.editSale});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final List<Map<String, dynamic>> _cart = [];
  String _selectedLocation = 'Default';
  String _selectedCustomer = 'Walk In Customer';
  String _selectedSalesman = 'Admin';
  String _paymentMethod = 'Cash';
  
  final _discountCtrl = TextEditingController(text: '0');
  final _cashReceivedCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  bool _isAmountReceivedManuallyEdited = false;

  final Map<String, bool> _customerFilters = {
    'Name': true,
    'Father Name': false,
    'Phone': false,
    'CNIC': false,
    'Exact': false,
  };

  final Map<String, bool> _productFilters = {
    'Name': true,
    'SKU': false,
    'Exact': false,
  };

  @override
  void initState() {
    super.initState();
    if (widget.editSale != null) {
      _selectedLocation = widget.editSale!.location;
      _selectedCustomer = widget.editSale!.customerName ?? 'Walk In Customer';
      _paymentMethod = widget.editSale!.paymentMethod;
      _discountCtrl.text = widget.editSale!.discount.toStringAsFixed(0);
      _cashReceivedCtrl.text = widget.editSale!.paidAmount.toStringAsFixed(0);
      _notesCtrl.text = widget.editSale!.notes ?? '';
      _isAmountReceivedManuallyEdited = true;

      for (var item in widget.editSale!.items) {
        _cart.add({
          'id': item.sku ?? item.productName,
          'name': item.productName,
          'qty': item.qty,
          'price': item.price,
        });
      }
    }
  }

  double get _subTotal => _cart.fold(0, (sum, item) => sum + (item['price'] * item['qty']));
  double get _discount => double.tryParse(_discountCtrl.text) ?? 0;
  double get _netTotal => _subTotal - _discount;

  double get _prevDue {
    final customerState = ref.read(customersListProvider);
    if (customerState.value != null && _selectedCustomer != 'Walk In Customer') {
      final c = customerState.value!.firstWhere(
        (c) => c.name == _selectedCustomer,
        orElse: () => CustomerModel(id: '', name: ''),
      );
      return c.balance;
    }
    return 0.0;
  }

  double get _grandTotal => _netTotal + _prevDue;
  double get _cashReceived => double.tryParse(_cashReceivedCtrl.text) ?? 0;
  double get _change => _cashReceived > _grandTotal ? _cashReceived - _grandTotal : 0.0;
  double get _dueRemaining => _grandTotal - _cashReceived > 0 ? _grandTotal - _cashReceived : 0.0;

  @override
  Widget build(BuildContext context) {
    // Fetch dynamic customers
    final customerState = ref.watch(customersListProvider);
    final customers = ['Walk In Customer'];
    if (customerState.value != null) {
      for (var c in customerState.value!) {
        if (!customers.contains(c.name)) {
          customers.add(c.name);
        }
      }
    }
    // Ensure selected customer is valid
    if (!customers.contains(_selectedCustomer)) {
      _selectedCustomer = 'Walk In Customer';
    }

    CustomerModel? activeCust;
    if (customerState.value != null && _selectedCustomer != 'Walk In Customer') {
      activeCust = customerState.value!.firstWhere(
        (c) => c.name == _selectedCustomer,
        orElse: () => CustomerModel(id: '', name: ''),
      );
    }

    // Fetch dynamic products
    final productState = ref.watch(productsListProvider);
    final products = productState.value ?? [];

    // Default amount received controller to grand total if not manually edited
    if (!_isAmountReceivedManuallyEdited) {
      _cashReceivedCtrl.text = _grandTotal.toStringAsFixed(0);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFf1f5f9),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Product Entry
                Expanded(
                  flex: 7,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCustomerSection(customers, activeCust, customerState.value),
                        const SizedBox(height: 16),
                        _buildProductSearchSection(products),
                        const SizedBox(height: 16),
                        _buildProductTable(),
                      ],
                    ),
                  ),
                ),
                // Right Column: Checkout
                _buildCheckoutSidebar(),
              ],
            ),
          ),
          _buildFooterBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10b981), Color(0xFF059669)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          const Text('Location:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLocation,
                items: ['Default', 'Warehouse A'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setState(() => _selectedLocation = v!),
              ),
            ),
          ),
          const Spacer(),
          Image.network('https://lajpaltraders.bosonstudio.com/uploads/business_logos/1715082054_nayia_swaria_logo.png', height: 40, errorBuilder: (c, e, s) => const Icon(Icons.business, color: Colors.white)),
          const SizedBox(width: 8),
          const Text('| Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          _topIcon(Icons.attach_money),
          _topIcon(Icons.keyboard),
          _topIcon(Icons.receipt_long),
          _topIcon(Icons.inventory_2),
          _topIcon(Icons.settings),
          _topIcon(Icons.exit_to_app, color: Colors.redAccent, onTap: () => context.go('/dashboard')),
        ],
      ),
    );
  }

  Widget _topIcon(IconData icon, {Color color = Colors.white, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildCustomerSection(List<String> customers, CustomerModel? activeCust, List<CustomerModel>? customerList) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Customer (Alt+C)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
              const Spacer(),
              ..._customerFilters.entries.map((e) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: Checkbox(value: e.value, onChanged: (v) => setState(() => _customerFilters[e.key] = v!))),
                    const SizedBox(width: 4),
                    Text(e.key, style: const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
                  ],
                ),
              )).toList(),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCustomer,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF94a3b8)),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'Walk In Customer',
                    child: Text('Walk In Customer', style: TextStyle(fontSize: 13)),
                  ),
                  if (customerList != null)
                    ...customerList.map((c) {
                      String dueText = '';
                      if (c.balance > 0) {
                        dueText = ' | Due: Rs ${c.balance.toStringAsFixed(0)}';
                      } else if (c.balance < 0) {
                        dueText = ' | Advance: Rs ${(-c.balance).toStringAsFixed(0)}';
                      }
                      return DropdownMenuItem<String>(
                        value: c.name,
                        child: Text('${c.name}$dueText', style: const TextStyle(fontSize: 13)),
                      );
                    }),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedCustomer = v!;
                    _isAmountReceivedManuallyEdited = false;
                  });
                },
              ),
            ),
          ),
          if (activeCust != null && activeCust.id.isNotEmpty && activeCust.balance != 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: activeCust.balance > 0 ? const Color(0xFFfef2f2) : const Color(0xFFf0fdf4),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: activeCust.balance > 0 ? const Color(0xFFfee2e2) : const Color(0xFFdcfce7),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    activeCust.balance > 0 ? Icons.info_outline : Icons.check_circle_outline,
                    size: 16,
                    color: activeCust.balance > 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Previous Balance (Khata): ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: activeCust.balance > 0 ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                  ),
                  Text(
                    '${activeCust.balance > 0 ? "-" : "+"}Rs ${activeCust.balance.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: activeCust.balance > 0 ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    activeCust.balance > 0 ? '(Receivable / Lena hai)' : '(Prepaid/Advance / Dena hai)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: activeCust.balance > 0 ? Colors.red.shade600 : Colors.green.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sale Date (Ctrl+D)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
                      child: const Row(
                        children: [
                          Text('May 16, 2026 10:44 PM', style: TextStyle(fontSize: 13)),
                          Spacer(),
                          Icon(Icons.close, size: 16, color: Color(0xFF94a3b8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saleman (Alt+U)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 8),
                    _buildSearchDropdown(_selectedSalesman, (v) => setState(() => _selectedSalesman = v!), 'Select Saleman', ['Admin']),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchSection(List<ProductModel> products) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Search Products (Ctrl+Enter)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
              const Spacer(),
              ..._productFilters.entries.map((e) => Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: Checkbox(value: e.value, onChanged: (v) => setState(() => _productFilters[e.key] = v!))),
                    const SizedBox(width: 4),
                    Text(e.key, style: const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
                  ],
                ),
              )).toList(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Enter Product Name OR SKU to search', style: TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF94a3b8)),
                      items: products.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text('${p.name} (SKU: ${p.sku ?? ''}) - Rs ${p.price}', style: const TextStyle(fontSize: 13)),
                      )).toList(),
                      onChanged: (productId) {
                        if (productId == null) return;
                        final prod = products.firstWhere((p) => p.id == productId);
                        final existingIdx = _cart.indexWhere((item) => item['id'] == prod.id);
                        if (existingIdx != -1) {
                          setState(() {
                            _cart[existingIdx]['qty'] += 1;
                          });
                        } else {
                          setState(() {
                            _cart.add({
                              'id': prod.id,
                              'name': prod.name,
                              'qty': 1,
                              'price': prod.price,
                            });
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF1e293b), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(color: Color(0xFFf8fafc), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text('SR. #', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(flex: 3, child: Text('NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(child: Text('QUANTITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(child: Text('PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(child: Text('DISCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                Expanded(child: Text('TOTAL PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                SizedBox(width: 80, child: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
              ],
            ),
          ),
          if (_cart.isEmpty)
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 48, color: Colors.blue.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  const Text('No Data Found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  const Text('There is no data found for this resource', style: TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final item = _cart[index];
                return _CartItemRow(
                  key: ValueKey(item['id']),
                  index: index,
                  item: item,
                  onDelete: () => setState(() => _cart.removeAt(index)),
                  onQtyChanged: (q) => setState(() => item['qty'] = q),
                  onPriceChanged: (p) => setState(() => item['price'] = p),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSidebar() {
    return Container(
      width: 350,
      decoration: const BoxDecoration(color: Colors.white, border: Border(left: BorderSide(color: Color(0xFFe2e8f0)))),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckoutField('Discount (Alt+D)', _discountCtrl, suffix: const Icon(Icons.percent, size: 16)),
                  const SizedBox(height: 16),
                  const Text('Payment Method (Alt+M)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  const SizedBox(height: 8),
                  _buildSearchDropdown(_paymentMethod, (v) => setState(() => _paymentMethod = v!), 'Select Method', ['Cash', 'Bank Transfer', 'Card']),
                  const SizedBox(height: 16),
                  _buildCheckoutField(
                    'Cash Received (Amount Given by Customer)',
                    _cashReceivedCtrl,
                    prefix: const Text('Rs ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                    onChanged: (val) {
                      setState(() {
                        _isAmountReceivedManuallyEdited = true;
                      });
                    },
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rs ${_grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF1e293b))),
                        if (_prevDue > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Due Included: Rs ${_prevDue.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFf59e0b)),
                          ),
                        ] else if (_prevDue < 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Advance Deducted: Rs ${(-_prevDue).toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10b981)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _quickCash('+100', 100),
                      _quickCash('+500', 500),
                      _quickCash('+1,000', 1000),
                      _quickCash('+5,000', 5000),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildCheckoutField('Notes', _notesCtrl, maxLines: 3),
                  const SizedBox(height: 32),
                  // Summary Totals
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf8fafc),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFe2e8f0)),
                    ),
                    child: Column(
                      children: [
                        _summaryRow('Subtotal', 'Rs ${_subTotal.toStringAsFixed(0)}', color: const Color(0xFF475569)),
                        if (_discount > 0) _summaryRow('Discount', '- Rs ${_discount.toStringAsFixed(0)}', color: const Color(0xFFef4444)),
                        _summaryRow('Net Total (Items)', 'Rs ${_netTotal.toStringAsFixed(0)}', color: const Color(0xFF1e293b), bold: true),
                        if (_prevDue > 0) _summaryRow('Prev. Due (Khata)', '+ Rs ${_prevDue.toStringAsFixed(0)}', color: const Color(0xFFef4444)),
                        if (_prevDue < 0) _summaryRow('Advance Credit', '- Rs ${(-_prevDue).toStringAsFixed(0)}', color: const Color(0xFF10b981)),
                        const Divider(height: 16),
                        _summaryRow('Grand Total', 'Rs ${_grandTotal.toStringAsFixed(0)}', color: const Color(0xFF6d28d9), bold: true, large: true),
                        const Divider(height: 16),
                        _summaryRow('Cash Received', 'Rs ${_cashReceived.toStringAsFixed(0)}', color: const Color(0xFF1e293b)),
                        if (_dueRemaining > 0)
                          _summaryRow('Due Remaining', 'Rs ${_dueRemaining.toStringAsFixed(0)}', color: const Color(0xFFef4444), bold: true),
                        if (_change > 0)
                          _summaryRow('Change (Return)', 'Rs ${_change.toStringAsFixed(0)}', color: const Color(0xFF10b981), bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _actionButton('Save (Alt+Enter)', const Color(0xFF10b981), () async {
                        if (_cart.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty!'), backgroundColor: Colors.red));
                          return;
                        }
                        final paidAmount = _cashReceived > _grandTotal ? _grandTotal : _cashReceived;
                        final pendingAmount = _dueRemaining; // what customer still owes
                        
                        String? resolvedCustomerId;
                        if (_selectedCustomer != 'Walk In Customer') {
                          final customerList = ref.read(customersListProvider).value;
                          if (customerList != null) {
                            final cust = customerList.firstWhere(
                              (c) => c.name == _selectedCustomer,
                              orElse: () => CustomerModel(id: '', name: ''),
                            );
                            if (cust.id.isNotEmpty) {
                              resolvedCustomerId = cust.id;
                            }
                          }
                        }

                        final saleId = widget.editSale?.id ?? const Uuid().v4();
                        final invoiceNo = widget.editSale?.invoiceNo ?? 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                        final newSale = SaleModel(
                          id: saleId,
                          invoiceNo: invoiceNo,
                          customerId: resolvedCustomerId,
                          customerName: _selectedCustomer,
                          location: _selectedLocation,
                          saleDate: widget.editSale?.saleDate ?? DateTime.now().toIso8601String(),
                          subtotal: _subTotal,
                          discount: _discount,
                          netTotal: _netTotal,
                          paidAmount: paidAmount,
                          pendingAmount: pendingAmount,
                          paymentMethod: _paymentMethod,
                          notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
                          items: _cart.map((item) => SaleItemModel(
                            productName: item['name'],
                            qty: item['qty'],
                            price: item['price'],
                            totalPrice: item['price'] * item['qty'],
                          )).toList(),
                        );
                        
                        final success = widget.editSale != null 
                            ? await ref.read(salesListProvider.notifier).updateSale(newSale)
                            : await ref.read(salesListProvider.notifier).addSale(newSale);

                        if (success && mounted) {
                          // Update Customer Balance/Ledger
                          if (_selectedCustomer != 'Walk In Customer') {
                            final customerList = ref.read(customersListProvider).value;
                            if (customerList != null) {
                              final cust = customerList.firstWhere(
                                (c) => c.name == _selectedCustomer,
                                orElse: () => CustomerModel(id: '', name: ''),
                              );
                              if (cust.id.isNotEmpty) {
                                double newBalance = cust.balance;
                                if (widget.editSale != null) {
                                  if (widget.editSale!.customerName == _selectedCustomer) {
                                    // Same customer: subtract old pending and add new pending
                                    newBalance = cust.balance - widget.editSale!.pendingAmount + pendingAmount;
                                  } else {
                                    // Customer changed: add new pending to this customer
                                    newBalance = cust.balance + pendingAmount;
                                    
                                    // Remove old pending from previous customer
                                    if (widget.editSale!.customerName != null && widget.editSale!.customerName != 'Walk In Customer') {
                                      final oldCust = customerList.firstWhere(
                                        (c) => c.name == widget.editSale!.customerName,
                                        orElse: () => CustomerModel(id: '', name: ''),
                                      );
                                      if (oldCust.id.isNotEmpty) {
                                        final correctedOldCust = oldCust.copyWith(
                                          balance: oldCust.balance - widget.editSale!.pendingAmount,
                                          synced: false,
                                        );
                                        await ref.read(customersListProvider.notifier).updateCustomer(correctedOldCust);
                                      }
                                    }
                                  }
                                } else {
                                  // Brand new sale: increase by new pending amount
                                  newBalance = cust.balance + pendingAmount;
                                }
                                final updatedCust = cust.copyWith(
                                  balance: newBalance,
                                  synced: false,
                                );
                                await ref.read(customersListProvider.notifier).updateCustomer(updatedCust);
                              }
                            }
                          } else {
                            // If user changed customer to Walk In Customer during edit, subtract pending from old customer
                            if (widget.editSale != null && widget.editSale!.customerName != null && widget.editSale!.customerName != 'Walk In Customer') {
                              final customerList = ref.read(customersListProvider).value;
                              if (customerList != null) {
                                final oldCust = customerList.firstWhere(
                                  (c) => c.name == widget.editSale!.customerName,
                                  orElse: () => CustomerModel(id: '', name: ''),
                                );
                                if (oldCust.id.isNotEmpty) {
                                  final correctedOldCust = oldCust.copyWith(
                                    balance: oldCust.balance - widget.editSale!.pendingAmount,
                                    synced: false,
                                  );
                                  await ref.read(customersListProvider.notifier).updateCustomer(correctedOldCust);
                                }
                              }
                            }
                          }


                          // Clear UI State
                          setState(() {
                            _cart.clear();
                            _discountCtrl.text = '0';
                            _cashReceivedCtrl.text = '0';
                            _notesCtrl.clear();
                            _isAmountReceivedManuallyEdited = false;
                          });

                          // Show Invoice Modal
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => InvoiceDialog(sale: newSale),
                          );
                        }
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: _actionButton('Clear (Alt+Delete)', const Color(0xFFef4444), () {
                        setState(() {
                          _cart.clear();
                          _isAmountReceivedManuallyEdited = false;
                        });
                      })),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color, bool bold = false, bool large = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: large ? 14 : 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF64748b))),
          Text(value, style: TextStyle(fontSize: large ? 16 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: color ?? const Color(0xFF1e293b))),
        ],
      ),
    );
  }

  Widget _buildCheckoutField(String label, TextEditingController ctrl, {Widget? prefix, Widget? suffix, int maxLines = 1, bool enabled = true, ValueChanged<String>? onChanged, TextStyle? style}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          enabled: enabled,
          onChanged: onChanged,
          style: style,
          decoration: InputDecoration(
            prefixIcon: prefix != null ? UnconstrainedBox(child: prefix) : null,
            suffixIcon: suffix,
            filled: true,
            fillColor: enabled ? const Color(0xFFf8fafc) : const Color(0xFFf1f5f9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchDropdown(String value, ValueChanged<String?> onChanged, String hint, List<String> items) {
    final List<String> dropdownItems = items.contains(value) ? items : [value, ...items];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF94a3b8)),
          items: dropdownItems.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _quickCash(String label, double amount) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: () {
            double current = double.tryParse(_cashReceivedCtrl.text) ?? 0;
            setState(() => _cashReceivedCtrl.text = (current + amount).toStringAsFixed(0));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFe2e8f0))),
            child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFe2e8f0)))),
      child: const Row(
        children: [
          Icon(Icons.business, size: 14, color: Color(0xFF94a3b8)),
          SizedBox(width: 4),
          Text('Boson Studio', style: TextStyle(fontSize: 11, color: Color(0xFF64748b))),
          SizedBox(width: 12),
          Icon(Icons.phone, size: 14, color: Color(0xFF94a3b8)),
          SizedBox(width: 4),
          Text('+923068216606', style: TextStyle(fontSize: 11, color: Color(0xFF64748b))),
          Spacer(),
          Text('All Rights Reserved © 2026', style: TextStyle(fontSize: 11, color: Color(0xFF64748b))),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatefulWidget {
  final int index;
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final ValueChanged<int> onQtyChanged;
  final ValueChanged<double> onPriceChanged;

  const _CartItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.onDelete,
    required this.onQtyChanged,
    required this.onPriceChanged,
  });

  @override
  State<_CartItemRow> createState() => _CartItemRowState();
}

class _CartItemRowState extends State<_CartItemRow> {
  late TextEditingController _qtyCtrl;
  late TextEditingController _priceCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '${widget.item['qty']}');
    _priceCtrl = TextEditingController(text: '${widget.item['price']}');
  }

  @override
  void didUpdateWidget(covariant _CartItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (int.tryParse(_qtyCtrl.text) != widget.item['qty']) {
      _qtyCtrl.text = '${widget.item['qty']}';
    }
    if (double.tryParse(_priceCtrl.text) != widget.item['price']) {
      _priceCtrl.text = '${widget.item['price']}';
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFe2e8f0)))),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text('${widget.index + 1}', style: const TextStyle(fontSize: 13))),
          Expanded(flex: 3, child: Text(widget.item['name'], style: const TextStyle(fontSize: 13))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    final q = int.tryParse(val) ?? 1;
                    widget.onQtyChanged(q);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixText: 'Rs ',
                  ),
                  onChanged: (val) {
                    final p = double.tryParse(val) ?? 0.0;
                    widget.onPriceChanged(p);
                  },
                ),
              ),
            ),
          ),
          const Expanded(child: Center(child: Text('0', style: TextStyle(fontSize: 13)))),
          Expanded(
            child: Center(
              child: Text(
                'Rs ${(widget.item['price'] * widget.item['qty']).toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              onPressed: widget.onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
