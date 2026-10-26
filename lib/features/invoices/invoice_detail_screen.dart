import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = ref.watch(invoiceProvider(id));
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: inv.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.ink)),
          error: (e, _) => Center(child: Text('$e')),
          data: (i) => ListView(padding: const EdgeInsets.fromLTRB(8, 4, 8, 32), children: [
            PushedHeader(center: Text(i.number, style: AppText.headline(size: 18))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  i.isPaid
                      ? const Pill('Paid', bg: AppColors.successTint, fg: AppColors.success, icon: LucideIcons.circleCheck)
                      : const Pill('Open', bg: AppColors.warningTint, fg: AppColors.warning, icon: LucideIcons.clock),
                  const Spacer(),
                  Text('Synced ${fmtDate(i.syncedAt)}', style: AppText.caption()),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.accentFill),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Synced from QuickBooks Online - ${fmtDate(i.syncedAt)}', style: AppText.caption(color: AppColors.ink))),
                    const Icon(LucideIcons.circleCheck, size: 16, color: AppColors.success),
                  ]),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bill to', style: AppText.caption()),
                    Text(i.customer, style: AppText.title()),
                    Text(i.propertyName, style: AppText.caption()),
                    const SizedBox(height: 14),
                    Row(children: [
                      _Meta('Issued', fmtDateLong(i.issued)),
                      _Meta('Due date', fmtDateLong(i.due)),
                      _Meta('Terms', i.terms),
                    ]),
                  ]),
                ),
                const SizedBox(height: 14),
                AppCard(
                  child: Column(children: [
                    Row(children: [
                      Text('Line items', style: AppText.headline(size: 18)),
                      const Spacer(),
                      Text('${i.lines.length} items', style: AppText.caption()),
                    ]),
                    const SizedBox(height: 10),
                    for (final l in i.lines) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(l.description, style: AppText.label(weight: FontWeight.w600)),
                              Text(l.detail, style: AppText.caption()),
                            ]),
                          ),
                          Text(money.format(l.amount), style: AppText.numerals(size: 15, weight: FontWeight.w600)),
                        ]),
                      ),
                      const Divider(height: 1, color: AppColors.hairline),
                    ],
                    const SizedBox(height: 12),
                    _Sum('Subtotal', money.format(i.total)),
                    _Sum('Tax (0%)', money.format(0)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text('TOTAL DUE', style: AppText.overline(color: AppColors.ink)),
                      const Spacer(),
                      Text(money.format(i.balance == 0 ? i.total : i.balance), style: AppText.display(size: 28)),
                    ]),
                  ]),
                ),
                const SizedBox(height: 18),
                SecondaryButton('Download PDF', icon: LucideIcons.download, onPressed: () {}),
                const SizedBox(height: 10),
                PrimaryButton('Question about this invoice',
                    icon: LucideIcons.messageCircleQuestion, onPressed: () => context.go('/support')),
                const SizedBox(height: 14),
                Text('Invoices are view-only in the portal. Payments are handled by your accounts payable team as usual.',
                    textAlign: TextAlign.center, style: AppText.caption(color: AppColors.textTertiary)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppText.caption()),
          Text(value, style: AppText.label(weight: FontWeight.w700)),
        ]),
      );
}

class _Sum extends StatelessWidget {
  const _Sum(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(label, style: AppText.caption()),
          const Spacer(),
          Text(value, style: AppText.numerals(size: 14, weight: FontWeight.w500)),
        ]),
      );
}
