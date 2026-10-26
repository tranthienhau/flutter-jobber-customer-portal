import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:midas_portal/app.dart';
import 'package:midas_portal/state/providers.dart';
import 'package:midas_portal/theme/app_theme.dart';

/// Drives the real app through sign in, home, a site, a change request, a new request
/// with photos, job tracking, completed work, invoices, support chat, notifications and
/// account, capturing one screenshot per key screen. Uses fixed pump(Duration) steps
/// (not pumpAndSettle) so the mock API latency and animations finish deterministically.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var converted = false;

  Future<void> settle(WidgetTester t, [int ms = 900]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shoot(WidgetTester t, String name) async {
    if (!converted) {
      await binding.convertFlutterSurfaceToImage();
      converted = true;
    }
    await settle(t, 600);
    await binding.takeScreenshot(name);
  }

  Future<void> tap(WidgetTester t, Finder f, [int ms = 1100]) async {
    for (var i = 0; i < 12 && f.evaluate().isEmpty; i++) {
      // Lazily built list: scroll the main vertical list until the target exists.
      final vertical = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down);
      await t.drag(vertical.first, const Offset(0, -220));
      await settle(t, 300);
    }
    await t.ensureVisible(f.first);
    await settle(t, 300);
    await t.tap(f.first, warnIfMissed: false);
    await settle(t, ms);
  }

  late void Function(String) goTo;
  Future<void> go(WidgetTester t, String path, [int ms = 1200]) async {
    goTo(path);
    await settle(t, ms);
  }

  Future<void> top(WidgetTester t) async {
    await t.drag(find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first,
        const Offset(0, 3000));
    await settle(t, 900);
  }

  Finder k(String key) => find.byKey(Key(key));

  testWidgets('capture Midas portal flows', (t) async {
    await preloadFonts();
    await t.pumpWidget(const ProviderScope(child: MidasPortalApp()));
    await settle(t, 2000);
    final c = ProviderScope.containerOf(t.element(find.byType(MidasPortalApp)));
    goTo = (path) => c.read(routerProvider).go(path);

    await shoot(t, '01-login');
    await tap(t, k('sign-in'), 2000);
    await shoot(t, '02-home');

    await t.drag(find.byType(Scrollable).first, const Offset(0, -330));
    await settle(t, 600);
    await tap(t, find.text('Northgate Office Park'), 1500);
    await shoot(t, '03-property-detail');

    await tap(t, k('change-svc-ng-janitorial'), 1500);
    await shoot(t, '04-request-change');
    await go(t, '/home');

    await tap(t, k('home-new-request'), 1500);
    await tap(t, k('add-photo'), 600);
    await t.drag(find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first,
        const Offset(0, 140));
    await settle(t, 900);
    await shoot(t, '05-new-request');
    await tap(t, k('submit-request'), 1800);
    await shoot(t, '06-request-submitted');
    await tap(t, find.text('Back to home'), 1500);

    await tap(t, k('tab-Requests'));
    await tap(t, k('job-job-2187'), 1500);
    await shoot(t, '07-job-status');
    await go(t, '/requests');
    await top(t);
    await shoot(t, '08-requests');

    await tap(t, k('job-job-2154'), 1500);
    await tap(t, k('star-5'), 400);
    await top(t);
    await shoot(t, '09-completed-work');
    await go(t, '/requests');

    await tap(t, k('tab-Invoices'), 1500);
    await shoot(t, '10-invoices');
    await tap(t, k('inv-10482'), 1500);
    await shoot(t, '11-invoice-detail');
    await go(t, '/invoices');

    await tap(t, k('tab-Support'), 1500);
    await t.enterText(k('chat-input'), 'Can the crew also restock paper towels on 2?');
    await settle(t, 300);
    await tap(t, k('chat-send'), 2200);
    await shoot(t, '12-support-chat');

    await tap(t, k('tab-Home'), 1200);
    await t.drag(find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first,
        const Offset(0, 1500));
    await settle(t, 800);
    await tap(t, k('bell'), 1200);
    await shoot(t, '13-notifications');
    await go(t, '/home');

    await tap(t, k('avatar'), 1200);
    await shoot(t, '14-account');
    c.read(sessionProvider.notifier).setLinked(false);
    await settle(t, 400);
    await go(t, '/home');
    await shoot(t, '15-home-empty');
    c.read(sessionProvider.notifier).setLinked(true);
    await settle(t, 1000);
  });
}
