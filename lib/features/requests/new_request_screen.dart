import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class NewRequestScreen extends ConsumerStatefulWidget {
  const NewRequestScreen({super.key});
  @override
  ConsumerState<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends ConsumerState<NewRequestScreen> {
  bool sending = false;
  late final TextEditingController desc = TextEditingController(text: ref.read(draftProvider).description);

  static const types = ['Janitorial', 'Floor care', 'Windows', 'Restroom', 'Spill / urgent', 'Other'];
  static const timings = ['ASAP', 'This week', 'Next visit'];

  @override
  void dispose() {
    desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => sending = true);
    final d = ref.read(draftProvider).copyWith(description: desc.text);
    final job = await ref.read(jobsProvider.notifier).submit(d.toDraft());
    ref.read(draftProvider.notifier).reset();
    if (mounted) context.pushReplacement('/request-submitted/${job.id}');
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(draftProvider);
    final n = ref.read(draftProvider.notifier);
    final props = ref.watch(propertiesProvider).value ?? const <Property>[];
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(children: [
              Expanded(child: Text('New request', style: AppText.display(size: 24))),
              IconButton(
                  key: const Key('close'),
                  tooltip: 'Close',
                  onPressed: () => context.pop(),
                  icon: const Icon(LucideIcons.x, color: AppColors.ink)),
            ]),
          ),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), children: [
              _Label('Site'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: AppColors.controlBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: d.propertyId,
                    isExpanded: true,
                    icon: const Icon(LucideIcons.chevronDown, size: 18),
                    style: AppText.body(),
                    items: [
                      for (final p in props) DropdownMenuItem(value: p.id, child: Text(p.name)),
                      if (props.isEmpty)
                        const DropdownMenuItem(value: 'prop-northgate', child: Text('Northgate Office Park')),
                    ],
                    onChanged: (v) => n.update((s) => s.copyWith(propertyId: v)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _Label('Service type', trailing: 'Required'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final t in types)
                  SelectChip(t, selected: d.serviceType == t, onTap: () => n.update((s) => s.copyWith(serviceType: t))),
              ]),
              const SizedBox(height: 20),
              _Label('Description'),
              TextField(
                key: const Key('desc'),
                controller: desc,
                maxLines: 3,
                style: AppText.body(),
                decoration: const InputDecoration(hintText: 'What needs attention, where, and how big?'),
              ),
              const SizedBox(height: 20),
              _Label('Photos', trailing: '${d.photos.length} attached'),
              SizedBox(
                height: 96,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (final p in d.photos) ...[
                    Stack(children: [
                      Img(p, radius: 14, width: 96, height: 96),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: InkWell(
                          onTap: () => n.removePhoto(p),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
                            child: const Icon(LucideIcons.x, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(width: 10),
                  ],
                  if (d.photos.length < 4)
                    InkWell(
                      key: const Key('add-photo'),
                      onTap: n.addPhoto,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.lemonTint,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.lemon, width: 1.5),
                        ),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(LucideIcons.camera, color: AppColors.ink),
                          const SizedBox(height: 6),
                          Text('Add photo', style: AppText.caption(color: AppColors.ink, weight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 20),
              _Label('Preferred timing'),
              Row(children: [
                for (final t in timings) ...[
                  SelectChip(t, selected: d.timing == t, onTap: () => n.update((s) => s.copyWith(timing: t))),
                  const SizedBox(width: 8),
                ],
              ]),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Text me when scheduled', style: AppText.label(weight: FontWeight.w700)),
                      Text('SMS updates to (512) 555-0192', style: AppText.caption()),
                    ]),
                  ),
                  Switch(value: d.textMe, onChanged: (v) => n.update((s) => s.copyWith(textMe: v))),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Column(children: [
              PrimaryButton(sending ? 'Sending to Midas...' : 'Submit request',
                  key: const Key('submit-request'),
                  trailing: sending ? null : LucideIcons.arrowRight,
                  onPressed: sending ? null : _submit),
              const SizedBox(height: 8),
              Text('Goes straight to the Midas scheduling team', style: AppText.caption(color: AppColors.textTertiary)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.trailing});
  final String text;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(text, style: AppText.label(weight: FontWeight.w700)),
          const Spacer(),
          if (trailing != null) Text(trailing!, style: AppText.caption(color: AppColors.textTertiary)),
        ]),
      );
}
