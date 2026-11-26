// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoginRequest extends LoginRequest {
  @override
  final String identifier;
  @override
  final String password;
  @override
  final ClientPlatform platform;
  @override
  final String? deviceName;

  factory _$LoginRequest([void Function(LoginRequestBuilder)? updates]) =>
      (LoginRequestBuilder()..update(updates))._build();

  _$LoginRequest._(
      {required this.identifier,
      required this.password,
      required this.platform,
      this.deviceName})
      : super._();
  @override
  LoginRequest rebuild(void Function(LoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginRequestBuilder toBuilder() => LoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginRequest &&
        identifier == other.identifier &&
        password == other.password &&
        platform == other.platform &&
        deviceName == other.deviceName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, identifier.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LoginRequest')
          ..add('identifier', identifier)
          ..add('password', password)
          ..add('platform', platform)
          ..add('deviceName', deviceName))
        .toString();
  }
}

class LoginRequestBuilder
    implements Builder<LoginRequest, LoginRequestBuilder> {
  _$LoginRequest? _$v;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  ClientPlatform? _platform;
  ClientPlatform? get platform => _$this._platform;
  set platform(ClientPlatform? platform) => _$this._platform = platform;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  LoginRequestBuilder() {
    LoginRequest._defaults(this);
  }

  LoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _identifier = $v.identifier;
      _password = $v.password;
      _platform = $v.platform;
      _deviceName = $v.deviceName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoginRequest other) {
    _$v = other as _$LoginRequest;
  }

  @override
  void update(void Function(LoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginRequest build() => _build();

  _$LoginRequest _build() {
    final _$result = _$v ??
        _$LoginRequest._(
          identifier: BuiltValueNullFieldError.checkNotNull(
              identifier, r'LoginRequest', 'identifier'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'LoginRequest', 'password'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'LoginRequest', 'platform'),
          deviceName: deviceName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
