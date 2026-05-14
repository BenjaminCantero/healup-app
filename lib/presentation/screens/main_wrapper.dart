import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/glass_nav_bar.dart';

class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    Key? key,
    required this.navigationShell,
  }) : super(key: key);

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for floating nav bars over content
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GlassNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _onTap,
              items: [
                GlassNavItem(icon: LucideIcons.layoutGrid, label: 'Inicio'),
                GlassNavItem(icon: LucideIcons.activitySquare, label: 'Lesiones'),
                GlassNavItem(icon: LucideIcons.lineChart, label: 'Progreso'),
                GlassNavItem(icon: LucideIcons.user, label: 'Perfil'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
