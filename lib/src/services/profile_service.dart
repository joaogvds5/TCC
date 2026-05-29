import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/models/profile.dart';
import 'package:nearu/src/models/interest.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Busca o perfil do usuário logado
  Future<Profile?> getMyProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ ProfileService: Usuário não autenticado');
        return null;
      }

      debugPrint('🔍 Buscando perfil para user_id: $userId');

      // 1. Busca o perfil básico
      var userResponse = await _client
          .from('users')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      // 2. Se não encontrou, cria automaticamente
      if (userResponse == null) {
        debugPrint('⚠️ Perfil não encontrado. Criando automaticamente...');

        final user = _client.auth.currentUser;
        if (user != null) {
          final email = user.email ?? '';
          final name =
              user.userMetadata?['name'] as String? ?? email.split('@').first;

          await _client.from('users').insert({
            'user_id': userId,
            'email': email,
            'name': name,
            'created_at': DateTime.now().toIso8601String(),
          });

          // Busca novamente
          userResponse = await _client
              .from('users')
              .select('*')
              .eq('user_id', userId)
              .maybeSingle();
        }
      }

      if (userResponse == null) {
        debugPrint('❌ Não foi possível criar/carregar o perfil');
        return null;
      }

      debugPrint('✅ Perfil carregado: ${userResponse['name']}');

      // 3. Busca os interesses
      List<Interest>? interests;
      try {
        final interestsResponse = await _client
            .from('user_interest')
            .select('interest_id, interest(*)')
            .eq('user_id', userId);

        if (interestsResponse != null && interestsResponse is List) {
          interests = interestsResponse
              .map((item) {
                final interestData = item['interest'];
                if (interestData is Map<String, dynamic>) {
                  return Interest.fromMap(interestData);
                }
                return null;
              })
              .whereType<Interest>()
              .toList();
        }
      } catch (e) {
        debugPrint('⚠️ Interesses não carregados: $e');
      }

      // 4. Monta o perfil completo
      final profileData = Map<String, dynamic>.from(userResponse);
      if (interests != null && interests.isNotEmpty) {
        profileData['user_interest'] = interests
            .map((i) => {'interest': i.toMap()})
            .toList();
      }

      return Profile.fromMap(profileData);
    } catch (e) {
      debugPrint('❌ Erro ao buscar perfil: $e');
      return null;
    }
  }

  // ... resto dos métodos iguais ...

  /// Atualiza perfil
  Future<void> updateProfile(Profile profile) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client.from('users').update(profile.toMap()).eq('user_id', userId);

      debugPrint('✅ Perfil atualizado');
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  /// Upload de foto
  Future<String?> uploadProfilePhotoBytes(Uint8List bytes) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

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
          .eq('user_id', userId);

      return photoUrl;
    } catch (e) {
      debugPrint('Erro ao fazer upload da foto: $e');
      return null;
    }
  }

  /// Remove foto
  Future<void> removeProfilePhoto() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client
          .from('users')
          .update({'photo_user': null})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Erro ao remover foto: $e');
      rethrow;
    }
  }

  /// Deleta conta
  Future<void> deleteAccount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client.from('users').delete().eq('user_id', userId);
    } catch (e) {
      debugPrint('Erro ao deletar conta: $e');
      rethrow;
    }
  }

  /// Busca IDs dos interesses
  Future<List<int>> getUserInterestIds() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('user_interest')
          .select('interest_id')
          .eq('user_id', userId);

      return (response as List).map((e) => e['interest_id'] as int).toList();
    } catch (e) {
      return [];
    }
  }

  /// Atualiza interesses
  Future<void> updateInterests(List<int> interestIds) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client.from('user_interest').delete().eq('user_id', userId);

      if (interestIds.isNotEmpty) {
        final inserts = interestIds
            .map((id) => {'user_id': userId, 'interest_id': id})
            .toList();

        await _client.from('user_interest').insert(inserts);
      }
    } catch (e) {
      debugPrint('Erro ao atualizar interesses: $e');
      rethrow;
    }
  }
}
