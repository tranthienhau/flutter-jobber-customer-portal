import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final customer = ref.watch(customerProvider);
    final unread = ref.watch(unreadCountProvider);
    return Scaffold(
      floatingActionButton: session.linked
          ? PrimaryButton('New request',
              key: const Key('home-new-request'),
              icon: LucideIcons.plus,
              expand: false,
              onPressed: () => context.push('/new-request'))
          : null,
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 110), children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(session.linked ? 'Good morning,\n${customer.firstName}' : 'Welcome, ${customer.firstName}',
                    style: AppText.display(size: 26)),
                const SizedBox(height: 6),
                Text(fmtDayTime(ref.watch(clockProvider)), style: AppText.caption()),
              ]),
            ),
            CircleIconButton(LucideIcons.bell,
                key: const Key('bell'),
                tooltip: 'Notifications',
                badge: unread > 0,
                onTap: () => context.push('/notifications')),
            const SizedBox(width: 10),
            GestureDetector(
              key: const Key('avatar'),
              onTap: () => context.push('/account'),
              child: Avatar(customer.avatar, size: 44),
            ),
          ]),
          const SizedBox(height: 20),
          if (session.linked) const _LinkedHome() else const _EmptyHome(),
        ]),
      ),
    );
  }
}

class _LinkedHome extends ConsumerWidget {
  const _LinkedHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(propertiesProvider);
    final jobs = ref.watch(jobsProvider).value ?? const <Job>[];
    final balance = ref.watch(balanceProvider);
    final open = jobs.where((j) => j.status != JobStatus.completed).length;
    final urgent = jobs.where((j) => j.urgent && j.status != JobStatus.completed).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _NextVisitCard(),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
            child: _Stat(
                label: 'Open requests',
                value: '$open',
                foot: urgent > 0 ? '$urgent urgent' : 'All on track',
                footColor: AppColors.warning,
                icon: LucideIcons.triangleAlert)),
        const SizedBox(width: 10),
        const Expanded(
            child: _Stat(
                label: 'Visits this month',
                value: '18',
                foot: 'On track',
                footColor: AppColors.success,
                icon: LucideIcons.trendingUp)),
        const SizedBox(width: 10),
        Expanded(
            child: _Stat(
                label: 'Balance due',
                value: money.format(balance).replaceAll('.00', ''),
                foot: 'Net 30 terms',
                small: true,
                onTap: () => context.go('/invoices'))),
      ]),
      const SizedBox(height: 26),
      SectionHeader('Your sites', action: 'View all (3)', onAction: () {}),
      SizedBox(
        height: 214,
        child: props.when(
          data: (list) => ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _SiteCard(list[i]),
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.ink)),
          error: (e, _) => Text('$e'),
        ),
      ),
      const SizedBox(height: 26),
      const SectionHeader('Recent activity'),
      AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          _ActivityRow(
            icon: LucideIcons.sprayCan,
            title: 'Carpet extraction completed',
            sub: 'Riverside Medical Plaza, 8 photos attached',
            when: 'Oct 24',
            trailing: const StatusChip(JobStatus.completed),
            onTap: () => context.push('/requests/work/job-2154'),
          ),
          const Divider(height: 1, color: AppColors.hairline),
          _ActivityRow(
            icon: LucideIcons.receiptText,
            title: 'Invoice INV-10482 issued',
            sub: 'Due Nov 30, Northgate Office Park',
            when: 'Oct 31',
            trailing: Text(r'$1,920.00', style: AppText.numerals(size: 15)),
            onTap: () => context.push('/invoices/10482'),
          ),
        ]),
      ),
    ]);
  }
}

