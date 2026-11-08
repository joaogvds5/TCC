import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/interest.dart';

class InterestService {
  final SupabaseClient _client;

  InterestService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const String othersName = 'Outros';
  static List<Interest> sortWithOthersLast(List<Interest> input) {
    final list = List<Interest>.from(input);

    list.sort((a, b) {
      final aIsOthers = a.name.toLowerCase() == othersName.toLowerCase();
      final bIsOthers = b.name.toLowerCase() == othersName.toLowerCase();

      if (aIsOthers && !bIsOthers) return 1;
      if (!aIsOthers && bIsOthers) return -1;
      if (aIsOthers && bIsOthers) return 0;

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return list;
  }

  Future<List<Interest>> getAllInterests() async {
    try {
      final response = await _client
          .from('interest')
          .select()
          .order('title', ascending: true);

      final list = (response as List)
          .map((e) => Interest.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      return sortWithOthersLast(list);
    } catch (e) {
      debugPrint('InterestService - erro ao listar interesses: $e');
      return [];
    }
  }

  Future<Set<int>> getUserInterestIds(String userUuid) async {
    try {
      final response = await _client
          .from('user_interest')
          .select('interest_id')
          .eq('user_id', userUuid);

      return (response as List).map((e) => e['interest_id'] as int).toSet();
    } catch (e) {
      debugPrint('InterestService - erro ao buscar interesses do usuário: $e');
      return {};
    }
  }

  Future<List<Interest>> getUserInterests(String userUuid) async {
    try {
      final response = await _client
          .from('user_interest')
          .select('interest_id, interest(id, title, icon)')
          .eq('user_id', userUuid);

      final list = (response as List)
          .map((item) {
            final data = item['interest'];
            if (data is Map<String, dynamic>) {
              return Interest.fromMap(data);
            }
            return null;
          })
          .whereType<Interest>()
          .toList();

      return sortWithOthersLast(list);
    } catch (e) {
      debugPrint('InterestService - erro ao buscar interesses completos: $e');
      return [];
    }
  }

  Future<bool> setUserInterests({
    required String userUuid,
    required Set<int> interestIds,
  }) async {
    try {
      await _client.from('user_interest').delete().eq('user_id', userUuid);

      if (interestIds.isEmpty) return true;

      final inserts = interestIds
          .map((id) => {'user_id': userUuid, 'interest_id': id})
          .toList();

      await _client.from('user_interest').insert(inserts);
      return true;
    } catch (e) {
      debugPrint('InterestService - erro ao salvar interesses: $e');
      return false;
    }
  }
}
