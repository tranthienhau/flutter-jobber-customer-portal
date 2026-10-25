import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class CompletedWorkScreen extends ConsumerStatefulWidget {
  const CompletedWorkScreen({super.key, required this.id});
  final String id;
  @override
  ConsumerState<CompletedWorkScreen> createState() => _CompletedWorkScreenState();
}

class _CompletedWorkScreenState extends ConsumerState<CompletedWorkScreen> {
  double split = 0.5;

  @override
  Widget build(BuildContext context) {
    final j = ref.watch(jobProvider(widget.id));
    if (j == null) return const Scaffold();
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(8, 4, 8, 32), children: [
          PushedHeader(center: StatusChip(j.status), trailing: IconButton(
            tooltip: 'Share report',
            onPressed: () {},
            icon: const Icon(LucideIcons.share2, size: 20),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(j.title, style: AppText.display(size: 22)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(LucideIcons.mapPin, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('${j.propertyName} - Completed ${fmtDate(j.date)}', style: AppText.caption()),
              ]),
              const SizedBox(height: 18),
              if (j.beforePhoto != null && j.afterPhoto != null)
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('BEFORE AND AFTER', style: AppText.overline(color: AppColors.ink)),
                      const Spacer(),
                      const Icon(LucideIcons.moveHorizontal, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Drag slider', style: AppText.caption()),
                    ]),
                    const SizedBox(height: 12),
                    _BeforeAfter(before: j.beforePhoto!, after: j.afterPhoto!, split: split, onChanged: (v) => setState(() => split = v)),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(LucideIcons.badgeCheck, size: 16, color: AppColors.accentFill),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Stain treated and hot-water extracted - elevator landing', style: AppText.caption(color: AppColors.ink))),
                    ]),
                  ]),
                ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('Photos', style: AppText.headline(size: 18)),
                    const SizedBox(width: 8),
                    Pill('${j.photos.length}', bg: AppColors.surfaceAlt, fg: AppColors.ink),
                  ]),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      for (final (i, p) in j.photos.take(6).indexed)
                        GestureDetector(
                          key: Key('photo-$i'),
                          onTap: () => _open(context, j.photos, i),
                          child: Stack(fit: StackFit.expand, children: [
                            Img(p, radius: 12),
                            if (i == 5 && j.photos.length > 6)
                              Container(
                                decoration: BoxDecoration(
                                    color: AppColors.ink.withValues(alpha: 0.72), borderRadius: BorderRadius.circular(12)),
                                alignment: Alignment.center,
                                child: Text('+${j.photos.length - 5}\nmore',
                                    textAlign: TextAlign.center, style: AppText.label(color: Colors.white)),
                              ),
                          ]),
                        ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              if (j.crewNotes != null)
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(LucideIcons.notebookPen, size: 18),
                      const SizedBox(width: 8),
                      Text('Crew notes', style: AppText.headline(size: 18)),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.lemonTint, borderRadius: BorderRadius.circular(14)),
                      child: Text('"${j.crewNotes}"', style: AppText.body(size: 15)),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      if (j.crewAvatar != null) Avatar(j.crewAvatar!, size: 40),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(j.crewLead ?? '', style: AppText.label(weight: FontWeight.w700)),
                          Text('Crew lead - signed off ${fmtDate(j.date)}, ${fmtTime(j.date)}', style: AppText.caption()),
                        ]),
                      ),
                      const Icon(LucideIcons.circleCheck, color: AppColors.success),
                    ]),
                  ]),
                ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(children: [
                  Row(children: [
                    Text('Rate this visit', style: AppText.label(weight: FontWeight.w700)),
                    const Spacer(),
                    for (var s = 1; s <= 5; s++)
                      InkWell(
                        key: Key('star-$s'),
                        onTap: () => ref.read(jobsProvider.notifier).rate(j.id, s),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(LucideIcons.star,
                              size: 24, color: s <= j.rating ? AppColors.lemonPressed : AppColors.controlBorder),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  SecondaryButton('Report an issue', icon: LucideIcons.flag, onPressed: () {}),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void _open(BuildContext context, List<String> photos, int start) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.ink.withValues(alpha: 0.92),
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(children: [
          PageView(
            controller: PageController(initialPage: start),
            children: [for (final p in photos) InteractiveViewer(child: Center(child: Img(p, fit: BoxFit.contain)))],
          ),
          Positioned(
            right: 16,
            top: MediaQuery.paddingOf(context).top + 8,
            child: IconButton(
              key: const Key('close-viewer'),
              tooltip: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(LucideIcons.x, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}

class _BeforeAfter extends StatelessWidget {
  const _BeforeAfter({required this.before, required this.after, required this.split, required this.onChanged});
  final String before;
  final String after;
  final double split;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        return GestureDetector(
          key: const Key('before-after'),
          onHorizontalDragUpdate: (d) => onChanged((split + d.delta.dx / w).clamp(0.05, 0.95)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 230,
              width: w,
              child: Stack(children: [
                Positioned.fill(child: Img(after)),
                Positioned.fill(
                  child: ClipRect(clipper: _LeftClip(split), child: Img(before)),
                ),
                Positioned(
                  left: w * split - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2, color: Colors.white),
                ),
                Positioned(
                  left: w * split - 18,
                  top: 97,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.card),
                    child: const Icon(LucideIcons.gripVertical, size: 18),
                  ),
                ),
                const Positioned(left: 10, top: 10, child: Pill('Before', bg: AppColors.ink, fg: Colors.white)),
                const Positioned(right: 10, top: 10, child: Pill('After', bg: AppColors.lemon, fg: AppColors.ink)),
              ]),
            ),
          ),
        );
      });
}

class _LeftClip extends CustomClipper<Rect> {
  _LeftClip(this.f);
  final double f;
  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * f, size.height);
  @override
  bool shouldReclip(_LeftClip old) => old.f != f;
}
