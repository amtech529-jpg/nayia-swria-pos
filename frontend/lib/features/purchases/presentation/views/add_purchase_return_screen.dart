import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/purchases/data/models/purchase_return_model.dart';
import 'package:frontend/features/purchases/presentation/providers/purchase_returns_provider.dart';

class AddPurchaseReturnScreen extends ConsumerStatefulWidget {
  const AddPurchaseReturnScreen({super.key});

  @override
  ConsumerState<AddPurchaseReturnScreen> createState() => _AddPurchaseReturnScreenState();
}

class _AddPurchaseReturnScreenState extends ConsumerState<AddPurchaseReturnScreen> {
  final _searchCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: 'May 17, 2026 01:12 AM');
  final _notesCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/purchase-return/create',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Add Purchase Return']),
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
                  const Text('Add Purchase Return', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildDrop('Business Location*', 'Default')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildDrop('Supplier*', 'Walk In Supplier')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildField('Reference', _refCtrl, hint: 'Reference')),
                      const SizedBox(width: 24),
                      Expanded(child: _buildField('Purchase Return Date', _dateCtrl, hasIcon: true)),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _checkOption('Name', false),
                      const SizedBox(width: 12),
                      _checkOption('SKU', true),
                      const SizedBox(width: 12),
                      _checkOption('Exact', false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFf8fafc),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFe2e8f0)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter Product Name OR SKU to search',
                                    hintStyle: TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748b)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Items Table
                  PosTable(
                    columns: const ['NAME', 'QUANTITY', 'UNIT PRICE', 'TOTAL PRICE', 'ACTIONS'],
                    columnWidths: const [400, 200, 200, 200, 80],
                    rows: [
                      [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('product name here', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
                            const Text('gms (Bought: 109 Pc)', style: TextStyle(fontSize: 11, color: Color(0xFF64748b))),
                            Text('SKU: 64897', style: TextStyle(fontSize: 11, color: const Color(0xFF2563eb).withOpacity(0.7))),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 60, height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(6)),
                              child: const Text('1', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text('Pc', style: TextStyle(fontSize: 12, color: Color(0xFF64748b))),
                            const Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF64748b)),
                          ],
                        ),
                        Container(
                          width: 120, height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFe2e8f0))),
                          child: const Row(children: [Text('Rs ', style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8))), Expanded(child: Text('500', style: TextStyle(fontSize: 13)))]),
                        ),
                        const Text('Rs 500', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                      ],
                      // Subtotal row
                      [
                        const SizedBox(),
                        const SizedBox(),
                        const SizedBox(),
                        const Align(alignment: Alignment.centerRight, child: Text('total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                        const Text('Rs 500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () async {
                  final newReturn = PurchaseReturnModel(
                    id: '',
                    returnNo: 'PR-RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                    returnDate: DateTime.now().toIso8601String(),
                    totalAmount: 500.0,
                    reason: _notesCtrl.text,
                    items: [
                      PurchaseReturnItemModel(productName: 'product name here', qty: 1, price: 500.0, totalPrice: 500.0)
                    ]
                  );
                  
                  final success = await ref.read(purchaseReturnsProvider.notifier).addPurchaseReturn(newReturn);
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase Return Added Successfully!')));
                    context.go('/purchase-return');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Submit Return', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {String hint = '', bool hasIcon = false, String prefix = '', int maxLines = 1}) {
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
          child: Row(
            children: [
              if (prefix.isNotEmpty) Text(prefix, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  maxLines: maxLines,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13), border: InputBorder.none),
                ),
              ),
              if (hasIcon) const Icon(Icons.close, size: 16, color: Color(0xFF64748b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDrop(String label, String value, {bool isSimple = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          const SizedBox(height: 8),
        ],
        Container(
          height: isSimple ? null : 44,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFf8fafc),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFe2e8f0)),
          ),
          child: Row(
            children: [
              Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF334155), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _checkOption(String label, bool value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24, height: 24,
          child: Checkbox(
            value: value, 
            onChanged: (v) {},
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFcbd5e1)),
            activeColor: const Color(0xFF2563eb),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748b))),
      ],
    );
  }
}
