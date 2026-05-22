import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/shared/widgets/main_layout.dart';
import 'package:frontend/shared/widgets/breadcrumb_widget.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/customers/data/models/area_manager_model.dart';
import 'package:frontend/features/customers/presentation/providers/area_managers_provider.dart';
import 'package:uuid/uuid.dart';

class AddAreaManagerScreen extends ConsumerStatefulWidget {
  final AreaManagerModel? manager;

  const AddAreaManagerScreen({super.key, this.manager});

  @override
  ConsumerState<AddAreaManagerScreen> createState() => _AddAreaManagerScreenState();
}

class _AddAreaManagerScreenState extends ConsumerState<AddAreaManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    if (widget.manager != null) {
      _nameCtrl.text = widget.manager!.name;
      _phoneCtrl.text = widget.manager!.phone ?? '';
      _emailCtrl.text = widget.manager!.email ?? '';
      _addressCtrl.text = widget.manager!.address ?? '';
      _areaCtrl.text = widget.manager!.area;
      _status = widget.manager!.status;
    }
  }

  void _saveManager() async {
    if (_formKey.currentState!.validate()) {
      final manager = AreaManagerModel(
        id: widget.manager?.id ?? const Uuid().v4(),
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        email: _emailCtrl.text,
        address: _addressCtrl.text,
        area: _areaCtrl.text.isNotEmpty ? _areaCtrl.text : 'None',
        balance: widget.manager?.balance ?? 0.0,
        status: _status,
      );

      final notifier = ref.read(areaManagersListProvider.notifier);
      if (widget.manager != null) {
        await notifier.updateAreaManager(manager);
      } else {
        await notifier.addAreaManager(manager);
      }

      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.manager == null ? 'Add Area Manager' : 'Edit Area Manager';
    return MainLayout(
      currentRoute: '/area-managers',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbWidget(items: const ['Home', 'Area Managers', 'Add Manager']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder)
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Name', _nameCtrl, required: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Phone', _phoneCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Email', _emailCtrl)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Area', _areaCtrl)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField('Address', _addressCtrl, maxLines: 3),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.tableText)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _status,
                          items: const [
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                          ],
                          onChanged: (v) => setState(() => _status = v!),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.cardBorder)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveManager,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBtn,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(widget.manager == null ? 'Save Manager' : 'Update Manager', style: const TextStyle(color: Colors.white)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.tableText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: required ? (v) => v!.isEmpty ? 'Required field' : null : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.cardBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.cardBorder)),
          ),
        ),
      ],
    );
  }
}
