import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:biznet/providers/auth_provider.dart';
import 'package:biznet/features/auth/presentation/screens/login_screen.dart';
import 'package:biznet/features/auth/presentation/screens/signup_screen.dart';
import 'package:biznet/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:biznet/features/home/presentation/screens/home_screen.dart';
import 'package:biznet/features/home/presentation/screens/search_screen.dart';
import 'package:biznet/features/home/presentation/screens/category_screen.dart';
import 'package:biznet/features/home/presentation/screens/all_businesses_screen.dart';
import 'package:biznet/features/home/presentation/screens/write_review_screen.dart';
import 'package:biznet/features/home/presentation/screens/business_profile_screen.dart';
import 'package:biznet/features/home/presentation/screens/main_screen.dart';
import 'package:biznet/features/profile/presentation/screens/profile_screen.dart';
import 'package:biznet/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:biznet/features/profile/presentation/screens/settings_screen.dart';
import 'package:biznet/features/business/presentation/screens/business_dashboard_screen.dart';
import 'package:biznet/features/business/presentation/screens/manage_products_screen.dart';
import 'package:biznet/features/business/presentation/screens/business_reviews_screen.dart';
import 'package:biznet/features/business/presentation/screens/analytics_screen.dart';
import 'package:biznet/features/business/presentation/screens/build_profile_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.userModel != null;
        final isAuthPath = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
        final isVerifyPath = state.matchedLocation == '/verify-email';

        if (!isLoggedIn && !isAuthPath) {
          return '/login';
        }

        if (isLoggedIn) {
          if (!authProvider.isEmailVerified && !isVerifyPath) {
            return '/verify-email';
          }

          // Redirect businesses to build profile if not completed
          if (authProvider.userModel?.role == 'business' &&
              !authProvider.userModel!.hasBuiltProfile &&
              state.matchedLocation != '/build-profile') {
            return '/build-profile';
          }

          // Redirect businesses away from customer home
          if (state.matchedLocation == '/' && authProvider.userModel?.role == 'business') {
            return '/business-dashboard';
          }

          if (isAuthPath || isVerifyPath) {
            if (authProvider.userModel?.role == 'business') {
              return '/business-dashboard';
            }
            return '/';
          }
        }

        return null;
      },
      routes: [
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return MainScreen(child: child);
          },
          routes: [
            // Customer Routes
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) {
                // Determine query parameters regardless of go_router version breaking changes
                final uri = Uri.parse(state.matchedLocation);
                final queryParams = uri.queryParameters;

                final categoryId = queryParams['category'];

                return SearchScreen(initialCategory: categoryId);
              },
            ),
            GoRoute(
              path: '/category/:id',
              builder: (context, state) {
                final categoryId = state.pathParameters['id']!;
                final uri = Uri.parse(state.matchedLocation);
                final categoryName = uri.queryParameters['name'] ?? 'Category';
                return CategoryScreen(
                  categoryId: categoryId,
                  categoryName: categoryName,
                );
              },
            ),
            GoRoute(
              path: '/all-businesses',
              builder: (context, state) => const AllBusinessesScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/write-review/:businessId/:businessName',
              builder: (context, state) => WriteReviewScreen(
                businessId: state.pathParameters['businessId']!,
                businessName: state.pathParameters['businessName']!,
                productId: state.queryParameters['productId'],
                productName: state.queryParameters['productName'],
              ),
            ),
            // Business Routes
            GoRoute(
              path: '/business-dashboard',
              builder: (context, state) => const BusinessDashboardScreen(),
            ),
            GoRoute(
              path: '/manage-products',
              builder: (context, state) => const ManageProductsScreen(),
            ),
            GoRoute(
              path: '/business-reviews',
              builder: (context, state) => const BusinessReviewsScreen(),
            ),
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/build-profile',
          builder: (context, state) => const BuildProfileScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) => const VerifyEmailScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/business/:id',
          builder: (context, state) => BusinessProfileScreen(
            businessId: state.pathParameters['id']!,
          ),
        ),
      ],
    );
  }
}
