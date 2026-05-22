import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/inventory/data/models/unit_model.dart';
import 'package:frontend/features/inventory/presentation/providers/units_provider.dart';
import 'package:uuid/uuid.dart';

class UnitsScreen extends ConsumerStatefulWidget {
  const UnitsScreen({super.key});

  @override
  ConsumerState<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends ConsumerState<UnitsScreen> {
  final _searchCtrl = TextEditingController();

  final List<String> _columnLabels = [
    '', 'NAME', 'SHORTNAME', 'BASE UNIT MULTIPLIER', 'BASE UNIT', 'ACTIONS'
  ];

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(unitsProvider);

    return MainLayout(
      currentRoute: '/units',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Units']),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFe2e8f0)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Text('All Units', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                        const SizedBox(width: 8),
                        unitsAsync.maybeWhen(
                          data: (items) => Text('${items.length} items', style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                          orElse: () => const Text('...', style: TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                        ),
                        const Spacer(),
                        PosButton(label: '+ Add Unit', onTap: () => _showUnitDialog(context, ref, null)),
                        const SizedBox(width: 12),
                        PosSearchField(controller: _searchCtrl, hint: 'Search Units', width: 200, onChanged: (_) => setState(() {})),
                        const SizedBox(width: 12),
                        const Icon(Icons.view_column_outlined, color: Color(0xFF64748b), size: 20),
                        const SizedBox(width: 6),
                        const Text('Columns', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748b))),
                        const SizedBox(width: 12),
                        const Icon(Icons.more_vert, color: Color(0xFF64748b), size: 20),
                      ],
                    ),
                  ),

                  unitsAsync.when(
                    loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Padding(padding: const EdgeInsets.all(40), child: Text('Error: $e')),
                    data: (units) {
                      final filtered = units.where((u) => u.name.toLowerCase().contains(_searchCtrl.text.toLowerCase()) || u.shortName.toLowerCase().contains(_searchCtrl.text.toLowerCase())).toList();
                      return PosTable(
                        columns: _columnLabels,
                        columnWidths: const [60, 250, 200, 250, 200, 80],
                        rows: filtered.map((u) => [
                          Checkbox(value: false, onChanged: (_) {}, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
                          Text(u.name, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          Text(u.shortName, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          Text(u.baseUnitMultiplier.toStringAsFixed(0), style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          Text(u.baseUnit ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748b)),
                            onSelected: (val) {
                              if (val == 'edit') _showUnitDialog(context, ref, u);
                              if (val == 'delete') _deleteUnit(context, ref, u);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ]).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUnit(BuildContext context, WidgetRef ref, UnitModel u) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Unit'),
        content: Text('Are you sure you want to delete ${u.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      )
    );
    if (confirm == true) {
      ref.read(unitsProvider.notifier).deleteUnit(u.id);
    }
  }

  void _showUnitDialog(BuildContext context, WidgetRef ref, UnitModel? unit) {
    showDialog(
      context: context,
      builder: (_) => UnitDialogWidget(unit: unit),
    );
  }
}

class UnitDialogWidget extends ConsumerStatefulWidget {
  final UnitModel? unit;
  const UnitDialogWidget({super.key, this.unit});

  @override
  ConsumerState<UnitDialogWidget> createState() => _UnitDialogWidgetState();
}

class _UnitDialogWidgetState extends ConsumerState<UnitDialogWidget> {
  late TextEditingController nameCtrl;
  late TextEditingController shortNameCtrl;
  String? selectedBaseUnit;
  final List<String> baseUnitsList = ['Kg', 'Liter', 'Pc', 'Dozen', 'Box'];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.unit?.name ?? '');
    shortNameCtrl = TextEditingController(text: widget.unit?.shortName ?? '');
    selectedBaseUnit = widget.unit?.baseUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xFF0f172a), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.unit == null ? 'Add Unit' : 'Edit Unit', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white)),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Name*'),
                  const SizedBox(height: 8),
                  _fieldInput(nameCtrl, 'Name'),
                  const SizedBox(height: 20),
                  
                  _fieldLabel('Shortname*'),
                  const SizedBox(height: 8),
                  _fieldInput(shortNameCtrl, 'Shortname'),
                  const SizedBox(height: 20),

                  _fieldLabel('Base Unit'),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf8fafc),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFe2e8f0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBaseUnit,
                        isExpanded: true,
                        hint: const Text('Base Unit', style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF94a3b8)),
                        items: baseUnitsList.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) => setState(() => selectedBaseUnit = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF0f172a)), borderRadius: BorderRadius.circular(8)),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF0f172a), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (nameCtrl.text.isEmpty || shortNameCtrl.text.isEmpty) return;
                          
                          // Default multiplier logic based on name like "bori (35kg)"
                          double multiplier = 1.0;
                          if (nameCtrl.text.contains('(') && nameCtrl.text.contains('kg)')) {
                            final match = RegExp(r'\((\d+)kg\)').firstMatch(nameCtrl.text);
                            if (match != null) multiplier = double.parse(match.group(1)!);
                          }

                          if (widget.unit == null) {
                            await ref.read(unitsProvider.notifier).addUnit(
                              UnitModel(
                                id: const Uuid().v4(), 
                                name: nameCtrl.text, 
                                shortName: shortNameCtrl.text,
                                baseUnit: selectedBaseUnit,
                                baseUnitMultiplier: multiplier,
                              )
                            );
                          } else {
                            await ref.read(unitsProvider.notifier).updateUnit(
                              widget.unit!.copyWith(
                                name: nameCtrl.text, 
                                shortName: shortNameCtrl.text,
                                baseUnit: selectedBaseUnit,
                                baseUnitMultiplier: multiplier,
                              )
                            );
                          }
                          if (mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0f172a),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), // Height
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _fieldLabel(String label) {
    return Text.rich(
      TextSpan(
        text: label.replaceAll('*', ''),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        children: [
          if (label.contains('*')) const TextSpan(text: '*', style: TextStyle(color: Colors.red)),
        ]
      )
    );
  }

  Widget _fieldInput(TextEditingController ctrl, String hint) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFf8fafc),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFe2e8f0)),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
