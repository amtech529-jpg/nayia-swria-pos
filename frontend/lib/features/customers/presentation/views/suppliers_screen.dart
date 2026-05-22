import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/storage/offline_service.dart';
import 'package:frontend/core/network/sync_service.dart';
import 'package:frontend/features/suppliers/data/models/supplier_model.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final _searchCtrl = TextEditingController();
  final List<String> _columnLabels = [
    '', 'NAME', 'EMAIL', 'PHONE NUMBER', 'BUSINESS LOCATIONS', 'TOTAL PURCHASE', 'ACTIONS'
  ];

  final List<Map<String, String>> _data = [
    {'name': 'Orange protection', 'email': '', 'phone': '0', 'location': 'Default', 'purchase': 'Rs 104,820'},
    {'name': 'abbas tarar sunfort 75', 'email': '', 'phone': '03458225279', 'location': 'Default', 'purchase': 'Rs 69,600'},
    {'name': 'adnan & saver inter price 20', 'email': '', 'phone': '03436185434', 'location': 'Default', 'purchase': 'Rs 0'},
    {'name': 'amjad tarar 22', 'email': '', 'phone': '03426069155', 'location': 'Default', 'purchase': 'Rs 0'},
    {'name': 'azam gondal petron chemical 84 Inactive', 'email': '', 'phone': '03477688541', 'location': 'Default', 'purchase': 'Rs 0'},
    {'name': 'bilal tradar gala mandi 306', 'email': '', 'phone': '03452015030', 'location': 'Default', 'purchase': 'Rs 0'},
    {'name': 'khuram LAKIYA', 'email': '', 'phone': '03426667933', 'location': 'Default', 'purchase': 'Rs 138.08M'},
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/suppliers',
      child: FutureBuilder<List<SupplierModel>>(
        future: ref.read(syncServiceProvider).getSuppliers(),
        builder: (context, snapshot) {
          final suppliers = snapshot.data ?? [];
          final filteredSuppliers = suppliers.where((s) {
            final q = _searchCtrl.text.toLowerCase();
            return s.name.toLowerCase().contains(q) ||
                   (s.phone?.toLowerCase().contains(q) ?? false);
          }).toList();

          double totalPurchase = 0;
          for (var s in filteredSuppliers) {
            totalPurchase += s.purchaseTotal;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BreadcrumbWidget(items: ['Home', 'Suppliers']),
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
                      // Toolbar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Text('Search Suppliers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                            const SizedBox(width: 8),
                            Text('${filteredSuppliers.length} items', style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                            const Spacer(),
                            PosButton(label: '+ Add Supplier', onTap: () => context.go('/suppliers/create')),
                            const SizedBox(width: 8),
                            _navyBtn(Icons.file_upload_outlined, 'Import'),
                            const SizedBox(width: 8),
                            _navyBtn(Icons.file_download_outlined, 'Template'),
                            const SizedBox(width: 12),
                            PosSearchField(controller: _searchCtrl, hint: 'Search Suppliers', width: 200, onChanged: (_) => setState(() {})),
                            const SizedBox(width: 12),
                            const Icon(Icons.view_column_outlined, color: Color(0xFF64748b), size: 20),
                            const SizedBox(width: 12),
                            const Icon(Icons.filter_alt_outlined, color: Color(0xFF64748b), size: 20),
                            const SizedBox(width: 12),
                            const Icon(Icons.more_vert, color: Color(0xFF64748b), size: 20),
                          ],
                        ),
                      ),

                      // Table
                      PosTable(
                        columns: _columnLabels,
                        columnWidths: const [50, 300, 200, 200, 200, 200, 100],
                        rows: [
                          ...filteredSuppliers.map((r) => [
                            '',
                            Text(r.name, style: const TextStyle(fontSize: 13, color: Color(0xFF22c55e), fontWeight: FontWeight.w600)),
                            Text(r.email ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                            Text(r.phone ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                            _badge(r.location, isBlue: true),
                            Text('Rs ${r.purchaseTotal}', style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748b)),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                              ],
                              onSelected: (val) async {
                                if (val == 'edit') {
                                  _showEditSupplierDialog(r);
                                } else if (val == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Supplier'),
                                      content: const Text('Are you sure you want to delete this supplier?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ref.read(syncServiceProvider).deleteSupplier(r.id);
                                    setState(() {});
                                  }
                                }
                              },
                            ),
                          ]),
                          // Totals Row
                          [
                            '',
                            const SizedBox(),
                            const SizedBox(),
                            const SizedBox(),
                            const SizedBox(),
                            const Align(alignment: Alignment.centerRight, child: Text('total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            Text('Rs $totalPurchase', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(),
                          ]
                        ],
                      ),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showEditSupplierDialog(SupplierModel supplier) {
    final nameCtrl = TextEditingController(text: supplier.name);
    final phoneCtrl = TextEditingController(text: supplier.phone);
    final emailCtrl = TextEditingController(text: supplier.email);
    final addressCtrl = TextEditingController(text: supplier.address);
    final purchaseCtrl = TextEditingController(text: supplier.purchaseTotal.toString());

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Supplier',
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
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: const Color(0xFF0f172a),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Edit Supplier', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditField('Name*', nameCtrl),
                          const SizedBox(height: 16),
                          _buildEditField('Phone', phoneCtrl),
                          const SizedBox(height: 16),
                          _buildEditField('Email', emailCtrl),
                          const SizedBox(height: 16),
                          _buildEditField('Address', addressCtrl),
                          const SizedBox(height: 16),
                          _buildEditField('Purchase Total', purchaseCtrl),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFe2e8f0)))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0f172a)),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (nameCtrl.text.isEmpty) return;
                            final updated = SupplierModel(
                              id: supplier.id,
                              name: nameCtrl.text,
                              phone: phoneCtrl.text,
                              email: emailCtrl.text,
                              address: addressCtrl.text,
                              purchaseTotal: double.tryParse(purchaseCtrl.text) ?? 0.0,
                              location: supplier.location,
                            );
                            await ref.read(syncServiceProvider).saveSupplier(updated);
                            if (mounted) {
                              Navigator.pop(context);
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0f172a), foregroundColor: Colors.white),
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFf8fafc),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _navyBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _badge(String label, {bool isBlue = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isBlue ? const Color(0xFFeff6ff) : const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, color: isBlue ? const Color(0xFF2563eb) : const Color(0xFF64748b), fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4)),
            child: const Row(children: [Text('10', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)), Icon(Icons.keyboard_arrow_down, size: 14)]),
          ),
          const SizedBox(width: 12),
          const Text('SHOWING 1-10 OF 17', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94a3b8))),
          const Spacer(),
          _pageNode('«'),
          _pageNode('‹'),
          _pageNode('1', active: true),
          _pageNode('2'),
          _pageNode('›'),
          _pageNode('»'),
        ],
      ),
    );
  }

  Widget _pageNode(String label, {bool active = false}) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: active ? const Color(0xFF0f172a) : Colors.transparent, shape: BoxShape.circle),
      child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : const Color(0xFF64748b), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
    );
  }
}
