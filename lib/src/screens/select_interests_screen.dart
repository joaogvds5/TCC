import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/controllers/interest_controller.dart';
import 'package:nearu/src/widgets/interest_selector_widget.dart';

class SelectInterestsScreen extends StatefulWidget {
  final String? userUuid;
  final bool returnSelection;

  const SelectInterestsScreen({
    super.key,
    this.userUuid,
    this.returnSelection = false,
  });

  @override
  State<SelectInterestsScreen> createState() => _SelectInterestsScreenState();
}

class _SelectInterestsScreenState extends State<SelectInterestsScreen> {
  late final InterestController _controller;
  String? _uuid;

  @override
  void initState() {
    super.initState();
    _controller = InterestController();
    _controller.addListener(_onUpdate);
    _uuid = widget.userUuid ?? Supabase.instance.client.auth.currentUser?.id;

    if (_uuid != null) {
      _controller.load(userUuid: _uuid!);
    }
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_uuid == null) return;

    final ok = await _controller.save(userUuid: _uuid!);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interesses atualizados!'),
          backgroundColor: Colors.green,
        ),
      );
      if (widget.returnSelection) {
        Navigator.pop(context, _controller.selectedIds);
      } else {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.error ?? 'Erro ao salvar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus interesses'),
        actions: [
          TextButton(
            onPressed: _controller.isLoading ? null : _save,
            child: _controller.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione o que te interessa',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Usamos para mostrar eventos do seu interesse e exibir no seu perfil.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            InterestSelectorWidget(controller: _controller),
            const Spacer(),
            if (_controller.selectedIds.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Selecione ao menos um interesse.',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
