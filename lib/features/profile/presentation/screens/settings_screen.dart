import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingTile(
            context,
            icon: LucideIcons.user,
            title: 'Edit Profile',
            onTap: () => context.push('/profile/edit'),
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.lock,
            title: 'Change Password',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.bell,
            title: 'Notifications',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('General'),
          _buildSettingTile(
            context,
            icon: LucideIcons.globe,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggle(),
            ),
            onTap: null,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSettingTile(
            context,
            icon: LucideIcons.helpCircle,
            title: 'Help Center',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.fileText,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _buildSettingTile(
            context,
            icon: LucideIcons.info,
            title: 'About BIZNET',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await authProvider.signOut();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: subtitleColor)) : null,
        trailing: trailing ?? Icon(LucideIcons.chevronRight, size: 18, color: theme.iconTheme.color),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

