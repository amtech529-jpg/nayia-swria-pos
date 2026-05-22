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
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;
  
  // Column visibility state
  final List<String> _columnLabels = [
    '', 'ID', 'IMAGE', 'NAME', 'FATHER NAME', 'ADDRESS', 'PHONE', 'BALANCE', 'EMAIL', 'CNIC', 'AREA', 'LOCATION', 'ACTIONS'
  ];
  late List<bool> _visibleColumns;
  String _pageSize = '10';

  final List<Map<String, String>> _customers = [
    {'id': '906', 'image': 'https://i.pravatar.cc/150?u=906', 'name': 'arshad randyali 231 S/O mil warkar', 'address': 'Village A', 'phone': '03454979140', 'balance': '47750', 'email': 'arshad@test.com', 'cnic': '35201-1234567-1', 'area': 'Lahore', 'location': 'Default'},
    {'id': '905', 'image': 'https://i.pravatar.cc/150?u=905', 'name': 'zain dahrar randyali 231', 'address': 'Street 5', 'phone': '03458029303', 'balance': '0', 'email': '', 'cnic': '', 'area': 'Multan', 'location': 'Default'},
    {'id': '904', 'image': 'https://i.pravatar.cc/150?u=904', 'name': 'zain dahrar randyali 231', 'address': 'Main Bazar', 'phone': '03458029303', 'balance': '5500', 'email': '', 'cnic': '', 'area': 'Multan', 'location': 'Default'},
    {'id': '903', 'image': 'https://i.pravatar.cc/150?u=903', 'name': 'hafiz ashad lokri copi 231', 'address': 'Sector 4', 'phone': '03454008482', 'balance': '0', 'email': '', 'cnic': '', 'area': 'Faisalabad', 'location': 'Default'},
  ];

  @override
  void initState() {
    super.initState();
    _visibleColumns = List.generate(_columnLabels.length, (index) => true);
  }

  List<Map<String, String>> get _filtered {
    final q = _searchCtrl.text.toLowerCase();
    if (q.isEmpty) return _customers;
    return _customers.where((c) =>
      c['name']!.toLowerCase().contains(q) ||
      c['phone']!.toLowerCase().contains(q) ||
      c['id']!.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/customers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Customers']),
            const SizedBox(height: 16),
            if (_showFilters) _buildAdvancedFilters(),
            const SizedBox(height: 16),
            _buildTableCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.filter_alt, size: 18, color: Color(0xFF0f172a)),
              SizedBox(width: 8),
              Text('Advanced Filters', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _filterDrop('Business Location', ['All', 'Default', 'Warehouse A'])),
              const SizedBox(width: 16),
              Expanded(child: _filterDrop('Area', ['All', 'Lahore', 'Multan', 'Faisalabad'])),
              const SizedBox(width: 16),
              Expanded(child: _filterDrop('Balance Status', ['All', 'With Dues', 'No Dues'])),
              const SizedBox(width: 16),
              PosButton(label: 'Apply Filters', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterDrop(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tableSubText)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFe2e8f0))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.first,
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1e293b)),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard() {
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 800;

    final customerState = ref.watch(customersListProvider);

    return customerState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text('Error: $err'),
        ),
      ),
      data: (customers) {
        final reversedCustomers = customers.reversed.toList();
        final filteredCustomers = reversedCustomers.where((c) {
          final q = _searchCtrl.text.toLowerCase();
          return c.name.toLowerCase().contains(q) ||
                 (c.phone?.toLowerCase().contains(q) ?? false) ||
                 c.id.toLowerCase().contains(q);
        }).toList();

        final limit = _pageSize == 'All' ? filteredCustomers.length : int.tryParse(_pageSize) ?? 10;
        final paginatedCustomers = filteredCustomers.take(limit).toList();

        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(
            children: [
              // Toolbar Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('All Customers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0f172a))),
                        const SizedBox(width: 8),
                        Text('${filteredCustomers.length} items', style: const TextStyle(color: Color(0xFF64748b), fontSize: 13)),
                        const Spacer(),
                        PosButton(label: '+ Add Customer', icon: Icons.add, onTap: () => context.go('/customers/create')),
                        const SizedBox(width: 8),
                        PosButton(label: 'Payments', outlined: true, onTap: () => context.go('/customers/payments')),
                        const SizedBox(width: 8),
                        PosButton(
                          label: 'Import', 
                          outlined: true, 
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Importing data...'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        PosButton(
                          label: 'Template', 
                          outlined: true, 
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloading template...'), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        PosSearchField(controller: _searchCtrl, hint: 'Search Customers', onChanged: (_) => setState(() {})),
                        const SizedBox(width: 12),
                        _columnMenu(),
                        const SizedBox(width: 12),
                        _ToolIcon(
                          icon: Icons.filter_alt_outlined, 
                          onTap: () => setState(() => _showFilters = !_showFilters), 
                          active: _showFilters
                        ),
                        const Spacer(),
                        _exportMenu(),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Table
              PosTable(
                columns: _columnLabels,
                columnWidths: const [50, 50, 60, 150, 120, 150, 120, 100, 150, 130, 100, 120, 80],
                visibleColumns: _visibleColumns,
                rows: paginatedCustomers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final c = entry.value;
                  return [
                    '',
                    Text('${index + 1}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                    const CircleAvatar(radius: 16, backgroundColor: Color(0xFFe2e8f0), child: Icon(Icons.person, size: 16, color: Color(0xFF94a3b8))),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () async {
                            final msg = "محترم جناب ${c.name} آپ کی طرف رقم Rs ${c.balance} واجب الادا ہے۔ برائے مہربانی جلد از جلد ادائیگی ممکن بنائیں شکریہ\\nMessage From: ";
                            final phone = (c.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
                            // If phone starts with 0, replace with 92 for Pakistan
                            final formattedPhone = phone.startsWith('0') ? '92${phone.substring(1)}' : phone;
                            final url = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(msg)}');
                            try {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF25D366),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(FontAwesomeIcons.whatsapp, size: 14, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.go('/customers/view/${c.id}'),
                            child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2563eb)), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                    Text(c.fatherName ?? '', style: const TextStyle(fontSize: 13, color: AppColors.tableText)),
                    Text(c.address ?? '', style: const TextStyle(fontSize: 12, color: AppColors.tableSubText)),
                    Text(c.phone ?? '', style: const TextStyle(fontSize: 13, color: AppColors.tableText)),
                    Text('Rs ${c.balance}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.balance > 0 ? const Color(0xFFef4444) : const Color(0xFF22c55e))),
                    Text(c.email ?? '', style: const TextStyle(fontSize: 13, color: AppColors.tableText)),
                    Text(c.cnic ?? '', style: const TextStyle(fontSize: 13, color: AppColors.tableText)),
                    Text(c.area ?? '', style: const TextStyle(fontSize: 13, color: AppColors.tableText)),
                    Text(c.location ?? '', style: const TextStyle(fontSize: 13, color: AppColors.tableText)),
                    _ActionMenu(
                      onEdit: () => _showEditCustomerDialog(c),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Customer'),
                            content: const Text('Are you sure you want to delete this customer?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(customersListProvider.notifier).removeCustomer(c.id);
                        }
                      },
                      onPay: () => context.go('/customers/payments'),
                    ),
                  ];
                }).toList(),
              ),

              _TableFooter(
                total: filteredCustomers.length,
                current: paginatedCustomers.length,
                pageSize: _pageSize,
                onPageSizeChanged: (newSize) {
                  setState(() {
                    _pageSize = newSize;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCustomerDialog(CustomerModel customer) {
    final nameCtrl = TextEditingController(text: customer.name);
    final phoneCtrl = TextEditingController(text: customer.phone);
    final emailCtrl = TextEditingController(text: customer.email);
    final cnicCtrl = TextEditingController(text: customer.cnic);
    final addressCtrl = TextEditingController(text: customer.address);
    final areaCtrl = TextEditingController(text: customer.area);
    final balanceCtrl = TextEditingController(text: customer.balance.toString());

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Customer',
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
                        const Text('Edit Customer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                          _buildEditField('CNIC', cnicCtrl),
                          const SizedBox(height: 16),
                          _buildEditField('Address', addressCtrl),
                          const SizedBox(height: 16),
                          _buildEditField('Area', areaCtrl),
                          const SizedBox(height: 16),
                          _buildEditField('Balance', balanceCtrl),
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
                            final updated = CustomerModel(
                              id: customer.id,
                              name: nameCtrl.text,
                              fatherName: customer.fatherName,
                              phone: phoneCtrl.text,
                              email: emailCtrl.text,
                              cnic: cnicCtrl.text,
                              address: addressCtrl.text,
                              balance: double.tryParse(balanceCtrl.text) ?? 0.0,
                              area: areaCtrl.text,
                              location: customer.location,
                              imageUrl: customer.imageUrl,
                            );
                            await ref.read(customersListProvider.notifier).updateCustomer(updated);
                            if (mounted) {
                              Navigator.pop(context);
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

  Widget _columnMenu() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 45),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(6)),
        child: const Row(
          children: [
            Icon(Icons.view_column, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text('Columns', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (_) => List.generate(_columnLabels.length, (i) {
        if (_columnLabels[i].isEmpty) return const PopupMenuDivider() as PopupMenuEntry<int>;
        return CheckedPopupMenuItem(
          value: i,
          checked: _visibleColumns[i],
          child: Text(_columnLabels[i], style: const TextStyle(fontSize: 13)),
        );
      }),
      onSelected: (i) => setState(() => _visibleColumns[i] = !_visibleColumns[i]),
    );
  }

  Widget _exportMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      icon: const Icon(Icons.more_vert, color: Color(0xFF64748b)),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'excel', child: Row(children: [Icon(Icons.file_copy, size: 16), SizedBox(width: 8), Text('Export to Excel')])),
        const PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, size: 16), SizedBox(width: 8), Text('Export to PDF')])),
        const PopupMenuItem(value: 'print', child: Row(children: [Icon(Icons.print, size: 16), SizedBox(width: 8), Text('Print Table')])),
      ],
      onSelected: (val) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exporting to ${val.toUpperCase()}...'), duration: const Duration(seconds: 1)),
        );
      },
    );
  }
}

