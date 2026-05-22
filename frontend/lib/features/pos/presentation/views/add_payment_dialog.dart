import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/features/sales/data/models/sale_model.dart';
import 'package:frontend/features/customers/data/models/customer_model.dart';
import 'package:frontend/features/customers/presentation/providers/customers_provider.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';

class AddPaymentDialog extends ConsumerStatefulWidget {
  final SaleModel sale;

  const AddPaymentDialog({super.key, required this.sale});

  @override
  ConsumerState<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends ConsumerState<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.sale.pendingAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFdbeafe), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.payment, color: Color(0xFF2563eb), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0f172a))),
                      Text('Invoice #${widget.sale.invoiceNo}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748b))),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF64748b)),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8fafc),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFe2e8f0)),
                ),
                child: Column(
                  children: [
                    _RowInfo('Total Bill:', 'Rs ${widget.sale.netTotal.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    _RowInfo('Already Paid:', 'Rs ${widget.sale.paidAmount.toStringAsFixed(0)}', color: const Color(0xFF10b981)),
                    const SizedBox(height: 6),
                    _RowInfo('Pending Amount:', 'Rs ${pending.toStringAsFixed(0)}', color: Colors.red, bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Customer Name if exists
              if (widget.sale.customerName != null) ...[
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748b)),
                    const SizedBox(width: 4),
                    Text(
                      'Customer: ${widget.sale.customerName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Amount to Pay input
              const Text('Payment Amount (Rs)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Enter amount...',
                  prefixText: 'Rs ',
                  prefixStyle: const TextStyle(color: Color(0xFF64748b), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFFfafafa),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFcbd5e1))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                  final numVal = double.tryParse(val);
                  if (numVal == null || numVal <= 0) return 'Please enter a valid positive number';
                  if (numVal > pending) return 'Cannot pay more than pending Rs ${pending.toStringAsFixed(0)}';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748b))),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563eb),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _RowInfo(String label, String value, {Color? color, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748b))),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: color ?? const Color(0xFF1e293b))),
      ],
    );
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final payAmount = double.parse(_amountCtrl.text);

      // 1. Calculate updated sale fields
      final updatedPaid = widget.sale.paidAmount + payAmount;
      final updatedPending = widget.sale.netTotal - updatedPaid;

      final updatedSale = widget.sale.copyWith(
        paidAmount: updatedPaid,
        pendingAmount: updatedPending,
      );

      // 2. Save sale update
      final saleSuccess = await ref.read(salesListProvider.notifier).updateSale(updatedSale);

      if (saleSuccess) {
        // 3. Update customer outstanding balance if customer is attached
        final customerName = widget.sale.customerName;
        if (customerName != null && customerName != 'Walk In Customer') {
          final customersList = ref.read(customersListProvider).value ?? [];
          final customer = customersList.firstWhere(
            (c) => c.id == widget.sale.customerId || c.name == customerName,
            orElse: () => CustomerModel(id: '', name: ''),
          );

          if (customer.id.isNotEmpty) {
            // Debt is reduced when paid
            final updatedBalance = customer.balance - payAmount;
            final updatedCust = customer.copyWith(balance: updatedBalance);
            await ref.read(customersListProvider.notifier).updateCustomer(updatedCust);
          }
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Rs ${payAmount.toStringAsFixed(0)} payment received successfully!'),
              backgroundColor: const Color(0xFF10b981),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Error saving payment. Please try again.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
