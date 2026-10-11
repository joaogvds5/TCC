// lib/src/widgets/chats_widget.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nearu/src/screens/event_chat_screen.dart';

class ChatsWidget extends StatefulWidget {
  const ChatsWidget({super.key});

  @override
  State<ChatsWidget> createState() => _ChatsWidgetState();
}

class _ChatsWidgetState extends State<ChatsWidget> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  /// Carrega a lista de conversas do usuário (eventos que ele participa)
  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _error = 'Faça login para ver seus chats';
          _isLoading = false;
        });
        return;
      }

      // Busca eventos que o usuário participa
      final response = await _client
          .from('event_participants')
          .select('''
            event_id,
            joined_at,
            events(
              id,
              title,
              description,
              photo_event,
              interest_category,
              latitude_event,
              longitude_event,
              user_creator,
              created_at
            )
          ''')
          .eq('user_id', userId)
          .order('joined_at', ascending: false);

      final data = response as List;
      debugPrint('Conversas carregadas: ${data.length}');

      setState(() {
        _conversations = data.map((e) => e as Map<String, dynamic>).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar conversas: $e');
      setState(() {
        _error = 'Erro ao carregar chats';
        _isLoading = false;
      });
    }
  }

  /// Busca a última mensagem de um evento
  Future<String?> _getLastMessage(String eventId) async {
    try {
      final response = await _client
          .from('event_messages')
          .select('message, created_at')
          .eq('event_id', eventId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return response['message'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Busca a contagem de participantes de um evento
  Future<int> _getParticipantCount(String eventId) async {
    try {
      final response = await _client
          .from('event_participants')
          .select('id')
          .eq('event_id', eventId);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConversations,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum chat ainda',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Participe de eventos para começar a conversar!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          final eventData = conversation['events'] as Map<String, dynamic>?;
          final eventId = conversation['event_id'].toString();
          final joinedAt = conversation['joined_at'] != null
              ? DateTime.tryParse(conversation['joined_at'].toString())
              : null;

          if (eventData == null) {
            return const SizedBox.shrink();
          }

          return _buildConversationTile(
            eventId: eventId,
            eventTitle: eventData['title'] ?? 'Evento',
            eventPhoto: eventData['photo_event'],
            joinedAt: joinedAt,
          );
        },
      ),
    );
  }

  Widget _buildConversationTile({
    required String eventId,
    required String eventTitle,
    String? eventPhoto,
    DateTime? joinedAt,
  }) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getConversationDetails(eventId),
      builder: (context, snapshot) {
        final lastMessage = snapshot.data?['last_message'] as String?;
        final participantCount =
            snapshot.data?['participant_count'] as int? ?? 0;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: eventPhoto != null && eventPhoto.isNotEmpty
                ? NetworkImage(eventPhoto)
                : null,
            child: eventPhoto == null || eventPhoto.isEmpty
                ? const Icon(Icons.event, color: Colors.white)
                : null,
          ),
          title: Text(
            eventTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            lastMessage ?? 'Inicie a conversa!',
            style: TextStyle(
              color: lastMessage != null
                  ? Colors.grey.shade600
                  : Colors.purple.shade400,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (joinedAt != null)
                Text(
                  DateFormat('dd/MM').format(joinedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$participantCount',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.purple.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventChatScreen(eventId: eventId),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getConversationDetails(String eventId) async {
    final results = await Future.wait([
      _getLastMessage(eventId),
      _getParticipantCount(eventId),
    ]);

    return {'last_message': results[0], 'participant_count': results[1]};
  }
}
