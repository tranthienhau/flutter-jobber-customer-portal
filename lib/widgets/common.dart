import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';

final money = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
String fmtDate(DateTime d) => DateFormat('MMM d').format(d);
String fmtDateLong(DateTime d) => DateFormat('MMM d, y').format(d);
String fmtTime(DateTime d) => DateFormat('h:mm a').format(d);
String fmtDayTime(DateTime d) => DateFormat('EEE, MMM d').format(d);

class Img extends StatelessWidget {
  const Img(this.name, {super.key, this.radius = 0, this.width, this.height, this.fit = BoxFit.cover});
  final String name;
  final double radius;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset('assets/images/$name', width: width, height: height, fit: fit),
      );
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 44, this.online = false});
  final String name;
  final double size;
  final bool online;

  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: AppShadows.card),
          child: ClipOval(child: Image.asset('assets/images/$name', width: size, height: size, fit: BoxFit.cover)),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                  color: const Color(0xFF16A34A), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
      ]);
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.hairline),
          boxShadow: AppShadows.card,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onPressed, this.icon, this.expand = true, this.trailing});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailing;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final btn = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.lemon,
        foregroundColor: AppColors.ink,
        disabledBackgroundColor: AppColors.lemon.withValues(alpha: 0.4),
        disabledForegroundColor: AppColors.ink.withValues(alpha: 0.5),
        overlayColor: AppColors.lemonPressed,
        minimumSize: const Size(48, 54),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: const StadiumBorder(),
        elevation: 0,
        textStyle: AppText.label(size: 15, weight: FontWeight.w700),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(label),
        if (trailing != null) ...[const SizedBox(width: 8), Icon(trailing, size: 18)],
      ]),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, this.onPressed, this.icon, this.expand = true});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.controlBorder),
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: const StadiumBorder(),
        textStyle: AppText.label(size: 15, weight: FontWeight.w600),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
        Text(label),
      ]),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key, this.text});
  final JobStatus status;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (status) {
      JobStatus.requested => (AppColors.infoTint, AppColors.info, LucideIcons.send),
      JobStatus.scheduled => (AppColors.lemonTint, AppColors.scheduledText, LucideIcons.calendarClock),
      JobStatus.inProgress => (AppColors.warningTint, AppColors.warning, LucideIcons.loaderCircle),
      JobStatus.completed => (AppColors.successTint, AppColors.success, LucideIcons.circleCheck),
    };
    return Pill(text ?? status.label, bg: bg, fg: fg, icon: icon);
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.bg, required this.fg, this.icon});
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 5)],
          Text(text, style: AppText.caption(color: fg, weight: FontWeight.w600)),
        ]),
      );
}

class SelectChip extends StatelessWidget {
  const SelectChip(this.label, {super.key, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          key: Key('chip-$label'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.lemon : AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? AppColors.lemon : AppColors.hairline),
            ),
            child: Text(label, style: AppText.label(weight: selected ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(child: Text(title, style: AppText.headline(size: 18))),
          if (action != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(foregroundColor: AppColors.ink, minimumSize: const Size(44, 44)),
              child: Row(children: [
                Text(action!, style: AppText.label(weight: FontWeight.w500)),
                const Icon(LucideIcons.chevronRight, size: 16),
              ]),
            ),
        ]),
      );
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton(this.icon, {super.key, required this.onTap, this.tooltip, this.fill = AppColors.surface, this.badge = false});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color fill;
  final bool badge;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Stack(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle, boxShadow: AppShadows.card),
              child: Icon(icon, size: 20, color: AppColors.ink),
            ),
            if (badge)
              Positioned(
                right: 10,
                top: 9,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                      color: AppColors.lemon, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                ),
              ),
          ]),
        ),
      );
}

/// Top bar for pushed screens: back chevron + optional centered caption + trailing.
class PushedHeader extends StatelessWidget {
  const PushedHeader({super.key, this.center, this.trailing});
  final Widget? center;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52,
        child: Row(children: [
          IconButton(
            key: const Key('back'),
            tooltip: 'Back',
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
            icon: const Icon(LucideIcons.chevronLeft, color: AppColors.ink),
          ),
          Expanded(child: Center(child: center ?? const SizedBox())),
          SizedBox(width: 48, child: trailing),
        ]),
      );
}

class SyncNote extends StatelessWidget {
  const SyncNote(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(LucideIcons.refreshCw, size: 14, color: AppColors.accentFill),
        const SizedBox(width: 6),
        Text(text, style: AppText.caption(color: AppColors.textTertiary)),
      ]);
}
