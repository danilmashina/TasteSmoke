import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RemoteConfigService {
  static FirebaseRemoteConfig? _instance;
  
  static FirebaseRemoteConfig get _remoteConfig {
    _instance ??= FirebaseRemoteConfig.instance;
    return _instance!;
  }

  /// Инициализация Remote Config с настройками по умолчанию
  static Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1), // Как в Android версии
        ),
      );

      // Значения по умолчанию (как в Android версии)
      await _remoteConfig.setDefaults({
        'latest_version_code': 3, // Текущая версия из Android
        'update_message': 'Вышла новая версия! Обновитесь, чтобы увидеть новый функционал.',
        'update_url': '', // Будет заполнено в зависимости от платформы
      });

      // Попытка получить актуальные значения
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Игнорируем ошибки инициализации, используем значения по умолчанию
      print('Remote Config initialization error: $e');
    }
  }

  /// Проверяет наличие обновлений
  /// Возвращает Map с данными об обновлении или null, если обновление не требуется
  static Future<Map<String, String>?> checkForUpdates() async {
    try {
      // Инициализируем, если еще не сделано
      await initialize();

      // Получаем информацию о приложении
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 1;

      // Получаем последнюю версию из Remote Config
      final latestVersionCode = _remoteConfig.getInt('latest_version_code');

      // Проверяем, нужно ли обновление
      if (latestVersionCode > currentVersionCode) {
        final message = _remoteConfig.getString('update_message');
        final url = _remoteConfig.getString('update_url');
        
        // Если URL не задан в Remote Config, используем дефолтные
        final updateUrl = url.isNotEmpty ? url : _getDefaultUpdateUrl(packageInfo);

        return {
          'message': message.isNotEmpty ? message : 'Доступна новая версия приложения!',
          'url': updateUrl,
          'current_version': currentVersionCode.toString(),
          'latest_version': latestVersionCode.toString(),
        };
      }

      return null; // Обновление не требуется
    } catch (e) {
      print('Update check error: $e');
      return null;
    }
  }

  /// Получает дефолтный URL для обновления в зависимости от платформы
  static String _getDefaultUpdateUrl(PackageInfo packageInfo) {
    // В Flutter можно определить платформу через dart:io или использовать универсальный подход
    // Для данного случая возвращаем RuStore (как в Android версии)
    return 'https://apps.rustore.ru/app/${packageInfo.packageName}';
  }

  /// Открывает URL для обновления
  static Future<void> openUpdateUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Cannot launch update URL: $url');
      }
    } catch (e) {
      print('Error opening update URL: $e');
    }
  }

  /// Принудительно обновляет конфигурацию
  static Future<bool> forceRefresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      return true;
    } catch (e) {
      print('Force refresh error: $e');
      return false;
    }
  }

  /// Получает значение строкового параметра
  static String getString(String key) {
    return _remoteConfig.getString(key);
  }

  /// Получает значение числового параметра
  static int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  /// Получает значение булевого параметра
  static bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  /// Получает значение double параметра
  static double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  /// Получает все параметры конфигурации
  static Map<String, RemoteConfigValue> getAll() {
    return _remoteConfig.getAll();
  }

  /// Проверяет статус последнего получения конфигурации
  static RemoteConfigFetchStatus get lastFetchStatus {
    return _remoteConfig.lastFetchStatus;
  }

  /// Время последнего успешного получения конфигурации
  static DateTime get lastFetchTime {
    return _remoteConfig.lastFetchTime;
  }

  /// Настройки конфигурации
  static RemoteConfigSettings get settings {
    return _remoteConfig.settings;
  }
}