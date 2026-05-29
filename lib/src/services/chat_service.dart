import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/chat.dart';

class ChatService {
  final _client = Supabase.instance.client;

  Future<List<Chat>> getUserChats() async {
    final user = _client.auth.currentUser;

    if (user == null) return [];

    final response = await _client
        .from('chat')
        .select('*, event(title)')
        .or('user_id_1.eq.${user.id},user_id_2.eq.${user.id}')
        .order('updated_at', ascending: false);

    return (response as List).map((e) => Chat.fromMap(e)).toList();
  }
}
