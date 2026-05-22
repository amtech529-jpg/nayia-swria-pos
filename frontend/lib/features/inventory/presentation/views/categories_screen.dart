import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/storage/offline_service.dart';
import 'package:frontend/core/network/sync_service.dart';
import 'package:frontend/features/inventory/data/models/category_model.dart';
import 'package:frontend/features/inventory/presentation/providers/categories_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _searchCtrl = TextEditingController();
  final List<String> _columnLabels = ['', 'CATEGORY NAME', 'DESCRIPTION', 'PARENT CATEGORY', 'ACTIONS'];
  List<bool> _visibleColumns = [];
  String _pageSize = '10';

  @override
  void initState() {
    super.initState();
    _visibleColumns = List.generate(_columnLabels.length, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesListProvider);

    return MainLayout(
      currentRoute: '/categories',
      child: categoriesState.when(
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
        data: (categories) {
          final filteredCategories = categories.where((c) {
            final query = _searchCtrl.text.toLowerCase();
            return c.name.toLowerCase().contains(query) || (c.description?.toLowerCase().contains(query) ?? false);
          }).toList();

          final limit = _pageSize == 'All' ? filteredCategories.length : int.tryParse(_pageSize) ?? 10;
          final paginatedCategories = filteredCategories.take(limit).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BreadcrumbWidget(items: ['Home', 'Categories']),
                const SizedBox(height: 24),

                // Main Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFe2e8f0)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      // Toolbar
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                            const SizedBox(width: 8),
                            Text('${filteredCategories.length} items', style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                            const Spacer(),
                            PosButton(label: '+ Add Category', onTap: () => _showAddCategoryDialog()),
                            const SizedBox(width: 12),
                            PosSearchField(controller: _searchCtrl, hint: 'Search Categories', width: 200, onChanged: (_) => setState(() {})),
                            const SizedBox(width: 12),
                            _columnMenu(),
                            const SizedBox(width: 12),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Color(0xFF64748b), size: 20),
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'import', child: Text('Import Categories')),
                                const PopupMenuItem(value: 'template', child: Text('Download Template')),
                              ],
                              onSelected: (val) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${val.toUpperCase()} selected'), duration: const Duration(seconds: 1)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Table
                      PosTable(
                        columns: _columnLabels,
                        visibleColumns: _visibleColumns,
                        columnWidths: const [50, 200, 350, 250, 100],
                        rows: paginatedCategories.map((c) => [
                          '',
                          Text(c.name, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                          Text(c.description ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                          Text(c.parentName ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF64748b))),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF64748b)),
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit')])),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                            ],
                            onSelected: (val) async {
                              if (val == 'edit') {
                                _showEditCategoryDialog(c);
                              } else if (val == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Category'),
                                    content: const Text('Are you sure you want to delete this category?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await ref.read(categoriesListProvider.notifier).removeCategory(c.id);
                                }
                              }
                            },
                          ),
                        ]).toList(),
                      ),

                      // Footer
                      _buildFooter(filteredCategories.length, paginatedCategories.length),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _columnMenu() {
    return PopupMenuButton<int>(
      offset: const Offset(0, 45),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFe2e8f0)), borderRadius: BorderRadius.circular(6)),
        child: const Row(
          children: [
            Icon(Icons.view_column_outlined, size: 16, color: Color(0xFF64748b)),
            SizedBox(width: 8),
            Text('Columns', style: TextStyle(color: Color(0xFF64748b), fontSize: 13, fontWeight: FontWeight.w600)),
            Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF64748b)),
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

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Category',
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
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: const Color(0xFF0f172a),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Add Category', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDialogField('Category Name*', hint: 'Category Name', controller: nameCtrl),
                          const SizedBox(height: 20),
                          _buildDialogTextArea('Description', hint: 'Description', controller: descCtrl),
                          const SizedBox(height: 20),
                          _buildDialogDrop('Parent Category', hint: 'Search Category'),
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
                        _dialogBtn('Cancel', isSecondary: true, onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        _dialogBtn(
                          'Submit',
                          onTap: () async {
                            if (nameCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Category Name is required')),
                              );
                              return;
                            }
                            final category = CategoryModel(
                              id: OfflineService.generateId(),
                              name: nameCtrl.text,
                              description: descCtrl.text,
                            );
                            await ref.read(categoriesListProvider.notifier).addCategory(category);
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
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

  void _showEditCategoryDialog(CategoryModel category) {
    final nameCtrl = TextEditingController(text: category.name);
    final descCtrl = TextEditingController(text: category.description ?? '');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Category',
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
                        const Text('Edit Category', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                          _buildDialogField('Category Name*', hint: 'Category Name', controller: nameCtrl),
                          const SizedBox(height: 20),
                          _buildDialogTextArea('Description', hint: 'Description', controller: descCtrl),
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
                        _dialogBtn('Cancel', isSecondary: true, onTap: () => Navigator.pop(context)),
                        const SizedBox(width: 12),
                        _dialogBtn(
                          'Save Changes',
                          onTap: () async {
                            if (nameCtrl.text.isEmpty) return;
                            final updated = CategoryModel(
                              id: category.id,
                              name: nameCtrl.text,
                              description: descCtrl.text,
                              parentName: category.parentName,
                            );
                            await ref.read(categoriesListProvider.notifier).updateCategory(updated);
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
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

  Widget _buildDialogField(String label, {required String hint, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFf8fafc),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTextArea(String label, {required String hint, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFf8fafc),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogDrop(String label, {required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hint, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF94a3b8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dialogBtn(String label, {bool isSecondary = false, required VoidCallback onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary ? Colors.white : const Color(0xFF0f172a),
        foregroundColor: isSecondary ? const Color(0xFF0f172a) : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: isSecondary ? const BorderSide(color: Color(0xFFe2e8f0)) : BorderSide.none),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildFooter(int total, int current) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          PopupMenuButton<String>(
            onSelected: (newSize) {
              setState(() {
                _pageSize = newSize;
              });
            },
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
                decoration: BoxDecoration(color: const Color(0xFFf1f5f9), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    Text(_pageSize, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('SHOWING 1-$current OF $total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94a3b8))),
          const Spacer(),
          _pageNode('«', onTap: () => _notify('First Page')),
          _pageNode('‹', onTap: () => _notify('Previous Page')),
          _pageNode('1', active: true, onTap: () => _notify('Page 1')),
          _pageNode('2', onTap: () => _notify('Page 2')),
          _pageNode('›', onTap: () => _notify('Next Page')),
          _pageNode('»', onTap: () => _notify('Last Page')),
        ],
      ),
    );
  }

  void _notify(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 500)),
    );
  }

  Widget _pageNode(String label, {bool active = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: active ? const Color(0xFF0f172a) : Colors.transparent, shape: BoxShape.circle),
        child: Text(label, style: TextStyle(fontSize: 12, color: active ? Colors.white : const Color(0xFF64748b), fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
