import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/storage/offline_service.dart';
import 'package:frontend/core/network/sync_service.dart';
import 'package:frontend/features/customers/data/models/customer_model.dart';
import 'package:frontend/features/customers/presentation/providers/customers_provider.dart';

class CreateCustomerScreen extends ConsumerStatefulWidget {
  final Map<String, String>? existing;
  const CreateCustomerScreen({super.key, this.existing});

  @override
  ConsumerState<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends ConsumerState<CreateCustomerScreen> {
  final _nameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController();
  
  String _selectedLocation = 'Default';
  String _selectedArea = 'None';

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!['name'] ?? '';
      _phoneCtrl.text = widget.existing!['phone'] ?? '';
      _addressCtrl.text = widget.existing!['address'] ?? '';
      _cnicCtrl.text = widget.existing!['cnic'] ?? '';
      _balanceCtrl.text = widget.existing!['balance'] ?? '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/customers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Customers', 'Add Customer']),
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
                  const Text('Add Customer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF0f172a))),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildField('Full Name *', _nameCtrl, hint: 'Enter customer name'),
                            const SizedBox(height: 20),
                            _buildField('Father Name', _fatherNameCtrl, hint: 'Enter father name'),
                            const SizedBox(height: 20),
                            _buildField('Phone Number', _phoneCtrl, hint: 'e.g. 03001234567'),
                            const SizedBox(height: 20),
                            _buildField('Email Address', _emailCtrl, hint: 'example@domain.com'),
                            const SizedBox(height: 20),
                            _buildField('CNIC Number', _cnicCtrl, hint: '35201-XXXXXXX-X'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildDropdown('Business Location *', _selectedLocation, ['Default', 'Warehouse A', 'Showroom'], (v) => setState(() => _selectedLocation = v!)),
                            const SizedBox(height: 20),
                            _buildDropdown('Area', _selectedArea, ['None', 'Lahore Central', 'Multan Road', 'Faisalabad'], (v) => setState(() => _selectedArea = v!)),
                            const SizedBox(height: 20),
                            _buildField('Address', _addressCtrl, hint: 'Enter full address', maxLines: 3),
                            const SizedBox(height: 20),
                            _buildField('Opening Balance (Rs)', _balanceCtrl, hint: '0.00', prefix: 'Rs '),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text('Customer Image', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                            const SizedBox(height: 12),
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFf8fafc),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFe2e8f0), style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.blue.shade400),
                                  const SizedBox(height: 8),
                                  const Text('Upload Image', style: TextStyle(fontSize: 12, color: Color(0xFF64748b))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: Color(0xFFf1f5f9)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PosButton(label: 'Cancel', outlined: true, onTap: () => context.pop()),
                      const SizedBox(width: 12),
                      PosButton(
                        label: 'Submit Customer',
                        onTap: () async {
                          if (_nameCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name is required')),
                            );
                            return;
                          }
                          try {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    ),
                                    SizedBox(width: 16),
                                    Text('Saving Customer...'),
                                  ],
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            final customer = CustomerModel(
                              id: OfflineService.generateId(),
                              name: _nameCtrl.text,
                              fatherName: _fatherNameCtrl.text,
                              phone: _phoneCtrl.text,
                              email: _emailCtrl.text,
                              cnic: _cnicCtrl.text,
                              address: _addressCtrl.text,
                              location: _selectedLocation,
                              area: _selectedArea,
                              balance: double.tryParse(_balanceCtrl.text) ?? 0.0,
                            );

                            await ref.read(customersListProvider.notifier).addCustomer(customer);
                            
                            _clearFields();

                            if (mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Customer Added Successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) context.go('/customers');
                              });
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                      ),
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

  Widget _buildField(String label, TextEditingController ctrl, {String? hint, int maxLines = 1, String? prefix}) {
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
            filled: true,
            fillColor: const Color(0xFFf8fafc),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF1e293b)),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _clearFields() {
    _nameCtrl.clear();
    _fatherNameCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _cnicCtrl.clear();
    _addressCtrl.clear();
    _balanceCtrl.clear();
    setState(() {
      _selectedLocation = 'Default';
      _selectedArea = 'None';
    });
  }
}
