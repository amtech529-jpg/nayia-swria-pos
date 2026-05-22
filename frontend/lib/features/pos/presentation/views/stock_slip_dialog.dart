import 'package:flutter/material.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';
import 'package:frontend/features/inventory/data/models/product_model.dart';
import 'package:frontend/core/utils/export_service.dart';

class StockSlipDialog extends StatelessWidget {
  final SaleModel sale;
  final List<ProductModel> products;

  const StockSlipDialog({super.key, required this.sale, required this.products});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Build enriched rows: each item + its stock before/after
    final rows = sale.items.map((item) {
      final prod = products.firstWhere(
        (p) => p.name == item.productName || (p.sku != null && p.sku == item.sku),
        orElse: () => ProductModel(id: '', name: item.productName, cost: 0, price: item.price),
      );
      final stockBefore = prod.id.isNotEmpty ? prod.openingStock + item.qty : null;
      final stockAfter  = prod.id.isNotEmpty ? prod.openingStock : null;
      return _SlipRow(
        name: item.productName,
        sku: prod.sku,
        qty: item.qty,
        stockBefore: stockBefore,
        stockAfter: stockAfter,
        unit: prod.saleUnit.isNotEmpty ? prod.saleUnit : 'Pcs',
      );
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 520,
        constraints: const BoxConstraints(maxHeight: 680),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFf3e8ff), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF6d28d9), size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock Movement Slip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                    Text('Before & After Sale Stock', style: TextStyle(fontSize: 11, color: Color(0xFF64748b))),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Color(0xFF64748b)),
                ),
              ],
            ),
            const Divider(height: 24),

            // Info Row
            Row(
              children: [
                _InfoChip(label: 'Invoice', value: sale.invoiceNo, color: const Color(0xFF10b981)),
                const SizedBox(width: 8),
                _InfoChip(label: 'Customer', value: sale.customerName ?? 'Walk In', color: const Color(0xFF3b82f6)),
                const SizedBox(width: 8),
                _InfoChip(label: 'Date', value: sale.saleDate.split('T')[0], color: const Color(0xFF6d28d9)),
              ],
            ),
            const SizedBox(height: 16),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5))),
                  SizedBox(width: 50, child: Text('SOLD', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5))),
                  SizedBox(width: 70, child: Text('BEFORE', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFfbbf24), letterSpacing: 0.5))),
                  SizedBox(width: 70, child: Text('AFTER', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4ade80), letterSpacing: 0.5))),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Table Body
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rows.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFf1f5f9)),
                itemBuilder: (context, i) {
                  final r = rows[i];
                  final isLow = r.stockAfter != null && r.stockAfter! <= 5;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: i.isEven ? Colors.white : const Color(0xFFfafafa),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0f172a))),
                              if (r.sku != null)
                                Text('SKU: ${r.sku}', style: const TextStyle(fontSize: 10, color: Color(0xFF94a3b8))),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFdbeafe), borderRadius: BorderRadius.circular(10)),
                              child: Text('${r.qty}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1d4ed8))),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Center(
                            child: r.stockBefore != null
                                ? Text(r.stockBefore!.toStringAsFixed(0),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFf59e0b)))
                                : const Text('—', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94a3b8))),
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Center(
                            child: r.stockAfter != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(r.stockAfter!.toStringAsFixed(0),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isLow ? const Color(0xFFef4444) : const Color(0xFF16a34a),
                                          )),
                                      if (isLow) ...[
                                        const SizedBox(width: 2),
                                        const Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFef4444)),
                                      ],
                                    ],
                                  )
                                : const Text('—', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF94a3b8))),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 24),

            // Summary
            Row(
              children: [
                _SummaryChip(label: 'Items Sold', value: '${sale.items.length} products', color: const Color(0xFF3b82f6)),
                const SizedBox(width: 8),
                _SummaryChip(
                  label: 'Total Qty',
                  value: '${sale.items.fold<int>(0, (s, i) => s + i.qty)} pcs',
                  color: const Color(0xFF6d28d9),
                ),
                const Spacer(),
                Text(
                  'Generated: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94a3b8)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Low stock warning if any
            if (rows.any((r) => r.stockAfter != null && r.stockAfter! <= 5)) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFfef2f2), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFfecaca))),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFef4444)),
                    SizedBox(width: 6),
                    Expanded(child: Text('⚠️ Some items are critically low in stock after this sale!', style: TextStyle(fontSize: 11, color: Color(0xFFef4444), fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final slipRows = rows.map((r) => {
                      'name': r.name,
                      'sku': r.sku,
                      'qty': r.qty,
                      'before': r.stockBefore,
                      'after': r.stockAfter,
                    }).toList();
                    await ExportService.printStockSlip(
                      invoiceNo: sale.invoiceNo,
                      customerName: sale.customerName ?? 'Walk In Customer',
                      saleDate: sale.saleDate,
                      rows: slipRows,
                    );
                  },
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('Print Slip', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6d28d9),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(color: Color(0xFF64748b))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _SlipRow {
  final String name;
  final String? sku;
  final int qty;
  final double? stockBefore;
  final double? stockAfter;
  final String unit;

  const _SlipRow({
    required this.name,
    this.sku,
    required this.qty,
    this.stockBefore,
    this.stockAfter,
    required this.unit,
  });
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0f172a)), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
