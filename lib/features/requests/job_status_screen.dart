import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class JobStatusScreen extends ConsumerWidget {
  const JobStatusScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final j = ref.watch(jobProvider(id));
    if (j == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.ink)));
    final step = j.status.index;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(8, 4, 8, 32), children: [
          PushedHeader(
            center: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Midas ID ', style: AppText.caption()),
              Pill(j.number.replaceFirst('#', ''), bg: AppColors.surfaceAlt, fg: AppColors.ink),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(j.title, style: AppText.display(size: 22))),
                const SizedBox(width: 8),
                StatusChip(j.status),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(LucideIcons.mapPin, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                    child: Text([j.propertyName, if (j.location.isNotEmpty) j.location].join(' - '),
                        style: AppText.caption())),
              ]),
              const SizedBox(height: 18),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('SERVICE TIMELINE', style: AppText.overline(color: AppColors.ink)),
                    const Spacer(),
                    Text('Step ${step + 1} of 4', style: AppText.caption()),
                  ]),
                  const SizedBox(height: 14),
                  for (final (i, s) in j.timeline.indexed)
                    _TimelineRow(step: s, state: i < step || j.status == JobStatus.completed ? 0 : (i == step ? 1 : 2), last: i == 3),
                ]),
              ),
              const SizedBox(height: 14),
              if (j.crewLead != null)
                AppCard(
                  child: Row(children: [
                    if (j.crewAvatar != null)
                      Avatar(j.crewAvatar!, size: 52, online: j.status == JobStatus.inProgress)
                    else
                      Container(
                        width: 52,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.lemonTint, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.users, color: AppColors.ink),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(j.crewLead!, style: AppText.title()),
                        Text('Crew lead', style: AppText.caption()),
                      ]),
                    ),
                    CircleIconButton(LucideIcons.phone, tooltip: 'Call crew lead', onTap: () {}),
                    const SizedBox(width: 8),
                    CircleIconButton(LucideIcons.messageSquareText,
                        tooltip: 'Message', fill: AppColors.lemon, onTap: () => context.go('/support')),
                  ]),
                ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SCOPE OF WORK', style: AppText.overline(color: AppColors.ink)),
                  const SizedBox(height: 10),
                  Text(j.scope, style: AppText.body(size: 14, color: AppColors.textSecondary)),
                  if (j.photos.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Row(children: [
                      const Icon(LucideIcons.camera, size: 15, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text('Attachments (${j.photos.length})', style: AppText.caption()),
                    ]),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: j.photos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => Img(j.photos[i], radius: 12, width: 140, height: 104),
                      ),
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 18),
              const SyncNote('Synced with Jobber 2 min ago'),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.state, required this.last});
  final TimelineStep step;

  /// 0 done, 1 current, 2 pending.
  final int state;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final muted = state == 2;
    final dot = switch (state) {
      0 => Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
          child: const Icon(LucideIcons.check, size: 14, color: Colors.white)),
      1 => Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
              color: AppColors.lemon, shape: BoxShape.circle, border: Border.all(color: AppColors.ink, width: 2)),
        ),
      _ => Container(
          width: 22,
          height: 22,
          decoration:
              BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.controlBorder, width: 1.5))),
    };
    final content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(step.title, style: AppText.label(color: muted ? AppColors.textTertiary : AppColors.ink, weight: FontWeight.w700)),
        if (state == 1) ...[
          const SizedBox(width: 6),
          const Pill('LIVE', bg: AppColors.lemon, fg: AppColors.ink),
        ],
        const Spacer(),
        if (step.at != null)
          Text('${fmtDate(step.at!)}, ${fmtTime(step.at!)}', style: AppText.caption(color: AppColors.ink)),
      ]),
      const SizedBox(height: 2),
      Text(step.detail, style: AppText.caption(color: muted ? AppColors.textTertiary : AppColors.textSecondary)),
    ]);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Column(children: [
          dot,
          if (!last)
            Expanded(child: Container(width: 2, color: state == 0 ? AppColors.ink : AppColors.hairline)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: state == 1
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: AppColors.lemonTint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.lemon)),
                    child: content)
                : content,
          ),
        ),
      ]),
    );
  }
}
