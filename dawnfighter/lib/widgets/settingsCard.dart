import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class SettingsCard extends StatefulWidget {
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
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  bool _editing = false;
  final TextEditingController _nameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startEdit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not signed in')));
      return;
    }
    // Read current name once
    final doc = await FirestoreService.getUserData(uid);
    final data = doc.data();
    final currentName = (data != null && data['name'] is String)
        ? data['name'] as String
        : '';
    _nameController.text = currentName;
    setState(() => _editing = true);
  }

  Future<void> _saveName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not signed in')));
      return;
    }
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a name')));
      return;
    }
    setState(() => _saving = true);
    try {
      await FirestoreService.updateUserData(uid, {'name': newName});
      if (!mounted) return;
      setState(() {
        _saving = false;
        _editing = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name updated')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save name: $e')));
    }
  }

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
        child: _editing ? _buildEditView() : _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.items.map((label) {
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
              ? (widget.isLoading
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
          onTap: isLogout && !widget.isLoading
              ? widget.onLogout
              : () {
                  if (label.toLowerCase() == 'edit account') {
                    _startEdit();
                  }
                },
        );
      }).toList(),
    );
  }

  Widget _buildEditView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back list-item with left chevron
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.chevron_left, color: Colors.white),
          title: const Text(
            'Back',
            style: TextStyle(
              fontFamily: 'PressStart2P',
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          onTap: () => setState(() => _editing = false),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Player name',
            hintStyle: TextStyle(color: Colors.white70.withOpacity(0.9)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        // Save button styled like login button
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C1533),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: _saving ? null : _saveName,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
