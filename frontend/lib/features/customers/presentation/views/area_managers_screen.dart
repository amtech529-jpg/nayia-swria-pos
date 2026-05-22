import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/pos_table.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/features/customers/presentation/providers/area_managers_provider.dart';

class AreaManagersScreen extends ConsumerStatefulWidget {
  const AreaManagersScreen({super.key});

  @override
  ConsumerState<AreaManagersScreen> createState() => _AreaManagersScreenState();
}

class _AreaManagersScreenState extends ConsumerState<AreaManagersScreen> {
  final _searchCtrl = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(areaManagersListProvider.notifier).loadAreaManagers());
  }

  void _openWhatsApp(String phone, String name, String balance) async {
    final message = "محترم جناب $name آپ کی طرف رقم Rs $balance واجب الادا ہے۔ برائے مہربانی جلد از جلد ادائیگی ممکن بنائیں شکریہ\nMessage From:";
    final encodedMessage = Uri.encodeComponent(message);
    // Format phone number if needed (assuming international format, or fallback)
    String formattedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '92${formattedPhone.substring(1)}';
    }
    final url = Uri.parse('https://wa.me/$formattedPhone?text=$encodedMessage');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch WhatsApp')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final areaManagersState = ref.watch(areaManagersListProvider);

    return MainLayout(
      currentRoute: '/area-managers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BreadcrumbWidget(items: ['Home', 'Area Managers']),
            const SizedBox(height: 16),
            areaManagersState.when(
              data: (managers) => _buildTableCard(managers),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCard(List<dynamic> managers) {
    // Filter managers based on search query
    final filteredManagers = managers.where((m) {
      final query = _searchCtrl.text.toLowerCase();
      return m.name.toLowerCase().contains(query) || 
             (m.phone?.toLowerCase().contains(query) ?? false) ||
             (m.area.toLowerCase().contains(query));
    }).toList();

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('All Area Managers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                const Spacer(),
                PosButton(label: '+ Add Manager', onTap: () {
                  context.push('/add-area-manager');
                }),
                const SizedBox(width: 12),
                PosSearchField(
                  controller: _searchCtrl, 
                  hint: 'Search Manager',
                  onChanged: (v) => setState((){}),
                ),
              ],
            ),
          ),
          PosTable(
            columns: const ['', 'NAME', 'PHONE', 'AREA', 'BALANCE', 'STATUS', 'ACTIONS'],
            columnWidths: const [50, 250, 150, 200, 150, 100, 100],
            rows: filteredManagers.map((m) => [
              Checkbox(value: false, onChanged: (_) {}),
              Row(
                children: [
                  if (m.phone != null && m.phone!.isNotEmpty) ...[
                    InkWell(
                      onTap: () => _openWhatsApp(m.phone!, m.name, m.balance.toStringAsFixed(2)),
                      child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        context.push('/view-area-manager', extra: m);
                      },
                      child: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBtn)),
                    ),
                  ),
                ],
              ),
              m.phone ?? '-',
              m.area,
              'Rs ${m.balance.toStringAsFixed(2)}',
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: m.status == 'Active' ? const Color(0xFFdcfce7) : const Color(0xFFfee2e2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(m.status, style: TextStyle(fontSize: 11, color: m.status == 'Active' ? const Color(0xFF15803d) : const Color(0xFFb91c1c), fontWeight: FontWeight.bold)),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: AppColors.tableSubText),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('View Overview'),
                    onTap: () {
                      context.push('/view-area-manager', extra: m);
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('Edit'),
                    onTap: () {
                      context.push('/edit-area-manager', extra: m);
                    },
                  ),
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () async {
                      await ref.read(areaManagersListProvider.notifier).removeAreaManager(m.id);
                    },
                  ),
                ],
              ),
            ]).toList(),
          ),
        ],
      ),
    );
  }
}
