import 'package:flutter/material.dart';
import 'package:frontend/features/purchases/data/models/purchase_model.dart';
import 'package:frontend/core/utils/export_service.dart';

class PurchaseInvoiceDialog extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseInvoiceDialog({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final totalQty = purchase.items.fold<int>(0, (sum, item) => sum + item.qty);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Purchase Invoice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0f172a),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF64748b)),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFe2e8f0)),
              const SizedBox(height: 16),

              // Header Details
              _buildDetailRow('Invoice No:', '#${purchase.invoiceNo}', isBold: true),
              _buildDetailRow('Date:', purchase.purchaseDate.contains('T') 
                ? purchase.purchaseDate.replaceAll('T', ' ').substring(0, 19) 
                : purchase.purchaseDate),
              _buildDetailRow('Supplier:', purchase.supplierName ?? 'Supplier'),
              _buildDetailRow('Location:', purchase.location),
              _buildDetailRow('Payment:', purchase.paymentMethod),
              const SizedBox(height: 16),

              // Table Headers
              Container(
                color: const Color(0xFFf1f5f9),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: const Row(
                  children: [
                    SizedBox(width: 30, child: Text('Sr.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                    Expanded(flex: 3, child: Text('Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                    Expanded(child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                    Expanded(child: Text('Cost', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                    Expanded(child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  ],
                ),
              ),

              // Table Body
              ...purchase.items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final item = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFe2e8f0))),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('$idx', style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                      Expanded(flex: 3, child: Text(item.productName, style: const TextStyle(fontSize: 12, color: Color(0xFF0f172a)))),
                      Expanded(child: Text('${item.qty}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                      Expanded(child: Text('${item.price.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                      Expanded(child: Text('${item.totalPrice.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Calculation block
              _buildCalcRow('Subtotal (Rs):', purchase.subtotal.toStringAsFixed(0)),
              _buildCalcRow('Items:', '$totalQty pcs'),
              if (purchase.discount > 0) _buildCalcRow('Discount (Rs):', '- ${purchase.discount.toStringAsFixed(0)}'),
              _buildCalcRow('Net Total (Rs):', purchase.netTotal.toStringAsFixed(0), isBold: true),
              _buildCalcRow('Amount Paid (Rs):', purchase.paidAmount.toStringAsFixed(0)),
              _buildCalcRow('Balance Due (Rs):', purchase.pendingAmount.toStringAsFixed(0)),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ExportService.printPurchaseInvoice(
                            invoiceNo: purchase.invoiceNo,
                            supplierName: purchase.supplierName ?? 'Supplier',
                            purchaseDate: purchase.purchaseDate,
                            location: purchase.location,
                            paymentMethod: purchase.paymentMethod,
                            subtotal: purchase.subtotal,
                            discount: purchase.discount,
                            netTotal: purchase.netTotal,
                            paidAmount: purchase.paidAmount,
                            pendingAmount: purchase.pendingAmount,
                            items: purchase.items.map((i) => {
                              'name': i.productName,
                              'qty': i.qty,
                              'price': i.price,
                              'total': i.totalPrice,
                            }).toList(),
                            isThermal: true,
                          );
                        },
                        icon: const Icon(Icons.print, size: 16),
                        label: const Text('Print Thermal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10b981), // Green for Thermal
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ExportService.printPurchaseInvoice(
                            invoiceNo: purchase.invoiceNo,
                            supplierName: purchase.supplierName ?? 'Supplier',
                            purchaseDate: purchase.purchaseDate,
                            location: purchase.location,
                            paymentMethod: purchase.paymentMethod,
                            subtotal: purchase.subtotal,
                            discount: purchase.discount,
                            netTotal: purchase.netTotal,
                            paidAmount: purchase.paidAmount,
                            pendingAmount: purchase.pendingAmount,
                            items: purchase.items.map((i) => {
                              'name': i.productName,
                              'qty': i.qty,
                              'price': i.price,
                              'total': i.totalPrice,
                            }).toList(),
                            isThermal: false,
                          );
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text('Print A4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0f172a),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF0f172a),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: const Color(0xFF0f172a),
            ),
          ),
        ],
      ),
    );
  }
}
