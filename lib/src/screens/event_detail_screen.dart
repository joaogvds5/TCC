import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nearu/src/controllers/event_controller.dart';
import 'package:nearu/src/controllers/event_detail_controller.dart';
import 'package:nearu/src/models/event.dart';
import 'package:nearu/src/screens/event_chat_screen.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final ScrollController? scrollController;

  const EventDetailScreen({
    super.key,
    required this.event,
    this.scrollController,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventDetailController _controller = EventDetailController();
  bool _showAllParticipants = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onUpdate);
    final eventId = widget.event.id ?? '';
    _controller.loadEventDetails(eventId);
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

  bool get _isCreator {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return userId != null && userId == widget.event.userId;
  }

  Future<void> _handleJoinEvent() async {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    if (!isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    final success = await _controller.joinEvent(widget.event.id ?? '');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Você entrou no evento!' : 'Erro ao entrar no evento',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLeaveEvent() async {
    if (_isCreator) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você é o criador do evento e não pode sair. Você pode excluir o evento.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair do evento'),
        content: const Text('Tem certeza que deseja sair deste evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await _controller.leaveEvent(widget.event.id ?? '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Você saiu do evento' : 'Erro ao sair do evento',
            ),
            backgroundColor: success ? Colors.orange : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir evento'),
        content: const Text(
          'Tem certeza que deseja excluir este evento?\n\nEsta ação é irreversível e todos os participantes serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await EventController().deleteEvent(
        widget.event.id ?? '',
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evento excluído com sucesso'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context); // Fecha o modal
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir evento'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Login necessário'),
        content: const Text('Faça login para participar do evento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Fazer login'),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventChatScreen(eventId: widget.event.id ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final isParticipating = _controller.isParticipating;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle (indicador de arrastar)
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Detalhes do Evento',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (isParticipating)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: _openChat,
                    tooltip: 'Chat do evento',
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                if (event.photoUrl != null && event.photoUrl!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(event.photoUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.event,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.createdAt != null
                                ? DateFormat(
                                    'dd/MM/yyyy HH:mm',
                                  ).format(event.createdAt!)
                                : 'Data não definida',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      if (event.description.isNotEmpty) ...[
                        Text(
                          event.description,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Participantes
                      Row(
                        children: [
                          const Text(
                            'Participantes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_controller.participantCount}',
                              style: TextStyle(
                                color: Colors.purple.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      if (_controller.participants.isNotEmpty)
                        _buildParticipantsList()
                      else
                        Text(
                          'Nenhum participante ainda.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),

                      const SizedBox(height: 30),

                      if (!_isCreator) ...[
                        if (!isParticipating)
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _controller.isLoading
                                  ? null
                                  : _handleJoinEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A0A23),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.person_add),
                              label: const Text(
                                'Participar do Evento',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _openChat,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.chat),
                                  label: const Text('Chat'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _handleLeaveEvent,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Sair'),
                                ),
                              ),
                            ],
                          ),
                      ],
                      if (_isCreator) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _openChat,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.chat),
                            label: const Text('Chat do Evento'),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Excluir evento
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _handleDeleteEvent,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Excluir Evento'),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    final participants = _showAllParticipants
        ? _controller.participants
        : _controller.participants.take(5).toList();

    return Column(
      children: [
        ...participants.map(
          (participant) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: participant.userPhotoUrl != null
                  ? NetworkImage(participant.userPhotoUrl!)
                  : null,
              child: participant.userPhotoUrl == null
                  ? Text(
                      _getInitials(participant.userName),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : null,
            ),
            title: Text(
              participant.userName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Entrou em ${DateFormat('dd/MM/yyyy').format(participant.joinedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ),
        if (_controller.participants.length > 5 && !_showAllParticipants)
          TextButton(
            onPressed: () => setState(() => _showAllParticipants = true),
            child: Text(
              'Ver todos (${_controller.participants.length})',
              style: const TextStyle(color: Colors.purple),
            ),
          ),
        if (_showAllParticipants)
          TextButton(
            onPressed: () => setState(() => _showAllParticipants = false),
            child: const Text('Mostrar menos'),
          ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
