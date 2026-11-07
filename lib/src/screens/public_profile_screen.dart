import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearu/src/models/profile.dart';
import 'package:nearu/src/services/interest_service.dart';
import 'package:nearu/src/services/profile_service.dart';
import 'package:nearu/src/widgets/interest_selector_widget.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userUuid;

  const PublicProfileScreen({super.key, required this.userUuid});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final InterestService _interestService = InterestService();

  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await _profileService.getProfileByUuid(widget.userUuid);
    final interests = await _interestService.getUserInterests(widget.userUuid);

    if (!mounted) return;
    setState(() {
      _profile = profile?.copyWith(interests: interests);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_profile == null) {
      return const Scaffold(body: Center(child: Text('Perfil não encontrado')));
    }

    final p = _profile!;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (p.photoUrl != null && p.photoUrl!.isNotEmpty)
                    ? NetworkImage(p.photoUrl!)
                    : null,
                child: (p.photoUrl == null || p.photoUrl!.isEmpty)
                    ? Text(
                        p.initials,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                p.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (p.birthDate != null && p.age != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '${p.age} anos',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (p.biography != null && p.biography!.isNotEmpty) ...[
              Text('Sobre', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(p.biography!),
              const SizedBox(height: 24),
            ],
            if (p.interests != null && p.interests!.isNotEmpty) ...[
              Text(
                'Interesses',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.interests!.map((i) {
                  return Chip(
                    avatar: Icon(
                      InterestSelectorWidget.iconFor(i.icon),
                      size: 18,
                    ),
                    label: Text(i.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            if (p.createdAt != null)
              Text(
                'Membro desde ${DateFormat('MM/yyyy').format(p.createdAt!)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
