import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../home/presentation/pages/home_page.dart';
import '../screening/presentation/pages/screening_flow_page.dart';
import '../screening/presentation/providers/screening_flow_provider.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../settings/presentation/pages/settings_page.dart';

/// Provider for current navigation index
class NavigationIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index, {bool resetScreening = false}) {
    // If navigating to screening tab (index 1), optionally reset the screening
    if (index == 1 && resetScreening) {
      ref.read(screeningFlowProvider.notifier).reset();
    }
    state = index;
  }
}

final navigationIndexProvider =
    NotifierProvider<NavigationIndexNotifier, int>(NavigationIndexNotifier.new);

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const ScreeningFlowPage(),
      const DashboardPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: AppStrings.home,
                  isSelected: currentIndex == 0,
                  onTap: () =>
                      ref.read(navigationIndexProvider.notifier).setIndex(0),
                ),
                _NavItem(
                  icon: Icons.quiz_outlined,
                  activeIcon: Icons.quiz,
                  label: AppStrings.screening,
                  isSelected: currentIndex == 1,
                  onTap: () =>
                      ref.read(navigationIndexProvider.notifier).setIndex(1),
                ),
                _NavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: AppStrings.dashboard,
                  isSelected: currentIndex == 2,
                  onTap: () =>
                      ref.read(navigationIndexProvider.notifier).setIndex(2),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: AppStrings.settings,
                  isSelected: currentIndex == 3,
                  onTap: () =>
                      ref.read(navigationIndexProvider.notifier).setIndex(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
