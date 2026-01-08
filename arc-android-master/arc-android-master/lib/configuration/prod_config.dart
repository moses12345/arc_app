// lib/config/prod_config.dart
import 'app_config.dart';

class ProdConfig implements AppConfig {
  @override
  String get baseUrl => "https://api.arcofficepro.com/api/v1/";

  @override
  String get firebaseChatDB => "chat_prod";

  @override
  String get agoraAppID => "3b8f023cca224381b3ffd31718fb89b3";
}
