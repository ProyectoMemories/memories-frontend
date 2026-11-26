// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterRequest extends RegisterRequest {
  @override
  final String username;
  @override
  final String email;
  @override
  final String password;
  @override
  final String firstName;
  @override
  final String paternalSurname;
  @override
  final String? maternalSurname;
  @override
  final Date birthDate;
  @override
  final bool acceptsPrivacyPolicy;

  factory _$RegisterRequest([void Function(RegisterRequestBuilder)? updates]) =>
      (RegisterRequestBuilder()..update(updates))._build();

  _$RegisterRequest._(
      {required this.username,
      required this.email,
      required this.password,
      required this.firstName,
      required this.paternalSurname,
      this.maternalSurname,
      required this.birthDate,
      required this.acceptsPrivacyPolicy})
      : super._();
  @override
  RegisterRequest rebuild(void Function(RegisterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterRequestBuilder toBuilder() => RegisterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterRequest &&
        username == other.username &&
        email == other.email &&
        password == other.password &&
        firstName == other.firstName &&
        paternalSurname == other.paternalSurname &&
        maternalSurname == other.maternalSurname &&
        birthDate == other.birthDate &&
        acceptsPrivacyPolicy == other.acceptsPrivacyPolicy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, paternalSurname.hashCode);
    _$hash = $jc(_$hash, maternalSurname.hashCode);
    _$hash = $jc(_$hash, birthDate.hashCode);
    _$hash = $jc(_$hash, acceptsPrivacyPolicy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterRequest')
          ..add('username', username)
          ..add('email', email)
          ..add('password', password)
          ..add('firstName', firstName)
          ..add('paternalSurname', paternalSurname)
          ..add('maternalSurname', maternalSurname)
          ..add('birthDate', birthDate)
          ..add('acceptsPrivacyPolicy', acceptsPrivacyPolicy))
        .toString();
  }
}

class RegisterRequestBuilder
    implements Builder<RegisterRequest, RegisterRequestBuilder> {
  _$RegisterRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _firstName;
  String? get firstName => _$this._firstName;
  set firstName(String? firstName) => _$this._firstName = firstName;

  String? _paternalSurname;
  String? get paternalSurname => _$this._paternalSurname;
  set paternalSurname(String? paternalSurname) =>
      _$this._paternalSurname = paternalSurname;

  String? _maternalSurname;
  String? get maternalSurname => _$this._maternalSurname;
  set maternalSurname(String? maternalSurname) =>
      _$this._maternalSurname = maternalSurname;

  Date? _birthDate;
  Date? get birthDate => _$this._birthDate;
  set birthDate(Date? birthDate) => _$this._birthDate = birthDate;

  bool? _acceptsPrivacyPolicy;
  bool? get acceptsPrivacyPolicy => _$this._acceptsPrivacyPolicy;
  set acceptsPrivacyPolicy(bool? acceptsPrivacyPolicy) =>
      _$this._acceptsPrivacyPolicy = acceptsPrivacyPolicy;

  RegisterRequestBuilder() {
    RegisterRequest._defaults(this);
  }

  RegisterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _email = $v.email;
      _password = $v.password;
      _firstName = $v.firstName;
      _paternalSurname = $v.paternalSurname;
      _maternalSurname = $v.maternalSurname;
      _birthDate = $v.birthDate;
      _acceptsPrivacyPolicy = $v.acceptsPrivacyPolicy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterRequest other) {
    _$v = other as _$RegisterRequest;
  }

  @override
  void update(void Function(RegisterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterRequest build() => _build();

  _$RegisterRequest _build() {
    final _$result = _$v ??
        _$RegisterRequest._(
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'RegisterRequest', 'username'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'RegisterRequest', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'RegisterRequest', 'password'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'RegisterRequest', 'firstName'),
          paternalSurname: BuiltValueNullFieldError.checkNotNull(
              paternalSurname, r'RegisterRequest', 'paternalSurname'),
          maternalSurname: maternalSurname,
          birthDate: BuiltValueNullFieldError.checkNotNull(
              birthDate, r'RegisterRequest', 'birthDate'),
          acceptsPrivacyPolicy: BuiltValueNullFieldError.checkNotNull(
              acceptsPrivacyPolicy, r'RegisterRequest', 'acceptsPrivacyPolicy'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