class _NextVisitCard extends StatelessWidget {
  const _NextVisitCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppRadius.card)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('NEXT VISIT', style: AppText.overline(color: const Color(0xFFE9E4CF))),
            const Spacer(),
            const Pill('Scheduled', bg: AppColors.lemon, fg: AppColors.ink, icon: LucideIcons.calendarClock),
          ]),
          const SizedBox(height: 12),
          Text('Tue, Nov 4 - 6:00 PM', style: AppText.headline(size: 22, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Nightly janitorial', style: AppText.title(color: Colors.white)),
          Text('Northgate Office Park, Building A', style: AppText.body(color: const Color(0xFFE9E4CF), size: 14)),
          const SizedBox(height: 14),
          const Divider(color: Color(0x33FFFFFF), height: 1),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(LucideIcons.users, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Crew 3 - Luis M.', style: AppText.label(color: Colors.white)),
                Text('Assigned in Jobber', style: AppText.caption(color: const Color(0xFFE9E4CF))),
              ]),
            ),
            TextButton(
              onPressed: () => context.push('/property/prop-northgate'),
              style: TextButton.styleFrom(foregroundColor: AppColors.lemon, minimumSize: const Size(44, 44)),
              child: Row(children: [
                Text('View site', style: AppText.label(color: AppColors.lemon)),
                const Icon(LucideIcons.chevronRight, size: 16),
              ]),
            ),
          ]),
        ]),
      );
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.label, required this.value, required this.foot, this.footColor, this.icon, this.small = false, this.onTap});
  final String label;
  final String value;
  final String foot;
  final Color? footColor;
  final IconData? icon;
  final bool small;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 36, child: Text(label, style: AppText.caption())),
          const SizedBox(height: 4),
          FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: small ? AppText.numerals(size: 20) : AppText.headline(size: 26))),
          const SizedBox(height: 6),
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 13, color: footColor), const SizedBox(width: 4)],
            Flexible(
                child: Text(foot,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.overline(color: footColor ?? AppColors.textSecondary).copyWith(letterSpacing: 0))),
          ]),
        ]),
      );
}

class _SiteCard extends StatelessWidget {
  const _SiteCard(this.p);
  final Property p;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 236,
        child: AppCard(
          padding: EdgeInsets.zero,
          onTap: () => context.push('/property/${p.id}'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              Img(p.image, height: 118, width: 236),
              if (p.tag != null)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Pill(p.tag!.toUpperCase(), bg: AppColors.ink, fg: Colors.white),
                ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.title()),
                Text(p.subtitle, style: AppText.caption()),
                const SizedBox(height: 8),
                Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.lemon, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('${p.services.length} services active', style: AppText.caption(color: AppColors.ink)),
                  const Spacer(),
                  const Icon(LucideIcons.arrowRight, size: 16),
                ]),
              ]),
            ),
          ]),
        ),
      );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(
      {required this.icon, required this.title, required this.sub, required this.when, required this.trailing, this.onTap});
  final IconData icon;
  final String title;
  final String sub;
  final String when;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: AppColors.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppText.label(weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(sub, style: AppText.caption()),
                const SizedBox(height: 6),
                trailing,
              ]),
            ),
            Text(when, style: AppText.caption(color: AppColors.textTertiary)),
          ]),
        ),
      );
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) => Column(children: [
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Stack(children: [
              const Img('empty-conference-room.jpg', radius: 14, height: 200, width: double.infinity),
              Positioned(
                left: 10,
                top: 10,
                child: const Pill('New account setup', bg: AppColors.surface, fg: AppColors.ink, icon: LucideIcons.sparkle),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
              child: Column(children: [
                Text('Your sites will appear here', textAlign: TextAlign.center, style: AppText.headline(size: 20)),
                const SizedBox(height: 10),
                Text(
                  'Once Midas links your service agreement, you will see each site, upcoming visits and invoices.',
                  textAlign: TextAlign.center,
                  style: AppText.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                PrimaryButton('Request a quote', trailing: LucideIcons.arrowRight, onPressed: () => context.push('/new-request')),
                const SizedBox(height: 10),
                SecondaryButton('Contact Midas', icon: LucideIcons.mail, onPressed: () => context.go('/support')),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        AppCard(
          color: AppColors.lemonTint,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(LucideIcons.hourglass, size: 20, color: AppColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('Service agreement pending', style: AppText.label(weight: FontWeight.w700))),
                  Text('In review', style: AppText.caption(color: AppColors.warning, weight: FontWeight.w700)),
                ]),
                const SizedBox(height: 4),
                Text('An account manager is linking your sites in Jobber. You will get an alert when it is done.',
                    style: AppText.caption()),
              ]),
            ),
          ]),
        ),
      ]);
}
