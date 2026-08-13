import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark themes'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const ListTile(
            title: Text('IP Radio App'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
