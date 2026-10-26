import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/account/account_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/invoices/invoice_detail_screen.dart';
import 'features/invoices/invoices_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/property/property_detail_screen.dart';
import 'features/requests/completed_work_screen.dart';
import 'features/requests/job_status_screen.dart';
import 'features/requests/new_request_screen.dart';
import 'features/requests/request_change_screen.dart';
import 'features/requests/request_submitted_screen.dart';
import 'features/requests/requests_screen.dart';
import 'features/support/support_chat_screen.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    redirect: (_, state) {
      final signedIn = ref.read(sessionProvider).signedIn;
      if (!signedIn && state.matchedLocation != '/login') return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/new-request', parentNavigatorKey: _rootKey, builder: (_, _) => const NewRequestScreen()),
      GoRoute(
          path: '/request-submitted/:id',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => RequestSubmittedScreen(id: s.pathParameters['id']!)),
      GoRoute(
          path: '/request-change/:pid/:sid',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => RequestChangeScreen(propertyId: s.pathParameters['pid']!, serviceId: s.pathParameters['sid']!)),
      GoRoute(path: '/notifications', parentNavigatorKey: _rootKey, builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/account', parentNavigatorKey: _rootKey, builder: (_, _) => const AccountScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
            GoRoute(path: '/property/:id', builder: (_, s) => PropertyDetailScreen(id: s.pathParameters['id']!)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/requests', builder: (_, _) => const RequestsScreen(), routes: [
              GoRoute(path: 'job/:id', builder: (_, s) => JobStatusScreen(id: s.pathParameters['id']!)),
              GoRoute(path: 'work/:id', builder: (_, s) => CompletedWorkScreen(id: s.pathParameters['id']!)),
            ]),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/invoices', builder: (_, _) => const InvoicesScreen(), routes: [
              GoRoute(path: ':id', builder: (_, s) => InvoiceDetailScreen(id: s.pathParameters['id']!)),
            ]),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/support', builder: (_, _) => const SupportChatScreen())]),
        ],
      ),
    ],
  );
});

class MidasPortalApp extends ConsumerWidget {
  const MidasPortalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        title: 'Midas Client Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: ref.watch(routerProvider),
      );
}
