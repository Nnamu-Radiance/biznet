import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/business_provider.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({Key? key}) : super(key: key);

  @override
  _BusinessDashboardScreenState createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.userModel != null) {
        Provider.of<BusinessProvider>(context, listen: false)
            .fetchBusinessByOwner(
          authProvider.userModel!.uid,
          userName: authProvider.userModel!.name,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final businessProvider = Provider.of<BusinessProvider>(context);
    final user = authProvider.userModel;
    final business = businessProvider.currentBusiness;
    final theme = Theme.of(context);
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final primaryColor = theme.colorScheme.primary;

    if (businessProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('Business Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.settings, color: theme.iconTheme.color),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: Icon(LucideIcons.logOut, color: theme.iconTheme.color),
            onPressed: () async {
              await authProvider.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.name ?? 'Business Owner'}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              business?.name ?? 'Manage your business reputation and products.',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),

            // Onboarding Banner
            if (user?.hasBuiltProfile == false)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2E4F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E2E4F).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.sparkles, color: Color(0xFF1E2E4F)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complete Your Profile',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Add your business details and products to start attracting customers.',
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => context.push('/build-profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2E4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Start'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Trust Score',
                    business?.trustScore.toStringAsFixed(1) ?? '0.0',
                    LucideIcons.shieldCheck,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Reviews',
                    businessProvider.reviews.length.toString(),
                    LucideIcons.messageSquare,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildActionTile(
              context,
              'Manage Products',
              'Add or edit your product listings',
              LucideIcons.package,
              Colors.orange,
                  () => context.go('/manage-products'),
            ),
            _buildActionTile(
              context,
              'View Reviews',
              'See what customers are saying',
              LucideIcons.star,
              Colors.amber,
                  () => context.go('/business-reviews'),
            ),
            _buildActionTile(
              context,
              'Business Profile',
              'Update your business information',
              LucideIcons.building,
              Colors.purple,
                  () {
                // For now, businesses can use the same profile edit or a specific one
                context.push('/profile/edit');
              },
            ),
            _buildActionTile(
              context,
              'Analytics',
              'Track your performance',
              LucideIcons.barChart,
              Colors.teal,
                  () => context.go('/analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color.fromRGBO(color.red, color.green, color.blue, 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8))),
        trailing: Icon(LucideIcons.chevronRight, size: 20, color: theme.iconTheme.color),
        onTap: onTap,
      ),
    );
  }
}
