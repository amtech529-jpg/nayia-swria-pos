import 'package:flutter/material.dart';

// ─── Standardized POS Table ────────────────────────────────────────
class PosTable extends StatefulWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final List<double>? columnWidths;
  final List<bool>? visibleColumns;
  final bool selectable;

  const PosTable({
    super.key,
    required this.columns,
    required this.rows,
    this.columnWidths,
    this.visibleColumns,
    this.selectable = true,
  });

  @override
  State<PosTable> createState() => _PosTableState();
}

class _PosTableState extends State<PosTable> {
  final Set<int> _selectedRows = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    final List<String> activeColumns = [];
    final List<double> activeWidths = [];
    final List<int> activeIndices = [];

    // Robust column matching
    for (int i = 0; i < widget.columns.length; i++) {
      final bool isVisible = (widget.visibleColumns == null || 
                             (widget.visibleColumns!.length > i && widget.visibleColumns![i]));
      
      if (isVisible) {
        activeColumns.add(widget.columns[i]);
        activeWidths.add((widget.columnWidths != null && widget.columnWidths!.length > i) 
            ? widget.columnWidths![i] 
            : 160.0);
        activeIndices.add(i);
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      double totalWidth = activeWidths.fold(0.0, (a, b) => a + b);
      if (totalWidth < constraints.maxWidth) totalWidth = constraints.maxWidth;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFf8f9fa),
                  border: Border(bottom: BorderSide(color: Color(0xFFe9ecef))),
                ),
                child: Row(
                  children: List.generate(activeColumns.length, (i) {
                    final isCheckbox = activeColumns[i].isEmpty && activeWidths[i] < 60;
                    return Container(
                      width: activeWidths[i],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: isCheckbox 
                        ? Center(
                            child: Checkbox(
                              value: _selectAll, 
                              onChanged: (v) {
                                setState(() {
                                  _selectAll = v!;
                                  if (_selectAll) {
                                    _selectedRows.addAll(List.generate(widget.rows.length, (i) => i));
                                  } else {
                                    _selectedRows.clear();
                                  }
                                });
                              },
                              side: const BorderSide(color: Color(0xFFcbd5e1), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            )
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  activeColumns[i],
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748b), letterSpacing: 0.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.unfold_more, size: 14, color: Color(0xFF94a3b8)),
                            ],
                          ),
                    );
                  }),
                ),
              ),
              // Rows
              ...widget.rows.asMap().entries.map((entry) {
                final rowIndex = entry.key;
                final row = entry.value;
                final isSelected = _selectedRows.contains(rowIndex);

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFf1f5f9) : Colors.transparent,
                    border: const Border(bottom: BorderSide(color: Color(0xFFf1f3f5))),
                  ),
                  child: Row(
                    children: List.generate(activeIndices.length, (i) {
                      final originalIndex = activeIndices[i];
                      final width = activeWidths[i];
                      
                      // Safety: Check if row has the index
                      final cellData = row.length > originalIndex ? row[originalIndex] : null;
                      final isCheckbox = activeColumns[i].isEmpty && width < 60;

                      return Container(
                        width: width,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: isCheckbox 
                          ? Center(
                              child: Checkbox(
                                value: isSelected, 
                                onChanged: (v) {
                                  setState(() {
                                    if (v!) {
                                      _selectedRows.add(rowIndex);
                                    } else {
                                      _selectedRows.remove(rowIndex);
                                      _selectAll = false;
                                    }
                                  });
                                },
                                side: const BorderSide(color: Color(0xFFcbd5e1), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              )
                            )
                          : (cellData is Widget 
                              ? cellData 
                              : Text(
                                  cellData?.toString() ?? '',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Standardized POS Button ─────────────────────────────────────
class PosButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final IconData? icon;

  const PosButton({
    super.key, 
    required this.label, 
    required this.onTap, 
    this.outlined = false, 
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : const Color(0xFF0f172a),
          border: Border.all(color: outlined ? const Color(0xFFe2e8f0) : const Color(0xFF0f172a)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: outlined ? const Color(0xFF334155) : Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: outlined ? const Color(0xFF334155) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Standardized POS Search Field ──────────────────────────────
class PosSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final double? width;

  const PosSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 240,
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94a3b8)),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94a3b8)),
          filled: true,
          fillColor: const Color(0xFFf8fafc),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFe2e8f0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0f172a), width: 1.5)),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
