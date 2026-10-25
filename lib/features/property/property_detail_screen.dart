import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  const PropertyDetailScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final prop = ref.watch(propertyProvider(widget.id));
    return Scaffold(
      body: prop.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.ink)),
        error: (e, _) => Center(child: Text('$e')),
        data: (p) {
          final jobs = (ref.watch(jobsProvider).value ?? const <Job>[]).where((j) => j.propertyId == p.id).toList();
          return Stack(children: [
            ListView(padding: EdgeInsets.zero, children: [
              Stack(children: [
                Img(p.image == 'site-northgate.jpg' ? 'northgate-hero.jpg' : p.image, height: 260, width: double.infinity),
                Positioned(
                  left: 16,
                  top: MediaQuery.paddingOf(context).top + 8,
                  child: CircleIconButton(LucideIcons.chevronLeft,
                      key: const Key('back'), tooltip: 'Back', onTap: () => context.pop()),
                ),
                Positioned(
                  left: 16,
                  bottom: 14,
                  child: Pill(p.tag ?? 'Active site', bg: AppColors.surface, fg: AppColors.ink, icon: LucideIcons.mapPin),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.name, style: AppText.display(size: 24)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(LucideIcons.mapPin, size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(p.address, style: AppText.caption())),
                  ]),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: AppColors.lemonTint, shape: BoxShape.circle),
                        child: Text('DW', style: AppText.label(weight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('SITE CONTACT', style: AppText.overline()),
                          Text(p.contact, style: AppText.label(weight: FontWeight.w700)),
                        ]),
                      ),
                      CircleIconButton(LucideIcons.phone, tooltip: 'Call', onTap: () {}),
                      const SizedBox(width: 8),
                      CircleIconButton(LucideIcons.messageSquare, tooltip: 'Message', onTap: () => context.go('/support')),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: _MiniStat(label: 'ACTIVE SERVICES', value: '${p.services.length} programs')),
                    const SizedBox(width: 10),
                    const Expanded(child: _MiniStat(label: 'NEXT VISIT', value: 'Tue 6:00 PM')),
                  ]),
                  const SizedBox(height: 18),
                  _Segmented(index: tab, onChanged: (i) => setState(() => tab = i)),
                  const SizedBox(height: 16),
                  if (tab == 0)
                    for (final s in p.services) ...[_ServiceCard(s, propertyId: p.id), const SizedBox(height: 12)],
                  if (tab == 1)
                    for (final j in jobs) ...[
                      AppCard(
                        onTap: () => context.push('/requests/job/${j.id}'),
                        child: Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(j.title, style: AppText.title()),
                              Text('${j.number} - ${fmtDate(j.date)}', style: AppText.caption()),
                            ]),
                          ),
                          StatusChip(j.status),
                        ]),
                      ),
                      const SizedBox(height: 12),
                    ],
                  if (tab == 2)
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [for (final j in jobs) for (final ph in j.photos) Img(ph, radius: 12)],
                    ),
                ]),
              ),
            ]),
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.paddingOf(context).bottom + 12,
              child: PrimaryButton('New request for this site', icon: LucideIcons.plus, onPressed: () {
                ref.read(draftProvider.notifier).update((d) => d.copyWith(propertyId: p.id));
                context.push('/new-request');
              }),
            ),
          ]);
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.overline()),
          const SizedBox(height: 4),
          Text(value, style: AppText.title(size: 17)),
        ]),
      );
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(999)),
        child: Row(children: [
          for (final (i, l) in const ['Services', 'Visits', 'Photos'].indexed)
            Expanded(
              child: InkWell(
                key: Key('seg-$l'),
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: index == i ? AppColors.lemon : Colors.transparent, borderRadius: BorderRadius.circular(999)),
                  child: Text(l,
                      style: AppText.label(
                          color: index == i ? AppColors.ink : AppColors.textTertiary,
                          weight: index == i ? FontWeight.w700 : FontWeight.w500)),
                ),
              ),
            ),
        ]),
      );
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard(this.s, {required this.propertyId});
  final ServiceLine s;
  final String propertyId;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(s.title, style: AppText.title())),
            s.active
                ? const Pill('Active', bg: AppColors.successTint, fg: AppColors.success, icon: LucideIcons.circleCheck)
                : Pill(s.cadence[0].toUpperCase() + s.cadence.substring(1), bg: AppColors.lemonTint, fg: AppColors.scheduledText),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(LucideIcons.clock, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(s.schedule, style: AppText.caption(color: AppColors.ink)),
          ]),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
            child: Text(s.scope, style: AppText.caption()),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: Key('change-${s.id}'),
              onPressed: () => context.push('/request-change/$propertyId/${s.id}'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accentFill, minimumSize: const Size(44, 44)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Request change', style: AppText.label(color: AppColors.accentFill)),
                const Icon(LucideIcons.chevronRight, size: 16),
              ]),
            ),
          ),
        ]),
      );
}
