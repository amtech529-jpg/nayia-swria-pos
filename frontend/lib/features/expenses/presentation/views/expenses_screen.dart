import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  int _selectedTab = 0; // 0: Expenses, 1: Repeating Expenses, 2: Expense Types
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/expenses',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Expenses']),
            const SizedBox(height: 24),

            // Tabs Switcher
            Row(
              children: [
                _tabBtn(0, Icons.attach_money, 'Expenses'),
                const SizedBox(width: 12),
                _tabBtn(1, Icons.attach_money, 'Repeating Expenses'),
                const SizedBox(width: 12),
                _tabBtn(2, Icons.attach_money, 'Expense Types'),
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
                  // Toolbar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(_selectedTab == 2 ? 'All Expense Types' : 'All Expenses', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1e293b))),
                        const SizedBox(width: 8),
                        const Text('0 items', style: TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
                        const Spacer(),
                        PosButton(
                          label: _selectedTab == 2 ? '+ Add Expense Type' : '+ Add Expense', 
                          onTap: () => _selectedTab == 2 ? _showAddExpenseType() : _showAddExpense(),
                        ),
                        const SizedBox(width: 12),
                        PosSearchField(
                          controller: _searchCtrl, 
                          hint: _selectedTab == 2 ? 'Search Expense Types' : 'Search Expenses', 
                          width: 200, 
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.view_column_outlined, color: Color(0xFF64748b), size: 20),
                        const SizedBox(width: 12),
                        const Icon(Icons.filter_alt_outlined, color: Color(0xFF64748b), size: 20),
                        const SizedBox(width: 12),
                        const Icon(Icons.more_vert, color: Color(0xFF64748b), size: 20),
                      ],
                    ),
                  ),

                  // Table content based on tab
                  if (_selectedTab == 0) _buildExpensesTable(),
                  if (_selectedTab == 1) _buildRepeatingExpensesTable(),
                  if (_selectedTab == 2) _buildExpenseTypesTable(),

                  // Empty State
                  _buildEmptyState(),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(int index, IconData icon, String label) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0f172a) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : const Color(0xFF64748b)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFF64748b), fontSize: 13, fontWeight: active ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesTable() {
    return PosTable(
      columns: const ['', 'DATE', 'NAME', 'EXPENSE TYPE', 'AMOUNT', 'BUSINESS LOCATION', 'ADDED BY', 'REFERENCE', 'EXPENSE DATE', 'PAYMENT METHOD', 'ACTIONS'],
      rows: const [],
    );
  }

  Widget _buildRepeatingExpensesTable() {
    return PosTable(
      columns: const ['', 'DATE', 'NAME', 'EXPENSE TYPE', 'AMOUNT', 'RECURRING PERIOD', 'UPCOMING DATE', 'BUSINESS LOCATION', 'ACTIONS'],
      rows: const [],
    );
  }

  Widget _buildExpenseTypesTable() {
    return PosTable(
      columns: const ['', 'NAME', 'PARENT EXPENSE TYPES', 'DESCRIPTION', 'TOTAL EXPENSES', 'BUSINESS LOCATIONS', 'ACTIONS'],
      rows: const [],
    );
  }

  Widget _buildEmptyState() {
    String title = 'No Expense Found';
    if (_selectedTab == 2) title = 'No Expense Type Found';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFe2e8f0).withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.folder_open, size: 40, color: Color(0xFF94a3b8)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1e293b))),
          const SizedBox(height: 4),
          Text(_selectedTab == 2 ? 'There is no expense type found. Please create one.' : 'There is no expense found. Please create one.', style: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8))),
        ],
      ),
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
          Text('SHOWING 1-0 OF 0', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94a3b8))),
          const Spacer(),
          _pageNode('«'), _pageNode('‹'), _pageNode('›'), _pageNode('»'),
        ],
      ),
    );
  }

  Widget _pageNode(String label) {
    return Container(
      width: 28, height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
      child: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFcbd5e1))),
    );
  }

  void _showAddExpense() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Expense',
      pageBuilder: (ctx, _, __) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 400,
          height: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Material(
            child: Column(
              children: [
                _modalHeader('Add Expense'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _modalDrop('Business Location', 'Default'),
                        const SizedBox(height: 24),
                        _modalField('Name*', 'Name'),
                        const SizedBox(height: 24),
                        _modalField('Amount*', '0', prefix: 'Rs '),
                        const SizedBox(height: 24),
                        _modalField('Reference*', 'Reference'),
                        const SizedBox(height: 24),
                        _modalField('Expense Date', 'May 17, 2026 01:29 AM', hasClear: true),
                        const SizedBox(height: 24),
                        _modalDrop('Payment Method', 'Select Payment Method'),
                        const SizedBox(height: 24),
                        _modalDrop('Expense Type*', 'Expense Type'),
                      ],
                    ),
                  ),
                ),
                _modalFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExpenseType() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add Expense Type',
      pageBuilder: (ctx, _, __) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 400,
          height: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Material(
            child: Column(
              children: [
                _modalHeader('Add Expense Type'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _modalDrop('Business Locations*', 'Default', hasTag: true),
                        const SizedBox(height: 24),
                        _modalField('Name*', 'Name'),
                        const SizedBox(height: 24),
                        _modalDrop('Parent Expense Type', 'Parent Expense Type'),
                        const SizedBox(height: 24),
                        _modalField('Description', 'Description', maxLines: 5),
                      ],
                    ),
                  ),
                ),
                _modalFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(color: Color(0xFF0f172a)),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white, size: 20)),
        ],
      ),
    );
  }

  Widget _modalField(String label, String hint, {String prefix = '', bool hasClear = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
          child: Row(
            children: [
              if (prefix.isNotEmpty) Text(prefix, style: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13)),
              Expanded(
                child: TextField(
                  maxLines: maxLines,
                  decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94a3b8), fontSize: 13), border: InputBorder.none),
                ),
              ),
              if (hasClear) const Icon(Icons.close, size: 16, color: Color(0xFF94a3b8)),
            ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFf8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFe2e8f0))),
          child: Row(
            children: [
              if (hasTag)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF22c55e), borderRadius: BorderRadius.circular(4)),
                  child: const Row(children: [Text('Default', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), SizedBox(width: 4), Icon(Icons.close, size: 12, color: Colors.white)]),
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

  Widget _modalFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFe2e8f0)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF0f172a), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0f172a), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
