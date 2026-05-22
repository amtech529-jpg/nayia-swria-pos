import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';

class ProductHistoryScreen extends StatefulWidget {
  const ProductHistoryScreen({super.key});

  @override
  State<ProductHistoryScreen> createState() => _ProductHistoryScreenState();
}

class _ProductHistoryScreenState extends State<ProductHistoryScreen> {
  bool _searchByName = false;
  bool _searchBySKU = false;
  bool _searchByExact = true;
  final String _selectedLocation = 'Business Location';

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/product-history',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 16, color: Color(0xFF64748b)),
                const SizedBox(width: 8),
                _breadcrumbItem('Products'),
                _breadcrumbDivider(),
                _breadcrumbItem('Product history', isLast: true),
              ],
            ),
            const SizedBox(height: 24),

            // Main Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Column(
                children: [
                  // Top Controls Section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checkboxes Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _checkOption('Name', _searchByName, (v) => setState(() => _searchByName = v!)),
                            const SizedBox(width: 24),
                            _checkOption('SKU', _searchBySKU, (v) => setState(() => _searchBySKU = v!)),
                            const SizedBox(width: 24),
                            _checkOption('Exact', _searchByExact, (v) => setState(() => _searchByExact = v!)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Search & Location Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildSearchDropdown(),
                            ),
                            const SizedBox(width: 12),
                            _addBtn(),
                            const Spacer(),
                            _buildLocationDrop(),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Summary Info Bar
                        _buildSummaryBar(),
                      ],
                    ),
                  ),

                  // Table
                  const PosTable(
                    columns: ['', 'TYPE', 'QUANTITY CHANGE', 'NEW QUANTITY', 'DATE'],
                    columnWidths: [50, 250, 250, 250, 250],
                    rows: [], // Empty state demonstration
                    selectable: true,
                  ),

                  // Empty State
                  _buildEmptyState(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter Product Name OR SKU to search',
                hintStyle: TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Color(0xFF64748b)),
        ],
      ),
    );
  }

  Widget _addBtn() {
    return InkWell(
      onTap: () => _showAddProductModal(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF0f172a),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }

  void _showAddProductModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          width: 1200,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: const Color(0xFFf8f9fa),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 20, color: Color(0xFF64748b)),
                    ),
                  ],
                ),
              ),

              // Form Body with ScrollView
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Col 1
                      Expanded(
                        child: Column(
                          children: [
                            _modalField('Name*', hint: 'Name'),
                            const SizedBox(height: 16),
                            _modalDrop('Business Locations*', 'Default', hasTag: true),
                            const SizedBox(height: 16),
                            _modalField('Margin', hint: '% 0'),
                            const SizedBox(height: 16),
                            _modalDrop('Categories', 'Categories'),
                            const SizedBox(height: 16),
                            _modalField('Opening Stock*', hint: '0'),
                            const SizedBox(height: 16),
                            _modalDrop('Sale Unit*', 'Sale Unit'),
                            const SizedBox(height: 16),
                            _modalDrop('Extra Units*', 'Extra Units'),
                            const SizedBox(height: 16),
                            _modalDrop('Status', 'Active'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Col 2
                      Expanded(
                        child: Column(
                          children: [
                            _modalField('SKU', hint: '0277'),
                            const SizedBox(height: 16),
                            _modalField('Cost*', hint: 'Rs 0'),
                            const SizedBox(height: 16),
                            _modalField('Price*', hint: 'Rs 0'),
                            const SizedBox(height: 16),
                            _modalField('Alert Quantity', hint: '1'),
                            const SizedBox(height: 16),
                            _modalDrop('Base Unit*', 'Base Unit'),
                            const SizedBox(height: 16),
                            _modalDrop('Purchase Unit*', 'Purchase Unit'),
                            const SizedBox(height: 16),
                            _modalDrop('Brand', 'Brand'),
                            const SizedBox(height: 16),
                            _modalField('Days In Expiry', hint: 'Days In Expiry'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Col 3
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _modalField('Notes', hint: 'Notes', maxLines: 5),
                            const SizedBox(height: 20),
                            const Text('Product Image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFf8fafc),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFe2e8f0)),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Click to upload or drag and drop', style: TextStyle(color: Color(0xFF64748b), fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    _modalBtn('Cancel', isSecondary: true, onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    _modalBtn('Save', onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalField(String label, {required String hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
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

  Widget _modalDrop(String label, String value, {bool hasTag = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFf8fafc),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: Row(
            children: [
              if (hasTag)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF10b981), borderRadius: BorderRadius.circular(4)),
                  child: const Row(
                    children: [
                      Text('Default', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.close, size: 12, color: Colors.white),
                    ],
                  ),
                )
              else
                Text(value, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _modalBtn(String label, {bool isSecondary = false, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.white : const Color(0xFF0f172a),
        foregroundColor: isSecondary ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: isSecondary ? const BorderSide(color: Color(0xFFe2e8f0)) : BorderSide.none),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildLocationDrop() {
    return Container(
      width: 200,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFcbd5e1)),
      ),
      child: Row(
        children: [
          Text(_selectedLocation, style: const TextStyle(color: Color(0xFF64748b), fontSize: 13)),
          const Spacer(),
          const Icon(Icons.arrow_drop_down, color: Color(0xFF64748b)),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFf1f5f9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _summaryCol('Opening Stock:', 'Total Sold:')),
          Expanded(child: _summaryCol('+ Total Purchased:', '- Total Returned:')),
          Expanded(child: _summaryCol('+ Total Purchase Returned:', '+ Total Stock:')),
          const Text('-', style: TextStyle(color: Color(0xFF64748b))),
        ],
      ),
    );
  }

  Widget _summaryCol(String line1, String line2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(line1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        Text(line2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
      ],
    );
  }

  Widget _checkOption(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFcbd5e1)),
            activeColor: const Color(0xFF2563eb),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: const Color(0xFFe2e8f0).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.folder_open_outlined, size: 30, color: Color(0xFF94a3b8)),
        ),
        const SizedBox(height: 16),
        const Text('No Data Found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
        const SizedBox(height: 4),
        const Text('There is no data found for this resource', style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
      ],
    );
  }

  Widget _breadcrumbItem(String label, {bool isLast = false}) {
    return Text(label, style: TextStyle(fontSize: 12, fontWeight: isLast ? FontWeight.w700 : FontWeight.w400, color: isLast ? const Color(0xFF1e293b) : const Color(0xFF64748b)));
  }

  Widget _breadcrumbDivider() {
    return const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_right, size: 14, color: Color(0xFFcbd5e1)));
  }
}
