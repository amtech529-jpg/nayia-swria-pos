import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';

class PaymentMethodCards extends ConsumerWidget {
  const PaymentMethodCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    final sales = ref.watch(salesListProvider).value ?? [];

    double getMethodTotal(String name) {
      return sales.where((s) => s.paymentMethod.toLowerCase() == name.toLowerCase()).fold(0.0, (sum, s) => sum + s.netTotal);
    }
    
    int getMethodCount(String name) {
      return sales.where((s) => s.paymentMethod.toLowerCase() == name.toLowerCase()).length;
    }

    final methods = [
      _PMData('Cash', Icons.attach_money, const Color(0xFF22c55e), const Color(0xFFdcfce7), getMethodTotal('Cash'), getMethodCount('Cash')),
      _PMData('Cheque', Icons.receipt_outlined, const Color(0xFFf97316), const Color(0xFFffedd5), getMethodTotal('Cheque'), getMethodCount('Cheque')),
      _PMData('Online', Icons.wifi_outlined, const Color(0xFF06b6d4), const Color(0xFFcffafe), getMethodTotal('Online'), getMethodCount('Online')),
      _PMData('Bank Transfer', Icons.account_balance_outlined, const Color(0xFF6366f1), const Color(0xFFe0e7ff), getMethodTotal('Bank Transfer'), getMethodCount('Bank Transfer')),
      _PMData('Jazz Cash', Icons.phone_android_outlined, const Color(0xFFef4444), const Color(0xFFfee2e2), getMethodTotal('Jazz Cash'), getMethodCount('Jazz Cash')),
      _PMData('Easypaisa', Icons.mobile_friendly_outlined, const Color(0xFFef4444), const Color(0xFFfee2e2), getMethodTotal('Easypaisa'), getMethodCount('Easypaisa')),
      _PMData('Card', Icons.credit_card_outlined, const Color(0xFF3b82f6), const Color(0xFFdbeafe), getMethodTotal('Card'), getMethodCount('Card')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.tableText)),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 1.6 : 2.2,
          ),
          itemCount: methods.length,
          itemBuilder: (_, i) => _PMCard(data: methods[i]),
        ),
      ],
    );
  }
}

class _PMData {
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final double totalAmount;
  final int count;
  _PMData(this.name, this.icon, this.iconColor, this.bgColor, this.totalAmount, this.count);
}

class _PMCard extends StatefulWidget {
  final _PMData data;
  const _PMCard({required this.data});
  @override
  State<_PMCard> createState() => _PMCardState();
}

class _PMCardState extends State<_PMCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _hovered ? widget.data.iconColor.withOpacity(0.4) : AppColors.cardBorder),
          boxShadow: _hovered
              ? [BoxShadow(color: widget.data.iconColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: widget.data.bgColor, shape: BoxShape.circle),
              child: Icon(widget.data.icon, color: widget.data.iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.data.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tableText),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Total: ${widget.data.count} sales', style: const TextStyle(fontSize: 10, color: AppColors.tableSubText)),
                  const SizedBox(height: 2),
                  Text('Rs ${widget.data.totalAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.data.iconColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
