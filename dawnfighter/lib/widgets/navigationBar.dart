import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

class CustomNavigationBar extends StatelessWidget {
  final void Function(int)? onTap;
  final int currentIndex;

  const CustomNavigationBar({
    Key? key,
    this.onTap,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(
            Pixel.users,
            size: 24,
            color: Colors.white,
          ),
          label: 'Group',
        ),
        NavigationDestination(
          icon: Icon(
            Pixel.clock,
            size: 24,
            color: Colors.white,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(
            Pixel.user,
            size: 24,
            color: Colors.white,
          ),
          label: 'User',
        ),
      ],
    );
  }
}