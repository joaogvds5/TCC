import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/people.dart';

class PeopleService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<People>> getPeople() async {
    final response = await _client
        .from('people')
        .select('*, location(*), interest(*)');

    return (response as List).map((e) => People.fromMap(e)).toList();
  }

  Future<void> createPeople(People people) async {
    await _client.from('people').insert(people.toMap());
  }

  Future<void> deletePeople(int id) async {
    await _client.from('people').delete().eq('id', id);
  }
}
