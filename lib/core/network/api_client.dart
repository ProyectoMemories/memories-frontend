import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';

/// Cliente HTTP de la aplicacion.
///
/// Hace dos cosas que si no estarian repetidas en cada llamada:
///  1. anade el token de acceso a cada peticion;
///  2. ante un 401, renueva la sesion una sola vez y reintenta. Si la renovacion
///     falla, avisa para que la app vuelva al inicio de sesion.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required Future<void> Function() onSessionExpired,
    Dio? dio,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired,
        dio = dio ?? Dio() {
    this.dio.options = BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: AppConfig.requestTimeout,
          receiveTimeout: AppConfig.requestTimeout,
          sendTimeout: AppConfig.uploadTimeout,
          contentType: Headers.jsonContentType,
          // El cliente decide como tratar cada codigo; Dio no lanza por 4xx.
          validateStatus: (int? status) => status != null && status < 400,
        );
    _refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
    this.dio.interceptors.add(_buildInterceptor());
  }

  static const String _marcaDeReintento = 'memories.reintento';

  final TokenStorage _tokenStorage;
  final Future<void> Function() _onSessionExpired;
  final Dio dio;
  late final Dio _refreshDio;

  /// Evita que diez peticiones fallidas a la vez disparen diez renovaciones.
  Future<bool>? _refreshInFlight;

  QueuedInterceptorsWrapper _buildInterceptor() {
    return QueuedInterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        final String? token = await _tokenStorage.readAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        final bool esNoAutorizado = error.response?.statusCode == 401;
        final bool esRutaDeSesion = error.requestOptions.path.startsWith('/auth/');
        // Si esta peticion ya es un reintento, no se renueva otra vez: seria un
        // bucle con el servidor respondiendo 401 sin parar.
        final bool yaSeReintento = error.requestOptions.extra[_marcaDeReintento] == true;

        if (!esNoAutorizado || esRutaDeSesion || yaSeReintento) {
          handler.next(error);
          return;
        }

        final bool renovada = await _renovarSesion();
        if (!renovada) {
          await _onSessionExpired();
          handler.next(error);
          return;
        }

        try {
          handler.resolve(await _reintentar(error.requestOptions));
        } on DioException catch (nuevoError) {
          handler.next(nuevoError);
        }
      },
    );
  }

  Future<bool> _renovarSesion() {
    return _refreshInFlight ??= _hacerRenovacion().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _hacerRenovacion() async {
    final String? refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      return false;
    }
    try {
      final Response<dynamic> respuesta = await _refreshDio.post<dynamic>(
        ApiEndpoints.refresh,
        data: <String, dynamic>{'refresh_token': refreshToken},
      );
      final Map<String, dynamic> datos = respuesta.data as Map<String, dynamic>;
      await _tokenStorage.save(
        accessToken: datos['access_token'] as String,
        refreshToken: datos['refresh_token'] as String,
      );
      return true;
    } on DioException {
      await _tokenStorage.clear();
      return false;
    }
  }

  Future<Response<dynamic>> _reintentar(RequestOptions peticion) async {
    final String? token = await _tokenStorage.readAccessToken();
    final Options opciones = Options(
      method: peticion.method,
      headers: <String, dynamic>{
        ...peticion.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      extra: <String, dynamic>{...peticion.extra, _marcaDeReintento: true},
    );
    // Un FormData ya enviado no se puede reenviar: hay que clonarlo. Sin esto,
    // reintentar una subida de fotos fallaria siempre.
    final dynamic datos =
        peticion.data is FormData ? (peticion.data as FormData).clone() : peticion.data;

    return dio.request<dynamic>(
      peticion.path,
      data: datos,
      queryParameters: peticion.queryParameters,
      options: opciones,
    );
  }
}
