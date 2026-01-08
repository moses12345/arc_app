// lib/config/config_provider.dart
import 'app_config.dart';
import 'dev_config.dart';
import 'prod_config.dart';

class ConfigProvider {

  //Uncomment for Command line way.
  //For dev build
  //flutter run
  //
  //For Prod Build
  //flutter run --dart-define=ENV=prod
  //
  // static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String _env = 'prod';
  //static const String _env = 'dev';

  static AppConfig get config {
    return _config ??= _createConfig();
  }

  static AppConfig? _config;
  static AppConfig _createConfig() {
    switch (_env) {
      case 'prod':
        return ProdConfig();
      default:
        return DevConfig();
    }
  }

}
