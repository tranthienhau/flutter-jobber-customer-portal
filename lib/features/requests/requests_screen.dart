import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(requestFilterProvider);
    final jobs = ref.watch(jobsProvider);
    return Scaffold(
      floatingActionButton: PrimaryButton('New request',
          key: const Key('requests-new'), icon: LucideIcons.plus, expand: false, onPressed: () => context.push('/new-request')),
      body: SafeArea(
        bottom: false,
        child: jobs.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.ink)),
          error: (e, _) => Center(child: Text('$e')),
          data: (all) {
            final list = filter == null ? all : all.where((j) => j.status == filter).toList();
            final open = all.where((j) => j.status != JobStatus.completed).length;
            final live = all.where((j) => j.status == JobStatus.inProgress).length;
            return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 110), children: [
              Row(children: [
                Expanded(child: Text('Requests', style: AppText.display(size: 26))),
                CircleIconButton(LucideIcons.search, tooltip: 'Search', onTap: () {}),
              ]),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(children: [
                  for (final (label, s) in const [
                    ('All', null),
                    ('Requested', JobStatus.requested),
                    ('Scheduled', JobStatus.scheduled),
                    ('In progress', JobStatus.inProgress),
                    ('Completed', JobStatus.completed),
                  ]) ...[
                    SelectChip(label,
                        selected: filter == s, onTap: () => ref.read(requestFilterProvider.notifier).set(s)),
                    const SizedBox(width: 8),
                  ],
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: AppColors.lemonTint, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('$open open - $live in progress', style: AppText.label(weight: FontWeight.w700)),
                  const Spacer(),
                  Text('${all.length} total', style: AppText.caption(color: AppColors.textSecondary)),
                ]),
              ),
              const SizedBox(height: 14),
              for (final j in list) ...[_JobCard(j), const SizedBox(height: 12)],
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(child: Text('Nothing here yet', style: AppText.body(color: AppColors.textSecondary))),
                ),
            ]);
          },
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard(this.j);
  final Job j;

  @override
  Widget build(BuildContext context) => AppCard(
        key: Key('job-${j.id}'),
        onTap: () => context.push(j.status == JobStatus.completed ? '/requests/work/${j.id}' : '/requests/job/${j.id}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(j.title, style: AppText.title())),
            const SizedBox(width: 8),
            StatusChip(j.status),
          ]),
          const SizedBox(height: 4),
          Text('${j.propertyName} - ${fmtDate(j.date)}', style: AppText.caption()),
          if (j.photos.isNotEmpty || j.urgent || j.crewLead != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              if (j.photos.isNotEmpty) ...[
                Img(j.photos.first, radius: 10, width: 52, height: 52),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (j.crewLead != null)
                    Row(children: [
                      const Icon(LucideIcons.users, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(j.crewLead!, style: AppText.caption(color: AppColors.ink)),
                    ]),
                  if (j.photos.isNotEmpty)
                    Text('${j.photos.length} photo${j.photos.length == 1 ? '' : 's'}', style: AppText.caption()),
                ]),
              ),
              if (j.urgent) const Pill('Urgent', bg: AppColors.dangerTint, fg: AppColors.danger, icon: LucideIcons.siren),
            ]),
          ],
        ]),
      );
}
