import 'package:flutter/material.dart';
import 'package:ithinkwash/core/utils/platform_util.dart';

class AppNavigationShell extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;
  final Widget body;

  const AppNavigationShell({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtil.isDesktop || PlatformUtil.isWeb) {
      return Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            labelType: NavigationRailLabelType.all,
            destinations: items
                .map((item) => NavigationRailDestination(
                      icon: item.icon,
                      selectedIcon: item.activeIcon,
                      label: Text(item.label ?? ''),
                    ))
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
