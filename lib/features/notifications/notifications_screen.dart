import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(noticesProvider);
    final today = ref.watch(clockProvider);
    bool isToday(DateTime d) => d.year == today.year && d.month == today.month && d.day == today.day;
    final t = list.where((n) => isToday(n.at)).toList();
    final e = list.where((n) => !isToday(n.at)).toList();
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(8, 4, 8, 32), children: [
          PushedHeader(
            center: Text('Notifications', style: AppText.headline(size: 18)),
            trailing: IconButton(tooltip: 'Settings', onPressed: () => context.push('/account'), icon: const Icon(LucideIcons.settings, size: 20)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('TODAY', style: AppText.overline()),
                const Spacer(),
                TextButton(
                  key: const Key('mark-read'),
                  onPressed: () => ref.read(noticesProvider.notifier).markAllRead(),
                  style: TextButton.styleFrom(foregroundColor: AppColors.accentFill, minimumSize: const Size(44, 44)),
                  child: Text('Mark all read', style: AppText.label(color: AppColors.accentFill)),
                ),
              ]),
              for (final n in t) ...[_NoticeTile(n), const SizedBox(height: 10)],
              const SizedBox(height: 14),
              Text('EARLIER', style: AppText.overline()),
              const SizedBox(height: 10),
              for (final n in e) ...[_NoticeTile(n), const SizedBox(height: 10)],
            ]),
          ),
        ]),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile(this.n);
  final PortalNotice n;

  @override
  Widget build(BuildContext context) {
    final (icon, bg) = switch (n.kind) {
      NoticeKind.onSite => (LucideIcons.mapPinCheck, AppColors.infoTint),
      NoticeKind.scheduled => (LucideIcons.calendarClock, AppColors.lemonTint),
      NoticeKind.completed => (LucideIcons.circleCheck, AppColors.successTint),
      NoticeKind.invoice => (LucideIcons.receiptText, AppColors.surfaceAlt),
      NoticeKind.approved => (LucideIcons.badgeCheck, AppColors.successTint),
    };
    return AppCard(
      color: n.unread ? AppColors.lemonTint : null,
      onTap: n.route == null ? null : () => context.push(n.route!),
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        n.image != null
            ? Img(n.image!, radius: 12, width: 44, height: 44)
            : Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: n.unread ? AppColors.surface : bg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 20, color: AppColors.ink),
              ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.title, style: AppText.label(weight: FontWeight.w700))),
              Text(n.at.day == 3 ? fmtTime(n.at) : fmtDate(n.at), style: AppText.caption(color: AppColors.textTertiary)),
              if (n.unread) ...[
                const SizedBox(width: 6),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle)),
              ],
            ]),
            const SizedBox(height: 3),
            Text(n.body, style: AppText.caption()),
          ]),
        ),
      ]),
    );
  }
}
