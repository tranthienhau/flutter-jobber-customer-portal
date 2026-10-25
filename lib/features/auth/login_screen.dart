import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(clipBehavior: Clip.none, children: [
            SizedBox(height: 250 + top, width: double.infinity, child: const Img('lobby-hero.jpg')),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.6, 1],
                    colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.95)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: -26,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.card),
                child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/brand/app-icon.png')),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back', style: AppText.display(size: 28)),
              const SizedBox(height: 8),
              Text('Manage your sites, requests and invoices in one place.', style: AppText.body(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Work email', style: AppText.label()),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: 'ops@northgateoffice.com',
                    decoration: const InputDecoration(prefixIcon: Icon(LucideIcons.mail, size: 18)),
                  ),
                  const SizedBox(height: 14),
                  Text('Password', style: AppText.label()),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: 'portal-demo-2026',
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(LucideIcons.lock, size: 18),
                      suffixIcon: Icon(LucideIcons.eye, size: 18),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(foregroundColor: AppColors.accentFill, minimumSize: const Size(44, 44)),
                      child: Text('Forgot password?', style: AppText.label(color: AppColors.accentFill)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  PrimaryButton('Sign in', key: const Key('sign-in'), onPressed: () {
                    ref.read(sessionProvider.notifier).signIn();
                    context.go('/home');
                  }),
                  const SizedBox(height: 12),
                  SecondaryButton('Use a magic link instead', icon: LucideIcons.wandSparkles, onPressed: () {}),
                ]),
              ),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Your portal account is linked to your Midas service agreement.',
                      style: AppText.caption(color: AppColors.textTertiary)),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
