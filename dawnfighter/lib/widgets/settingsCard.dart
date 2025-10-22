import 'package:flutter/material.dart';

class SettingsCard extends StatelessWidget {
  final List<String> items;
  final VoidCallback? onLogout;
  final bool isLoading;

  const SettingsCard({
    super.key,
    required this.items,
    this.onLogout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // height will fit contents
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/settingsCard.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items.map((label) {
            final isLogout =
                label.toLowerCase().contains('log out') ||
                label.toLowerCase().contains('logout');
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              trailing: isLogout
                  ? (isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : null)
                  : const Icon(Icons.chevron_right, color: Colors.white),
              onTap: isLogout && !isLoading ? onLogout : () {},
            );
          }).toList(),
        ),
      ),
    );
  }
}
