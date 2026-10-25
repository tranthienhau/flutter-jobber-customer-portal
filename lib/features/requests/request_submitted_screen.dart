import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class RequestSubmittedScreen extends ConsumerWidget {
  const RequestSubmittedScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final j = ref.watch(jobProvider(id));
    if (j == null) return const Scaffold();
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 40, 20, 24), children: [
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(color: AppColors.successTint, shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.check, size: 36, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Request received', textAlign: TextAlign.center, style: AppText.display(size: 26)),
          const SizedBox(height: 10),
          Text(
            'Request ${j.number} for ${j.propertyName}. Our team will confirm a time within 2 business hours.',
            textAlign: TextAlign.center,
            style: AppText.body(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Row(children: [
              for (final (i, s) in JobStatus.values.indexed) ...[
                Expanded(
                  child: Column(children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: i == 0 ? AppColors.lemon : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: i == 0 ? AppColors.ink : AppColors.controlBorder, width: i == 0 ? 2 : 1.5),
                      ),
                      child: i == 0 ? const Icon(LucideIcons.check, size: 12) : null,
                    ),
                    const SizedBox(height: 6),
                    Text(s.label,
                        textAlign: TextAlign.center,
                        style: AppText.overline(color: i == 0 ? AppColors.ink : AppColors.textTertiary).copyWith(letterSpacing: 0)),
                  ]),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(children: [
              _Row(LucideIcons.wrench, 'Service', j.title),
              _Row(LucideIcons.image, 'Photos', '${j.photos.length} attached'),
              _Row(LucideIcons.building2, 'Site', j.propertyName),
              _Row(LucideIcons.user, 'Submitted by', 'Dana Whitfield'),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(LucideIcons.messageSquare, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Logged in Jobber as a new request and added to the GoHighLevel pipeline for your account manager.',
                    style: AppText.caption()),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          PrimaryButton('Track request',
              key: const Key('track-request'),
              trailing: LucideIcons.arrowRight,
              onPressed: () => context.pushReplacement('/requests/job/${j.id}')),
          const SizedBox(height: 10),
          SecondaryButton('Back to home', onPressed: () => context.go('/home')),
        ]),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: AppText.caption()),
          const SizedBox(width: 12),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.right, style: AppText.label(weight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ]),
      );
}
