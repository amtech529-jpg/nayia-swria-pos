import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:frontend/features/inventory/data/models/product_model.dart';
import 'package:frontend/features/inventory/presentation/providers/products_provider.dart';
import 'package:frontend/features/inventory/presentation/providers/categories_provider.dart';
import 'package:frontend/features/inventory/presentation/providers/units_provider.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:go_router/go_router.dart';

class CreateProductScreen extends ConsumerStatefulWidget {
  const CreateProductScreen({super.key});

  @override
  ConsumerState<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  // Controllers
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController(text: '0277');
  final _marginCtrl = TextEditingController(text: '0');
  final _costCtrl = TextEditingController(text: '0');
  final _priceCtrl = TextEditingController(text: '0');
  final _openingStockCtrl = TextEditingController(text: '0');
  final _alertQtyCtrl = TextEditingController(text: '1');
  final _expiryCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Dropdown values
  String _location = 'Default';
  String _category = 'Categories';
  String _saleUnit = 'Sale Unit';
  String _extraUnits = 'Extra Units';
  String _status = 'Active';
  String _baseUnit = 'Base Unit';
  String _purchaseUnit = 'Purchase Unit';
  String _brand = 'Brand';

  @override
  Widget build(BuildContext context) {
    // Load dynamic categories
    final categoryState = ref.watch(categoriesListProvider);
    final categoryList = ['Categories'];
    final categoryMap = <String, String>{};
    if (categoryState.value != null) {
      for (var c in categoryState.value!) {
        if (!categoryList.contains(c.name)) {
          categoryList.add(c.name);
          categoryMap[c.name] = c.id;
        }
      }
    }

    // Load dynamic units
    final unitsState = ref.watch(unitsProvider);
    final List<String> availableUnits = ['Sale Unit'];
    final List<String> availableBaseUnits = ['Base Unit'];
    final List<String> availablePurchaseUnits = ['Purchase Unit'];
    final List<String> availableExtraUnits = ['Extra Units'];

    final defaultUnits = [
      'bori (35kg)', 'bori (10kg)', 'bori (20kg)', 'bori (25kg)', 'bori (34kg)', 'bori (40kg)', 'bori (50kg)', 'Pc', 'Kg', '1Ltr'
    ];

    if (unitsState.value != null && unitsState.value!.isNotEmpty) {
      for (var u in unitsState.value!) {
        final displayName = u.name;
        if (!availableUnits.contains(displayName)) availableUnits.add(displayName);
        if (!availableBaseUnits.contains(displayName)) availableBaseUnits.add(displayName);
        if (!availablePurchaseUnits.contains(displayName)) availablePurchaseUnits.add(displayName);
        if (!availableExtraUnits.contains(displayName)) availableExtraUnits.add(displayName);
      }
    } else {
      // Fallback to defaults
      for (var du in defaultUnits) {
        availableUnits.add(du);
        availableBaseUnits.add(du);
        availablePurchaseUnits.add(du);
        availableExtraUnits.add(du);
      }
    }

    // Ensure currently selected value is in the list
    if (!categoryList.contains(_category)) _category = 'Categories';
    if (!availableUnits.contains(_saleUnit)) _saleUnit = 'Sale Unit';
    if (!availableBaseUnits.contains(_baseUnit)) _baseUnit = 'Base Unit';
    if (!availablePurchaseUnits.contains(_purchaseUnit)) _purchaseUnit = 'Purchase Unit';
    if (!availableExtraUnits.contains(_extraUnits)) _extraUnits = 'Extra Units';

    return MainLayout(
      currentRoute: '/products',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                _breadcrumbItem('Home'),
                _breadcrumbDivider(),
                _breadcrumbItem('Products'),
                _breadcrumbDivider(),
                _breadcrumbItem('Add Product', isLast: true),
              ],
            ),
            const SizedBox(height: 24),

