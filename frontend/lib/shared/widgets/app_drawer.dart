import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/features/settings/presentation/providers/config_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: config.primaryColor,
            ),
            accountName: Text(
              config.shopName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('admin@shop.com'),
            currentAccountPicture: config.logoUrl != null
                ? CircleAvatar(backgroundImage: NetworkImage(config.logoUrl!))
                : const CircleAvatar(child: Icon(Icons.person)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('POS'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Inventory'),
            onTap: () {},
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
