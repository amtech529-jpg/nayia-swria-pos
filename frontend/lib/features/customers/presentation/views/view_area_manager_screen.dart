import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/customers/data/models/area_manager_model.dart';
import 'package:frontend/features/sales/presentation/providers/sales_provider.dart';

class ViewAreaManagerScreen extends ConsumerWidget {
  final AreaManagerModel manager;

  const ViewAreaManagerScreen({super.key, required this.manager});

  void _openWhatsApp(BuildContext context, String phone, String name, String balance) async {
    final message = "محترم جناب $name آپ کی طرف رقم Rs $balance واجب الادا ہے۔ برائے مہربانی جلد از جلد ادائیگی ممکن بنائیں شکریہ\nMessage From:";
    final encodedMessage = Uri.encodeComponent(message);
    String formattedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '92${formattedPhone.substring(1)}';
    }
    final url = Uri.parse('https://wa.me/$formattedPhone?text=$encodedMessage');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For a fully functional overview, we would compute related customers and sales for this area.
    // Assuming we have sales and customers from other providers:
    final salesState = ref.watch(salesListProvider);

    int totalCustomersInArea = 0; // Requires customer provider if we filter by area
    double totalAreaSales = 0.0;
    
    salesState.whenData((sales) {
      // In a real scenario, we might link Sales -> Customers -> Area Manager.
      // Or if sales store location/area directly. Let's just mock or compute safely.
      for (var s in sales) {
        if (s.location == manager.area || s.location == 'Default') {
            // For now just simulating data
            // totalAreaSales += s.netTotal;
        }
      }
    });

    return MainLayout(
      currentRoute: '/area-managers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Area Managers', 'Overview']),
            const SizedBox(height: 16),
            _buildProfileHeader(context),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildInfoCard()),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: _buildStatsCard()),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder)
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryBtn.withOpacity(0.1),
            child: Text(manager.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryBtn)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(manager.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(manager.area, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (manager.phone != null && manager.phone!.isNotEmpty) ...[
                      InkWell(
                        onTap: () => _openWhatsApp(context, manager.phone!, manager.name, manager.balance.toStringAsFixed(2)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withOpacity(0.3))
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(manager.phone!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: manager.status == 'Active' ? const Color(0xFFdcfce7) : const Color(0xFFfee2e2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(manager.status, style: TextStyle(fontSize: 12, color: manager.status == 'Active' ? const Color(0xFF15803d) : const Color(0xFFb91c1c), fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/edit-area-manager', extra: manager);
            },
            icon: const Icon(Icons.edit, size: 16, color: Colors.white),
            label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBtn,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          _infoRow(Icons.phone, 'Phone', manager.phone ?? '-'),
          const SizedBox(height: 16),
          _infoRow(Icons.email, 'Email', manager.email ?? '-'),
          const SizedBox(height: 16),
          _infoRow(Icons.location_on, 'Address', manager.address ?? '-'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Financial Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(
                child: _statBox('Current Balance', 'Rs ${manager.balance.toStringAsFixed(2)}', Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statBox('Total Area Sales', 'Rs 0.00', Colors.blue), // Placeholder
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statBox('Active Customers', '0', Colors.green), // Placeholder
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()),
            ],
          )
        ],
      ),
    );
  }

  Widget _statBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, color: color.withOpacity(0.8), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
