import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui/pages/welcome_screen.dart';
import 'ui/pages/signup_screen.dart';
import 'ui/pages/login_screen.dart';
import 'ui/pages/home_map_screen.dart';
import 'ui/pages/explore_screen.dart';
import 'ui/pages/listing_detail_screen.dart';
import 'ui/pages/wishlist_screen.dart';
import 'ui/pages/profile_screen.dart';

// Custom page transition
Page<T> _buildPageWithTransition<T extends Object?>(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const WelcomeScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const SignUpScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const HomeMapScreen(),
      ),
    ),
    GoRoute(
      path: '/explore',
      name: 'explore',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const ExploreScreen(),
      ),
    ),
    GoRoute(
      path: '/listing/:id',
      name: 'listing-detail',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return _buildPageWithTransition(
          context,
          state,
          ListingDetailScreen(listingId: id),
        );
      },
    ),
    GoRoute(
      path: '/wishlist',
      name: 'wishlist',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const WishlistScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => _buildPageWithTransition(
        context,
        state,
        const ProfileScreen(),
      ),
    ),
  ],
);
