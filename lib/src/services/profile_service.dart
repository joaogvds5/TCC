import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/profile.dart';
import 'package:nearu/src/services/interest_service.dart';

class ProfileService {
  final SupabaseClient _client;
  final InterestService _interestService;

  ProfileService({SupabaseClient? client, InterestService? interestService})
    : _client = client ?? Supabase.instance.client,
      _interestService = interestService ?? InterestService();

  Future<Profile?> getMyProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('ProfileService: Usuário não autenticado');
        return null;
      }

      debugPrint('Buscando perfil para user_id: $userId');

      var userResponse = await _client
          .from('users')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (userResponse == null) {
        debugPrint('Perfil não encontrado. Tentando criar...');
        final created = await _tryCreateProfile(userId);
        if (created != null) {
          userResponse = created;
        } else {
          return null;
        }
      }

      debugPrint('Perfil carregado: ${userResponse['name']}');

      final interests = await _interestService.getUserInterests(userId);

      final profileData = Map<String, dynamic>.from(userResponse);
      if (interests.isNotEmpty) {
        profileData['user_interest'] = interests
            .map((i) => {'interest': i.toMap()})
            .toList();
      }

      return Profile.fromMap(profileData);
    } catch (e) {
      debugPrint('Erro ao buscar perfil: $e');
      return null;
    }
  }

  Future<Profile?> getProfileByUuid(String uuid) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('user_id', uuid)
          .maybeSingle();

      if (response == null) return null;

      final interests = await _interestService.getUserInterests(uuid);

      final profileData = Map<String, dynamic>.from(response);
      if (interests.isNotEmpty) {
        profileData['user_interest'] = interests
            .map((i) => {'interest': i.toMap()})
            .toList();
      }

      return Profile.fromMap(profileData);
    } catch (e) {
      debugPrint('Erro ao buscar perfil: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _tryCreateProfile(String userId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final email = user.email ?? '';
      final name =
          user.userMetadata?['name'] as String? ?? email.split('@').first;

      await _client.from('users').upsert({
        'user_id': userId,
        'email': email,
        'name': name,
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      final response = await _client
          .from('users')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Erro ao criar perfil: $e');
      return null;
    }
  }

  Future<void> updateProfileFields({
    required String userUuid,
    String? name,
    String? biography,
    DateTime? birthDate,
    String? telephone,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (biography != null) data['biography'] = biography;
    if (birthDate != null) {
      data['birth_date'] = DateFormat('yyyy-MM-dd').format(birthDate);
    }
    if (telephone != null) data['telephone'] = telephone;
    if (photoUrl != null) data['photo_user'] = photoUrl;

    if (data.isEmpty) {
      debugPrint('Nenhum campo para atualizar');
      return;
    }

    debugPrint('Atualizando perfil de: $userUuid');
    debugPrint('Campos: $data');

    try {
      await _client.from('users').update(data).eq('user_id', userUuid);
      debugPrint('Perfil atualizado com sucesso');
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains('chk_users_min_age_18')) {
        throw Exception('É necessário ter pelo menos 18 anos.');
      }

      debugPrint('PostgrestException: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  Future<void> createProfile(Profile profile) async {
    try {
      await _client.from('users').insert(profile.toMap());
      debugPrint('Perfil criado com sucesso');
    } catch (e) {
      debugPrint('Erro ao criar perfil: $e');
      rethrow;
    }
  }

  Future<String?> uploadProfilePhotoBytes(
    Uint8List bytes, {
    required String userUuid,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      final fileName =
          'profile_${userUuid}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage
          .from('avatars')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final photoUrl = _client.storage.from('avatars').getPublicUrl(fileName);

      await _client
          .from('users')
          .update({'photo_user': photoUrl})
          .eq('user_id', userUuid);

      return photoUrl;
    } on StorageException catch (e) {
      debugPrint('StorageException: ${e.message}');
      throw Exception('Erro de storage: ${e.message}');
    } catch (e) {
      debugPrint('Erro ao fazer upload da foto: $e');
      return null;
    }
  }

  Future<String?> uploadEventPhoto(
    Uint8List bytes, {
    required String eventId,
  }) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuário não autenticado');
      }

      final fileName =
          'event_${eventId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage
          .from('events')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final photoUrl = _client.storage.from('events').getPublicUrl(fileName);

      await _client
          .from('events')
          .update({'photo_event': photoUrl})
          .eq('id', eventId);

      return photoUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da foto do evento: $e');
      return null;
    }
  }

  Future<void> removeProfilePhoto(String userUuid) async {
    try {
      await _client
          .from('users')
          .update({'photo_user': null})
          .eq('user_id', userUuid);
    } catch (e) {
      debugPrint('Erro ao remover foto: $e');
      rethrow;
    }
  }

  Future<List<int>> getUserInterestIds() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final ids = await _interestService.getUserInterestIds(userId);
    return ids.toList();
  }

  Future<void> updateInterests(List<int> interestIds) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuário não autenticado');
    await _interestService.setUserInterests(
      userUuid: userId,
      interestIds: interestIds.toSet(),
    );
  }
}
