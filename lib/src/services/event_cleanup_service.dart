// lib/src/services/event_cleanup_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventCleanupService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Chama a função RPC que desativa eventos expirados
  Future<int> cleanupExpiredEvents() async {
    try {
      final result = await _client.rpc('cleanup_expired_events');
      return result ?? 0;
    } catch (e) {
      debugPrint('Erro ao limpar eventos: $e');
      return 0;
    }
  }
}
