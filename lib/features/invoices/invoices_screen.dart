import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);
    final filter = ref.watch(invoiceFilterProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: invoices.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.ink)),
          error: (e, _) => Center(child: Text('$e')),
          data: (all) {
            final open = all.where((i) => !i.isPaid).toList();
            final balance = open.fold(0.0, (s, i) => s + i.balance);
            final list = switch (filter) {
              'Open' => open,
              'Paid' => all.where((i) => i.isPaid).toList(),
              _ => all,
            };
            return ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), children: [
              Row(children: [
                Expanded(child: Text('Invoices', style: AppText.display(size: 26))),
                CircleIconButton(LucideIcons.download, tooltip: 'Download statement', onTap: () {}),
              ]),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(AppRadius.card)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Balance due', style: AppText.label(color: const Color(0xFFE9E4CF), weight: FontWeight.w500)),
                    const Spacer(),
                    const Pill('Synced from QuickBooks', bg: AppColors.lemon, fg: AppColors.ink, icon: LucideIcons.refreshCw),
                  ]),
                  const SizedBox(height: 10),
                  FittedBox(child: Text(money.format(balance), style: AppText.display(size: 36, color: Colors.white))),
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x33FFFFFF), height: 1),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('${open.length} open invoices', style: AppText.label(color: Colors.white)),
                    const Spacer(),
                    Text('Net 30 terms', style: AppText.caption(color: const Color(0xFFE9E4CF))),
                  ]),
                ]),
              ),
              const SizedBox(height: 18),
              Row(children: [
                for (final f in const ['All', 'Open', 'Paid']) ...[
                  SelectChip(f, selected: filter == f, onTap: () => ref.read(invoiceFilterProvider.notifier).set(f)),
                  const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 14),
              for (final i in list) ...[_InvoiceRow(i), const SizedBox(height: 12)],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppColors.lemonTint,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lemon)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(LucideIcons.info, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Invoices are view-only and come straight from QuickBooks. Contact billing with questions.',
                        style: AppText.caption(color: AppColors.ink)),
                  ),
                ]),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow(this.i);
  final Invoice i;

  @override
  Widget build(BuildContext context) => AppCard(
        key: Key('inv-${i.id}'),
        onTap: () => context.push('/invoices/${i.id}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(i.number, style: AppText.title()),
            const SizedBox(width: 8),
            Text(fmtDate(i.issued), style: AppText.caption()),
            const Spacer(),
            Text(money.format(i.total), style: AppText.numerals(size: 17)),
          ]),
          const SizedBox(height: 2),
          Text(i.propertyName, style: AppText.caption(color: AppColors.ink)),
          const SizedBox(height: 10),
          Row(children: [
            i.isPaid
                ? const Pill('Paid', bg: AppColors.successTint, fg: AppColors.success, icon: LucideIcons.circleCheck)
                : Pill('Open - due ${fmtDate(i.due)}', bg: AppColors.warningTint, fg: AppColors.warning, icon: LucideIcons.clock),
            const Spacer(),
            const Icon(LucideIcons.fileText, size: 18, color: AppColors.textSecondary),
          ]),
        ]),
      );
}
