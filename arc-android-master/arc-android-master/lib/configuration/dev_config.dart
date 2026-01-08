// lib/config/dev_config.dart
import 'app_config.dart';

class DevConfig implements AppConfig {
  @override
  String get baseUrl => "https://dev-api.arcofficepro.com/api/v1/";

  @override
  String get firebaseChatDB => "chat_dev";

  @override
  String get agoraAppID => "3b8f023cca224381b3ffd31718fb89b3";
}
