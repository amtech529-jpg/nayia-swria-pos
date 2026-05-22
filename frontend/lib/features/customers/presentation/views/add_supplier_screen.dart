import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/storage/offline_service.dart';
import 'package:frontend/core/network/sync_service.dart';
import 'package:frontend/features/suppliers/data/models/supplier_model.dart';
import 'package:frontend/features/suppliers/presentation/providers/suppliers_provider.dart';
import 'package:go_router/go_router.dart';

class AddSupplierScreen extends ConsumerStatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  ConsumerState<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends ConsumerState<AddSupplierScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '0');
  final _emailCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _balanceCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/suppliers/create',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Add Suppliers']),
            const SizedBox(height: 24),

            // Main Form Card
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
                  const Text('Add Supplier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(child: _buildField('Name*', _nameCtrl, hint: 'Name')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('Phone Number*', _phoneCtrl, hint: '0')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _buildField('Email', _emailCtrl, hint: 'Email')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('CNIC Number', _cnicCtrl, hint: 'CNIC Number')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _buildField('Opening Balance*', _balanceCtrl, prefix: 'Rs ')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildDrop('Business Locations*', 'Default', hasTag: true)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _buildField('Notes', _notesCtrl, hint: 'Notes', maxLines: 5)),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('Address', _addressCtrl, hint: 'Address', maxLines: 5)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // File Upload Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: const Color(0xFFeff6ff), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Choose File', style: TextStyle(color: Color(0xFF2563eb), fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          const Text('No file chosen', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Footer Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _btn('Cancel', isOutlined: true, onTap: () => context.go('/suppliers')),
                      const SizedBox(width: 12),
                      _btn(
                        'Submit',
                        onTap: () async {
                          if (_nameCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name is required')),
                            );
                            return;
                          }
                          try {
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
                                    Text('Saving Supplier...'),
                                  ],
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            final supplier = SupplierModel(
                              id: OfflineService.generateId(),
                              name: _nameCtrl.text,
                              email: _emailCtrl.text,
                              phone: _phoneCtrl.text,
                              address: _addressCtrl.text,
                              purchaseTotal: double.tryParse(_balanceCtrl.text) ?? 0.0,
                            );

                            await ref.read(suppliersListProvider.notifier).addSupplier(supplier);
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Supplier Added Successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) context.go('/suppliers');
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

  Widget _buildField(String label, TextEditingController ctrl, {String hint = '', String prefix = '', int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
            prefixText: prefix.isNotEmpty ? prefix : null,
            prefixStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
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

  Widget _buildDrop(String label, String value, {bool hasTag = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  decoration: BoxDecoration(color: const Color(0xFF22c55e), borderRadius: BorderRadius.circular(4)),
                  child: const Row(
                    children: [
                      Text('Default', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.close, size: 12, color: Colors.white),
                    ],
                  ),
                )
              else
                Text(value, style: const TextStyle(color: Color(0xFF334155), fontSize: 13)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _btn(String label, {bool isOutlined = false, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.white : const Color(0xFF0f172a),
        foregroundColor: isOutlined ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isOutlined ? const BorderSide(color: Color(0xFFe2e8f0)) : BorderSide.none,
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}