class _ToolIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _ToolIcon({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: active ? const Color(0xFF0f172a).withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 20, color: active ? const Color(0xFF0f172a) : AppColors.tableSubText),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPay;

  const _ActionMenu({required this.onEdit, required this.onDelete, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.tableSubText),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'pay', child: Row(children: [Icon(Icons.payment, size: 16), SizedBox(width: 8), Text('Pay')])),
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
      ],
      onSelected: (val) {
        if (val == 'edit') onEdit();
        if (val == 'delete') onDelete();
        if (val == 'pay') onPay();
      },
    );
  }
}

class _TableFooter extends StatelessWidget {
  final int total;
  final int current;
  final String pageSize;
  final ValueChanged<String> onPageSizeChanged;

  const _TableFooter({
    required this.total,
    required this.current,
    required this.pageSize,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          PopupMenuButton<String>(
            onSelected: onPageSizeChanged,
            itemBuilder: (context) => ['10', '20', '50', '100', 'All'].map((size) {
              return PopupMenuItem<String>(
                value: size,
                child: Text(size, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFe9ecef)), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Text(pageSize, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('SHOWING 1-$current OF $total', style: const TextStyle(fontSize: 11, color: AppColors.tableSubText, fontWeight: FontWeight.w600)),
          const Spacer(),
          _PageBtn(label: '«', onTap: () => _notify(context, 'First Page')),
          _PageBtn(label: '‹', onTap: () => _notify(context, 'Previous Page')),
          _PageBtn(label: '1', selected: true, onTap: () => _notify(context, 'Page 1')),
          _PageBtn(label: '2', onTap: () => _notify(context, 'Page 2')),
          _PageBtn(label: '›', onTap: () => _notify(context, 'Next Page')),
          _PageBtn(label: '»', onTap: () => _notify(context, 'Last Page')),
        ],
      ),
    );
  }

  void _notify(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 500)),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PageBtn({required this.label, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0f172a) : Colors.white,
          border: Border.all(color: selected ? const Color(0xFF0f172a) : const Color(0xFFe9ecef)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.tableText, fontWeight: selected ? FontWeight.w700 : FontWeight.w400))),
      ),
    );
  }
}
