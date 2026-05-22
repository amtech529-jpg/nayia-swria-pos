import 'package:flutter/material.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';
import 'package:frontend/core/utils/export_service.dart';

class InvoiceDialog extends StatelessWidget {
  final SaleModel sale;

  const InvoiceDialog({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final totalQty = sale.items.fold<int>(0, (sum, item) => sum + item.qty);

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
                    'Invoice',
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

              // Business Logo / Header Image
              Center(
                child: Column(
                  children: [
                    Image.network(
                      'https://lajpaltraders.bosonstudio.com/uploads/business_logos/1715082054_nayia_swaria_logo.png',
                      height: 50,
                      errorBuilder: (c, e, s) => const Icon(Icons.business, size: 50, color: Color(0xFF10b981)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Contact : ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748b)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF0f172a), thickness: 1.5),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow('Invoice:', '#${sale.invoiceNo}', isBold: true),
              _buildDetailRow('Date:', sale.saleDate.contains('T') 
                ? sale.saleDate.replaceAll('T', ' ').substring(0, 19) 
                : sale.saleDate),
              _buildDetailRow('Customer:', sale.customerName ?? 'Walk In Customer'),
              _buildDetailRow('Contact:', ''),
              _buildDetailRow('Address:', sale.customerName == 'Walk In Customer' ? 'Walk In Customer Address' : 'Customer Address'),
              _buildDetailRow('Sale\'s Person:', 'Admin'),
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
                    Expanded(child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                    Expanded(child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                  ],
                ),
              ),

              // Table Body
              ...sale.items.asMap().entries.map((entry) {
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
                      Expanded(child: Text('${item.qty} Pc', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                      Expanded(child: Text('${item.price.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                      Expanded(child: Text('${item.totalPrice.toStringAsFixed(0)}/${item.totalPrice.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Calculation block
              _buildCalcRow('Subtotal (Rs):', '${sale.subtotal.toStringAsFixed(0)}/${sale.subtotal.toStringAsFixed(0)}'),
              _buildCalcRow('Items:', '$totalQty Pc'),
              _buildCalcRow('Discount (Rs):', '- ${sale.discount.toStringAsFixed(0)}'),
              _buildCalcRow('Total Payable (Rs):', sale.netTotal.toStringAsFixed(0), isBold: true),
              _buildCalcRow('Payment Received (Rs):', sale.paidAmount.toStringAsFixed(0)),
              _buildCalcRow('Balance (Rs):', sale.pendingAmount.toStringAsFixed(0)),
              _buildCalcRow('Cash Received (Rs):', (sale.paidAmount + sale.pendingAmount).toStringAsFixed(0)), // approximation or exact if tracked
              _buildCalcRow('Change (Rs):', '0'),
              const SizedBox(height: 20),

              // Footer
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Developed by Boson Studio',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748b)),
                    ),
                    Text(
                      'Contact: 03068216606',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94a3b8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ExportService.printInvoice(
                            invoiceNo: sale.invoiceNo,
                            customerName: sale.customerName ?? 'Walk In Customer',
                            saleDate: sale.saleDate,
                            location: sale.location,
                            paymentMethod: sale.paymentMethod,
                            subtotal: sale.subtotal,
                            discount: sale.discount,
                            netTotal: sale.netTotal,
                            paidAmount: sale.paidAmount,
                            pendingAmount: sale.pendingAmount,
                            items: sale.items.map((i) => {
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
                          await ExportService.printInvoice(
                            invoiceNo: sale.invoiceNo,
                            customerName: sale.customerName ?? 'Walk In Customer',
                            saleDate: sale.saleDate,
                            location: sale.location,
                            paymentMethod: sale.paymentMethod,
                            subtotal: sale.subtotal,
                            discount: sale.discount,
                            netTotal: sale.netTotal,
                            paidAmount: sale.paidAmount,
                            pendingAmount: sale.pendingAmount,
                            items: sale.items.map((i) => {
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
      padding: const EdgeInsets.symmetric(vertical: 2),
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
