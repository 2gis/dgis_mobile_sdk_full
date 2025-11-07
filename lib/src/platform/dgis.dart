import '../../src/generated/dart_bindings.dart';

/// Точка входа в 2GIS SDK.
/// На старте работы необходимо вызвать initialize.
class DGis {
  static Context? _sdkContext;

  /// Необходимо вызвать этот метод до начала работы с SDK.
  /// SDK [Context] инициализируется один раз, и при последующих вызовах возвращается созданный объект.
  /// При Hot Restart [Context] не пересоздается. Для того, чтобы поменять какие-то его параметры, нужен полный restart приложения.
  /// [httpOptions] задает настройки сетевого клиента.
  /// [logOptions] определяет параметры логирования.
  /// [dataCollectConsent] согласие на сбор данных и обработку данных.
  /// Источник ключа [keySource] используется для работы с сервисами SDK.
  /// Для переопределения конфигурации SDK нужно передать [vendorConfig].
  /// Если передать null, то будет использоваться 'dgissdk.key' файл из assets.
  /// Для установки источника геопозиции необходимо передать реализацию [locationProvider].
  /// Если передать null, то будет использоваться источник по умолчанию.
  /// Для установки источника направления необходимо передать реализацию [headingProvider].
  /// Если передать null, то будет использоваться источник по умолчанию.
  /// Результатом инициализации SDK является sdkContext,
  /// необходимый для работы сервисов SDK.
  static Context initialize({
    HttpOptions httpOptions = const HttpOptions(),
    LogOptions logOptions = const LogOptions(),
    PersonalDataCollectionConsent dataCollectConsent =
        PersonalDataCollectionConsent.granted,
    KeySource? keySource,
    VendorConfig? vendorConfig,
    LocationProvider? locationProvider,
    HeadingProvider? headingProvider,
  }) {
    _sdkContext ??= makeSystemContext(
      keySource ?? KeySource.fromAsset(const KeyFromAsset('dgissdk.key')),
      httpOptions,
      logOptions,
      dataCollectConsent,
      vendorConfig ?? VendorConfig.none(),
      locationProvider,
      headingProvider,
    );
    return _sdkContext!;
  }

  Context get context {
    if (_sdkContext == null) {
      throw Exception('You need initialize DGis SDK first');
    }

    return _sdkContext!;
  }
}
