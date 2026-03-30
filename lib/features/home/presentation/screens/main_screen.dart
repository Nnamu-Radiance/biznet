import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final isBusiness = user?.role == 'business';

    int calculateSelectedIndex(String location) {
      if (isBusiness) {
        if (location.startsWith('/business-dashboard')) return 0;
        if (location.startsWith('/manage-products')) return 1;
        if (location.startsWith('/business-reviews')) return 2;
        if (location.startsWith('/analytics')) return 3;
        return 0;
      } else {
        if (location.startsWith('/search')) return 1;
        if (location.startsWith('/profile')) return 2;
        return 0;
      }
    }

    void onItemTapped(int index, BuildContext context) {
      if (isBusiness) {
        switch (index) {
          case 0:
            context.go('/business-dashboard');
            break;
          case 1:
            context.go('/manage-products');
            break;
          case 2:
            context.go('/business-reviews');
            break;
          case 3:
            context.go('/analytics');
            break;
        }
      } else {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/search');
            break;
          case 2:
            context.go('/profile');
            break;
        }
      }
    }

    final items = isBusiness
        ? <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard),
              label: 'Stats',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.package),
              label: 'Products',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageSquare),
              label: 'Reviews',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.barChart3),
              label: 'Insights',
            ),
          ]
        : <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.search),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Profile',
            ),
          ];

    return WillPopScope(
      onWillPop: () async {
        final location = GoRouterState.of(context).matchedLocation;
        final currentIndex = calculateSelectedIndex(location);
        if (isBusiness) {
          if (currentIndex != 0) {
            context.go('/business-dashboard');
            return false;
          }
        } else {
          if (currentIndex != 0) {
            context.go('/');
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: calculateSelectedIndex(GoRouterState.of(context).matchedLocation),
          onTap: (index) => onItemTapped(index, context),
          selectedItemColor: const Color(0xFF1E2E4F),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: items,
        ),
      ),
    );
  }
}
