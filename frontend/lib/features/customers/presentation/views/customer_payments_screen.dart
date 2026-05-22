import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:go_router/go_router.dart';

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen> {
  String _selectedLocation = 'Business Locations';
  String _selectedManager = 'Area Manager';
  String _selectedArea = 'Area';
  String? _selectedCustomer = 'zulfiqar arain copy choti 446 S/O NA - 03000674160 - 03000674160 - NA - N/A - N/A';
  String _paymentMethod = 'Cash';
  
  final _amountCtrl = TextEditingController(text: '0');
  final _discountCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: 'May 16, 2026 05:00 AM');
  
  bool _useAdvance = true;
  final Map<String, bool> _searchOptions = {
    'Name': true,
    'Father Name': false,
    'Phone': false,
    'CNIC': false,
    'Address': false,
    'Connection ID': false,
    'Exact': false,
  };

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/customers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Customers', 'Payments']),
            const SizedBox(height: 20),
            
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
                  const Text('Collect Customer Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0f172a))),
                  const SizedBox(height: 24),
                  
                  // Row 1: Filters
                  Row(
                    children: [
                      Expanded(child: _buildDrop('Business Locations', _selectedLocation, ['Business Locations', 'Default', 'Warehouse A'], (v) => setState(() => _selectedLocation = v!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDrop('Area Manager', _selectedManager, ['Area Manager', 'Ali', 'Khan'], (v) => setState(() => _selectedManager = v!))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDrop('Area', _selectedArea, ['Area', 'Lahore', 'Multan'], (v) => setState(() => _selectedArea = v!))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Row 2: Customer Search & Options
                  Row(
                    children: [
                      const Text('Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const Spacer(),
                      ..._searchOptions.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: e.value, 
                                onChanged: (v) => setState(() => _searchOptions[e.key] = v!),
                                side: const BorderSide(color: Color(0xFFcbd5e1)),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(e.key, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf8fafc),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFe2e8f0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(_selectedCustomer ?? 'Search Customer...', style: const TextStyle(fontSize: 13, color: Color(0xFF1e293b)))),
                        const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748b)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Row 3: Amount, Discount, Payment Method
                  Row(
                    children: [
                      Expanded(child: _buildField('Amount', _amountCtrl, prefix: 'Rs ')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildField('Discount', _discountCtrl, prefix: 'Rs ')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDrop('Payment Method', _paymentMethod, ['Cash', 'Bank Transfer', 'Cheque', 'Online'], (v) => setState(() => _paymentMethod = v!))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(value: _useAdvance, onChanged: (v) => setState(() => _useAdvance = v!), side: const BorderSide(color: Color(0xFF0f172a))),
                      ),
                      const SizedBox(width: 8),
                      const Text('Use Advance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Row 4: Notes, Date, File
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildField('Notes', _notesCtrl, hint: 'Notes', maxLines: 4)),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField('Date', _dateCtrl, icon: Icons.close),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(20)),
                                  child: const Text('Choose File', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6366f1))),
                                ),
                                const SizedBox(width: 12),
                                const Text('No file chosen', style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Bottom Summary Sections
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Details Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: const Color(0xFFf1f5f9).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Customer Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0f172a))),
                              const SizedBox(height: 12),
                              _summaryRow('Customer Name:', 'Zulfiqar Arain Copy Choti 446'),
                              _summaryRow('Customer Father Name:', ''),
                              _summaryRow('Customer Email:', ''),
                              _summaryRow('Customer Phone:', '03000674160'),
                              _summaryRow('Customer CNIC:', ''),
                              _summaryRow('Customer Address:', '03000674160'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Financial Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: const Color(0xFFf1f5f9).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              _financialRow('Total Sale:', 'Rs 399,875'),
                              _financialRow('Total Paid:', 'Rs 399,875'),
                              _financialRow('Total Sale Due:', 'Rs 0'),
                              _financialRow('Opening Balance:', 'Rs 7,850'),
                              _financialRow('Opening Balance Dues:', 'Rs 0'),
                              _financialRow('Advance Balance:', 'Rs 0'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('CTRL + Enter to submit', style: TextStyle(fontSize: 11, color: Color(0xFFef4444))),
                      const SizedBox(width: 16),
                      PosButton(label: 'Submit', onTap: () {}),
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

  Widget _buildField(String label, TextEditingController ctrl, {String? hint, int maxLines = 1, String? prefix, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
            prefixText: prefix,
            prefixStyle: const TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600),
            suffixIcon: icon != null ? Icon(icon, size: 16, color: const Color(0xFF64748b)) : null,
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

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
        ],
      ),
    );
  }

  Widget _financialRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
        ],
      ),
    );
  }
}
