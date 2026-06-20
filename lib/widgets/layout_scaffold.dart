import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

class LayoutScaffold extends StatelessWidget {
  final Widget child;

  const LayoutScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;
    final isDark = theme.brightness == Brightness.dark;

    int currentIndex = 0;
    if (location.startsWith('/analyze')) {
      currentIndex = 1;
    } else if (location.startsWith('/chat')) {
      currentIndex = 2;
    } else if (location.startsWith('/learn')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      currentIndex = 4;
    } else {
      currentIndex = 0;
    }

    final items = <_NavItem>[
      _NavItem(icon: LucideIcons.layoutDashboard, route: '/dashboard'),
      _NavItem(icon: LucideIcons.shield, route: '/analyze'),
      _NavItem(icon: LucideIcons.lightbulb, route: '/chat'),
      _NavItem(icon: LucideIcons.bookOpen, route: '/learn'),
      _NavItem(icon: LucideIcons.user, route: '/profile'),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(top: true, bottom: false, child: child),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: navTheme.backgroundColor ?? theme.cardColor,
            borderRadius: BorderRadius.circular(isDark ? 20 : 0),
            border: isDark
                ? Border.all(color: HFTheme.border, width: 1)
                : Border(top: BorderSide(color: theme.dividerColor, width: 1)),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: HFTheme.accent.withAlpha(38),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = index == currentIndex;
              final selectedColor = navTheme.selectedItemColor ?? HFTheme.accent;
              final unselectedColor =
                  navTheme.unselectedItemColor ??
                  theme.iconTheme.color ??
                  HFTheme.muted;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.go(items[index].route),
                child: SizedBox(
                  width: 48,
                  height: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        width: isActive ? 24 : 0,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isActive ? selectedColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        items[index].icon,
                        size: 22,
                        color: isActive ? selectedColor : unselectedColor,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String route;
  const _NavItem({required this.icon, required this.route});
}
