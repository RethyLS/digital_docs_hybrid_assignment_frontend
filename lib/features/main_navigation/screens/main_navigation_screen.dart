import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

class MainNavigationScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          destinations: [
            NavigationDestination(
              icon: const HeroIcon(HeroIcons.squares2x2),
              selectedIcon: const HeroIcon(HeroIcons.squares2x2, style: HeroIconStyle.solid),
              label: 'navigation.dashboard'.tr(),
            ),
            NavigationDestination(
              icon: const HeroIcon(HeroIcons.documentText),
              selectedIcon: const HeroIcon(HeroIcons.documentText, style: HeroIconStyle.solid),
              label: 'navigation.documents'.tr(),
            ),
            NavigationDestination(
              icon: const HeroIcon(HeroIcons.users),
              selectedIcon: const HeroIcon(HeroIcons.users, style: HeroIconStyle.solid),
              label: 'navigation.employees'.tr(),
            ),
            NavigationDestination(
              icon: const HeroIcon(HeroIcons.cog6Tooth),
              selectedIcon: const HeroIcon(HeroIcons.cog6Tooth, style: HeroIconStyle.solid),
              label: 'navigation.settings'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
