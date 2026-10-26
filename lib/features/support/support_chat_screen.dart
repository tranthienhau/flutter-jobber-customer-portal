import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  const SupportChatScreen({super.key});
  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final input = TextEditingController();
  final scroll = ScrollController();

  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final t = text ?? input.text;
    input.clear();
    final f = ref.read(chatProvider.notifier).send(t);
    _toEnd();
    await f;
    _toEnd();
  }

  void _toEnd() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scroll.hasClients) {
          scroll.animateTo(scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });

  @override
  Widget build(BuildContext context) {
    final msgs = ref.watch(chatProvider).value ?? const <ChatMessage>[];
    ref.listen(chatProvider, (_, _) => _toEnd());
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(children: [
              const Avatar('avatar-jordan.jpg', size: 48, online: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Jordan Ellis', style: AppText.title(size: 17)),
                  Text('Your account manager', style: AppText.caption()),
                ]),
              ),
              CircleIconButton(LucideIcons.phone, tooltip: 'Call Midas', onTap: () {}),
            ]),
          ),
          SizedBox(
            height: 44,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: const [
              _ContactPill(LucideIcons.phone, 'Call (512) 555-0148'),
              SizedBox(width: 8),
              _ContactPill(LucideIcons.mail, 'support@midasfs.com'),
            ]),
          ),
          const Divider(height: 20, color: AppColors.hairline),
          Expanded(
            child: ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), children: [
              Center(child: Pill('Today, ${fmtTime(msgs.isEmpty ? DateTime(2026, 11, 3, 7, 6) : msgs.first.at)}', bg: AppColors.surfaceAlt, fg: AppColors.textSecondary)),
              const SizedBox(height: 12),
              for (final m in msgs) _Bubble(m),
            ]),
          ),
          SizedBox(
            height: 52,
            child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
              for (final q in const ['Request a quote', 'Billing question', 'Report an issue']) ...[
                ActionChip(
                  key: Key('quick-$q'),
                  label: Text(q, style: AppText.caption(color: AppColors.ink, weight: FontWeight.w600)),
                  backgroundColor: AppColors.lemonTint,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  onPressed: () => _send(q == 'Billing question' ? 'I have a question about INV-10482.' : q),
                ),
                const SizedBox(width: 8),
              ],
            ]),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + MediaQuery.paddingOf(context).bottom * 0),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.hairline))),
            child: Row(children: [
              IconButton(tooltip: 'Attach photo', onPressed: () {}, icon: const Icon(LucideIcons.camera, color: AppColors.textSecondary)),
              Expanded(
                child: TextField(
                  key: const Key('chat-input'),
                  controller: input,
                  style: AppText.body(),
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Message Midas support',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppColors.hairline)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999), borderSide: const BorderSide(color: AppColors.lemon, width: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleIconButton(LucideIcons.arrowUp, key: const Key('chat-send'), tooltip: 'Send', fill: AppColors.lemon, onTap: _send),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ContactPill extends StatelessWidget {
  const _ContactPill(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.hairline)),
        child: Row(children: [
          Icon(icon, size: 15),
          const SizedBox(width: 6),
          Text(text, style: AppText.caption(color: AppColors.ink, weight: FontWeight.w600)),
        ]),
      );
}

class _Bubble extends ConsumerWidget {
  const _Bubble(this.m);
  final ChatMessage m;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = m.sender == Sender.customer;
    final job = m.jobId == null ? null : ref.watch(jobProvider(m.jobId!));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (!mine) ...[const Avatar('avatar-jordan.jpg', size: 28), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 270),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: mine ? AppColors.lemon : AppColors.surface,
                border: mine ? null : Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(mine ? 18 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 18),
                ),
              ),
              child: Text(m.text, style: AppText.body(size: 15)),
            ),
          ),
        ]),
        if (job != null)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 8),
            child: SizedBox(
              width: 270,
              child: AppCard(
                padding: const EdgeInsets.all(12),
                onTap: () => context.push('/requests/job/${job.id}'),
                child: Row(children: [
                  if (job.photos.isNotEmpty) Img(job.photos.first, radius: 10, width: 48, height: 48),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${job.title} ${job.number}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.label(weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      StatusChip(job.status),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(top: 4, left: mine ? 0 : 36),
          child: Text(fmtTime(m.at), style: AppText.overline(color: AppColors.textTertiary).copyWith(letterSpacing: 0, fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }
}
