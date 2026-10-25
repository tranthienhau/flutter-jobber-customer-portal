import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class RequestChangeScreen extends ConsumerStatefulWidget {
  const RequestChangeScreen({super.key, required this.propertyId, required this.serviceId});
  final String propertyId;
  final String serviceId;
  @override
  ConsumerState<RequestChangeScreen> createState() => _RequestChangeScreenState();
}

class _RequestChangeScreenState extends ConsumerState<RequestChangeScreen> {
  String kind = 'Change frequency';
  final days = {'Mon', 'Wed', 'Fri'};
  bool sent = false;

  static const kinds = [
    ('Change frequency', 'Adjust recurring days of service', LucideIcons.calendarRange),
    ('Change time window', 'Shift start time or shift window', LucideIcons.clock),
    ('Add or remove areas', 'Floors, suites, kitchens or restrooms', LucideIcons.layoutGrid),
    ('Pause service', 'Temporary hold during renovations or closures', LucideIcons.pause),
    ('Cancel service', 'End this recurring service', LucideIcons.circleX),
  ];

  @override
  Widget build(BuildContext context) {
    final prop = ref.watch(propertyProvider(widget.propertyId)).value;
    final svc = prop?.services.firstWhere((s) => s.id == widget.serviceId);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          PushedHeader(center: Text('Request a change', style: AppText.headline(size: 18))),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
              if (svc != null)
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('CURRENT SERVICE', style: AppText.overline()),
                      const Spacer(),
                      const Pill('Active agreement', bg: AppColors.successTint, fg: AppColors.success),
                    ]),
                    const SizedBox(height: 8),
                    Text(svc.title, style: AppText.headline(size: 18)),
                    Text(prop!.name, style: AppText.caption()),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(LucideIcons.clock, size: 14),
                      const SizedBox(width: 6),
                      Text(svc.schedule, style: AppText.label(weight: FontWeight.w500)),
                    ]),
                  ]),
                ),
              const SizedBox(height: 20),
              Text('What would you like to change?', style: AppText.label(weight: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final (k, sub, icon) in kinds) ...[
                _KindCard(
                  title: k,
                  sub: sub,
                  icon: icon,
                  selected: kind == k,
                  onTap: () => setState(() => kind = k),
                  child: kind == k && k == 'Change frequency' ? _days() : null,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              Text('Effective date', style: AppText.label(weight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: 'Dec 1, 2026',
                readOnly: true,
                decoration: const InputDecoration(suffixIcon: Icon(LucideIcons.calendar, size: 18)),
              ),
              const SizedBox(height: 16),
              Text('Notes', style: AppText.label(weight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextFormField(initialValue: 'Office moving to a hybrid schedule.', maxLines: 2),
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(LucideIcons.info, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Changes may affect your contract price. Your account manager will confirm.',
                      style: AppText.caption()),
                ),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: PrimaryButton(sent ? 'Change request sent' : 'Send change request',
                key: const Key('send-change'),
                icon: sent ? LucideIcons.check : null,
                onPressed: sent
                    ? null
                    : () async {
                        await ref.read(repositoryProvider).submitChange(ChangeRequest(
                              serviceId: widget.serviceId,
                              kind: kind,
                              days: days.toList(),
                              effective: DateTime(2026, 12, 1),
                              notes: 'Office moving to a hybrid schedule.',
                            ));
                        setState(() => sent = true);
                        await Future<void>.delayed(const Duration(milliseconds: 900));
                        if (context.mounted) context.pop();
                      }),
          ),
        ]),
      ),
    );
  }

  Widget _days() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.hairline),
        const SizedBox(height: 12),
        Row(children: [
          Text('Select service days', style: AppText.caption(color: AppColors.ink, weight: FontWeight.w600)),
          const Spacer(),
          Text('${days.length} days selected', style: AppText.caption()),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          for (final d in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  key: Key('day-$d'),
                  onTap: () => setState(() => days.contains(d) ? days.remove(d) : days.add(d)),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: days.contains(d) ? AppColors.lemon : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: days.contains(d) ? AppColors.lemon : AppColors.hairline),
                    ),
                    child: Text(d, style: AppText.caption(color: AppColors.ink, weight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(LucideIcons.arrowRightLeft, size: 14),
          const SizedBox(width: 6),
          Text('From Mon-Fri to ${[for (final d in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) if (days.contains(d)) d].join(', ')}',
              style: AppText.caption(color: AppColors.ink)),
        ]),
      ]);
}

class _KindCard extends StatelessWidget {
  const _KindCard(
      {required this.title, required this.sub, required this.icon, required this.selected, required this.onTap, this.child});
  final String title;
  final String sub;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.lemonTint : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? AppColors.lemon : AppColors.hairline, width: selected ? 2 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(selected ? LucideIcons.circleDot : LucideIcons.circle, size: 20, color: AppColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: AppText.label(weight: FontWeight.w700)),
                  Text(sub, style: AppText.caption()),
                ]),
              ),
              Icon(icon, size: 18, color: AppColors.textSecondary),
            ]),
            ?child,
          ]),
        ),
      );
}
