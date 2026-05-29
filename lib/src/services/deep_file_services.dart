import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._();
  static DeepLinkService get instance => _instance;
  DeepLinkService._();

  final AppLinks _appLinks = AppLinks();

  /// Inicia o listener de deep links
  Future<void> init() async {
    // Captura link que abriu o app (se foi fechado)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Erro ao pegar link inicial: $e');
    }

    // Escuta links enquanto o app está aberto
    _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (e) {
        debugPrint('Erro no stream de links: $e');
      },
    );
  }

  /// Processa o deep link
  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('🔗 Deep link recebido: $uri');

    try {
      // O Supabase SDK já lida com o link magicamente se configurado
      // Mas podemos processar manualmente se necessário
      if (uri.toString().contains('access_token') ||
          uri.toString().contains('type=signup') ||
          uri.toString().contains('type=recovery')) {
        debugPrint('✅ Link de autenticação processado');
      }
    } catch (e) {
      debugPrint('❌ Erro ao processar deep link: $e');
    }
  }
}
