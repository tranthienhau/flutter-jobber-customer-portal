import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Bottom tab bar from DESIGN.md: Home, Requests, Invoices, Support. Active tab = ink icon +
/// label with a lemon pill behind the icon; inactive = tertiary text.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const tabs = [
    ('Home', LucideIcons.house),
    ('Requests', LucideIcons.clipboardList),
    ('Invoices', LucideIcons.receipt),
    ('Support', LucideIcons.messageCircle),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: shell.currentIndex == i,
                      label: tabs[i].$1,
                      child: InkWell(
                        key: Key('tab-${tabs[i].$1}'),
                        onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                        child: _TabItem(label: tabs[i].$1, icon: tabs[i].$2, active: shell.currentIndex == i),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.label, required this.icon, required this.active});
  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52,
          height: 30,
          decoration: BoxDecoration(
            color: active ? AppColors.lemon : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(icon, size: 21, color: active ? AppColors.ink : AppColors.textTertiary),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppText.caption(
                color: active ? AppColors.ink : AppColors.textTertiary,
                weight: active ? FontWeight.w700 : FontWeight.w500)),
      ]);
}