            // Main Content Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildField('Name*', _nameCtrl, hint: 'Name'),
                            const SizedBox(height: 16),
                            _buildLocationDrop('Business Locations*', _location),
                            const SizedBox(height: 16),
                            _buildField('Margin', _marginCtrl, prefix: '% '),
                            const SizedBox(height: 16),
                            _buildDrop('Categories', _category, categoryList, (v) => setState(() => _category = v!)),
                            const SizedBox(height: 16),
                            _buildField('Opening Stock*', _openingStockCtrl),
                            const SizedBox(height: 16),
                            _buildDrop('Sale Unit*', _saleUnit, availableUnits, (v) => setState(() => _saleUnit = v!)),
                            const SizedBox(height: 16),
                            _buildDrop('Extra Units*', _extraUnits, availableExtraUnits, (v) => setState(() => _extraUnits = v!)),
                            const SizedBox(height: 16),
                            _buildDrop('Status', _status, ['Active', 'Inactive'], (v) => setState(() => _status = v!)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Middle Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildField('SKU', _skuCtrl),
                            const SizedBox(height: 16),
                            _buildField('Cost*', _costCtrl, prefix: 'Rs '),
                            const SizedBox(height: 16),
                            _buildField('Price*', _priceCtrl, prefix: 'Rs '),
                            const SizedBox(height: 16),
                            _buildField('Alert Quantity', _alertQtyCtrl),
                            const SizedBox(height: 16),
                            _buildDrop('Base Unit*', _baseUnit, availableBaseUnits, (v) => setState(() => _baseUnit = v!)),
                            const SizedBox(height: 16),
                            _buildDrop('Purchase Unit*', _purchaseUnit, availablePurchaseUnits, (v) => setState(() => _purchaseUnit = v!)),
                            const SizedBox(height: 16),
                            _buildDrop('Brand', _brand, ['Brand', 'Nashia', 'Agrow Mark'], (v) => setState(() => _brand = v!)),
                            const SizedBox(height: 16),
                            _buildField('Days In Expiry', _expiryCtrl, hint: 'Days In Expiry'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextArea('Notes', _notesCtrl, hint: 'Notes'),
                            const SizedBox(height: 24),
                            const Text(
                              'Product Image',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildImageUploadZone(),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Bottom Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _btn('Cancel', isSecondary: true, onTap: () => context.pop()),
                      const SizedBox(width: 12),
                      _btn('Save', onTap: () async {
                        if (_nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Product name is required'), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        final product = ProductModel(
                          id: const Uuid().v4(),
                          name: _nameCtrl.text.trim(),
                          sku: _skuCtrl.text.trim(),
                          margin: double.tryParse(_marginCtrl.text) ?? 0.0,
                          categoryId: _category == 'Categories' ? null : categoryMap[_category],
                          categoryName: _category == 'Categories' ? null : _category,
                          cost: double.tryParse(_costCtrl.text) ?? 0.0,
                          price: double.tryParse(_priceCtrl.text) ?? 0.0,
                          openingStock: double.tryParse(_openingStockCtrl.text) ?? 0.0,
                          alertQty: double.tryParse(_alertQtyCtrl.text) ?? 1.0,
                          location: _location,
                          saleUnit: _saleUnit,
                          extraUnits: _extraUnits,
                          baseUnit: _baseUnit,
                          purchaseUnit: _purchaseUnit,
                          brand: _brand == 'Brand' ? null : _brand,
                          daysInExpiry: int.tryParse(_expiryCtrl.text) ?? 0,
                          status: _status,
                          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                        );
                        final success = await ref.read(productsListProvider.notifier).addProduct(product);
                        if (success && mounted) {
                          // Clear all fields
                          _nameCtrl.clear();
                          _skuCtrl.text = '0277';
                          _marginCtrl.text = '0';
                          _costCtrl.text = '0';
                          _priceCtrl.text = '0';
                          _openingStockCtrl.text = '0';
                          _alertQtyCtrl.text = '1';
                          _expiryCtrl.clear();
                          _notesCtrl.clear();
                          setState(() {
                            _location = 'Default';
                            _category = 'Categories';
                            _saleUnit = 'Sale Unit';
                            _extraUnits = 'Extra Units';
                            _status = 'Active';
                            _baseUnit = 'Base Unit';
                            _purchaseUnit = 'Purchase Unit';
                            _brand = 'Brand';
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Product saved successfully!'), backgroundColor: Color(0xFF10b981)),
                          );
                        }
                      }),
                      const SizedBox(width: 12),
                      _btn('Save & Manage Opening Stock', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breadcrumbItem(String label, {bool isLast = false}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
        color: isLast ? const Color(0xFF1e293b) : const Color(0xFF64748b),
      ),
    );
  }

  Widget _breadcrumbDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.chevron_right, size: 14, color: Color(0xFFcbd5e1)),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String? hint, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
            prefixText: prefix,
            prefixStyle: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600),
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

  Widget _buildTextArea(String label, TextEditingController ctrl, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
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

  Widget _buildDrop(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFf8fafc),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748b)),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1e293b)),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDrop(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFf8fafc),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.close, size: 12, color: Colors.white),
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

  Widget _buildImageUploadZone() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFcbd5e1), style: BorderStyle.solid), // In real css it's dashed, but border style dashed is not in Flutter
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 32, color: Color(0xFF94a3b8)),
          const SizedBox(height: 12),
          const Text(
            'Click to upload or drag and drop',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748b)),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, {bool isSecondary = false, required VoidCallback onTap}) {
    final bgColor = isSecondary ? Colors.white : const Color(0xFF0f172a);
    final textColor = isSecondary ? const Color(0xFF0f172a) : Colors.white;
    final borderColor = isSecondary ? const Color(0xFFe2e8f0) : Colors.transparent;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: borderColor),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}
