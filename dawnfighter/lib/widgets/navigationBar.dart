import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixelarticons/pixelarticons.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/navigationBar.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildNavItem(
                icon: SvgPicture.asset(
                  'assets/icons/group.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                index: 0,
              ),
            ),
            _buildNavItem(
              icon: SvgPicture.asset(
                'assets/icons/clock.svg',
                width: 50,
                height: 50,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              index: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _buildNavItem(
                icon: SvgPicture.asset(
                  'assets/icons/user.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                index: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required Widget icon, required int index}) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          isSelected ? Colors.white : Colors.white70,
          BlendMode.srcIn,
        ),
        child: SizedBox(width: 48, height: 48, child: Center(child: icon)),
      ),
    );
  }
}
