import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});
  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool push = true, email = true, sms = false, faceId = true;

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(customerProvider);
    final session = ref.watch(sessionProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(8, 4, 8, 32), children: [
          PushedHeader(center: Text('Account', style: AppText.headline(size: 18))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AppCard(
                child: Row(children: [
                  Avatar(c.avatar, size: 72),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: AppText.headline(size: 18)),
                      Text('${c.role}, ${c.company}', style: AppText.caption()),
                      const SizedBox(height: 4),
                      Text(c.email, style: AppText.caption(color: AppColors.ink)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              _Group('Sites and team', [
                _Row(LucideIcons.building2, 'Linked sites', trailing: '3'),
                _Row(LucideIcons.users, 'Team members', sub: 'Dana Whitfield (Admin), Kevin Ortiz (View only)'),
              ]),
              const SizedBox(height: 14),
              _Group('Notifications', [
                _Toggle('Push notifications', 'Crew arrivals, job completion', push, (v) => setState(() => push = v)),
                _Toggle('Email summary', 'Invoices and monthly service reports', email, (v) => setState(() => email = v)),
                _Toggle('SMS alerts', 'Urgent dispatch updates', sms, (v) => setState(() => sms = v)),
              ]),
              const SizedBox(height: 14),
              _Group('Connected systems', const [
                _Conn(LucideIcons.briefcaseBusiness, 'Jobs and visits', 'Jobber'),
                _Conn(LucideIcons.receipt, 'Invoices', 'QuickBooks Online'),
                _Conn(LucideIcons.messagesSquare, 'Messages and leads', 'GoHighLevel'),
              ]),
              const SizedBox(height: 14),
              _Group('Security and demo', [
                _Toggle('Face ID login', 'Sign in with biometrics', faceId, (v) => setState(() => faceId = v)),
                _Toggle('Service agreement linked', 'Turn off to preview the first-run home', session.linked,
                    (v) => ref.read(sessionProvider.notifier).setLinked(v), key: const Key('toggle-linked')),
              ]),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).signOut();
                    context.go('/login');
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.danger, minimumSize: const Size(44, 48)),
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: Text('Sign out', style: AppText.label(color: AppColors.danger)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.children);
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppText.title()),
          const SizedBox(height: 6),
          ...children,
        ]),
      );
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.title, {this.sub, this.trailing});
  final IconData icon;
  final String title;
  final String? sub;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.label()),
              if (sub != null) Text(sub!, style: AppText.caption()),
            ]),
          ),
          if (trailing != null) Pill(trailing!, bg: AppColors.lemonTint, fg: AppColors.ink),
          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 8),
        ]),
      );
}

class _Toggle extends StatelessWidget {
  const _Toggle(this.title, this.sub, this.value, this.onChanged, {super.key});
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppText.label()),
            Text(sub, style: AppText.caption()),
          ]),
        ),
        Switch(value: value, onChanged: onChanged),
      ]);
}

class _Conn extends StatelessWidget {
  const _Conn(this.icon, this.title, this.system);
  final IconData icon;
  final String title;
  final String system;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.label()),
              Text(system, style: AppText.caption()),
            ]),
          ),
          const Pill('Connected', bg: AppColors.successTint, fg: AppColors.success, icon: LucideIcons.circleCheck),
          const SizedBox(width: 8),
        ]),
      );
}
