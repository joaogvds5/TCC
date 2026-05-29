import 'package:flutter/material.dart';
import 'package:nearu/src/controllers/profile_controller.dart';
import 'package:nearu/src/screens/profile_screen.dart';

class ProfileIconWidget extends StatefulWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  const ProfileIconWidget({
    super.key,
    this.imageUrl,
    this.size = 36,
    this.onTap,
  });

  @override
  State<ProfileIconWidget> createState() => _ProfileIconWidgetState();
}

class _ProfileIconWidgetState extends State<ProfileIconWidget> {
  final ProfileController _controller = ProfileController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    _loadProfile();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _loadProfile() async {
    if (!_initialized) {
      await _controller.loadProfile();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _controller.profile;
    final photoUrl = profile?.photoUrl ?? widget.imageUrl;

    return GestureDetector(
      onTap:
          widget.onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
      child: CircleAvatar(
        radius: widget.size / 2,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
            ? NetworkImage(photoUrl)
            : null,
        child: photoUrl == null || photoUrl.isEmpty
            ? Text(
                profile?.initials ?? '?',
                style: TextStyle(
                  fontSize: widget.size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
