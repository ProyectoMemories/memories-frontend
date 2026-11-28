// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProfileResponse extends ProfileResponse {
  @override
  final String id;
  @override
  final String username;
  @override
  final String email;
  @override
  final String firstName;
  @override
  final String paternalSurname;
  @override
  final String? maternalSurname;

  factory _$ProfileResponse([void Function(ProfileResponseBuilder)? updates]) =>
      (ProfileResponseBuilder()..update(updates))._build();

  _$ProfileResponse._(
      {required this.id,
      required this.username,
      required this.email,
      required this.firstName,
      required this.paternalSurname,
      this.maternalSurname})
      : super._();
  @override
  ProfileResponse rebuild(void Function(ProfileResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProfileResponseBuilder toBuilder() => ProfileResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProfileResponse &&
        id == other.id &&
        username == other.username &&
        email == other.email &&
        firstName == other.firstName &&
        paternalSurname == other.paternalSurname &&
        maternalSurname == other.maternalSurname;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, firstName.hashCode);
    _$hash = $jc(_$hash, paternalSurname.hashCode);
    _$hash = $jc(_$hash, maternalSurname.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProfileResponse')
          ..add('id', id)
          ..add('username', username)
          ..add('email', email)
          ..add('firstName', firstName)
          ..add('paternalSurname', paternalSurname)
          ..add('maternalSurname', maternalSurname))
        .toString();
  }
}

class ProfileResponseBuilder
    implements Builder<ProfileResponse, ProfileResponseBuilder> {
  _$ProfileResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

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

  ProfileResponseBuilder() {
    ProfileResponse._defaults(this);
  }

  ProfileResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _email = $v.email;
      _firstName = $v.firstName;
      _paternalSurname = $v.paternalSurname;
      _maternalSurname = $v.maternalSurname;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProfileResponse other) {
    _$v = other as _$ProfileResponse;
  }

  @override
  void update(void Function(ProfileResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProfileResponse build() => _build();

  _$ProfileResponse _build() {
    final _$result = _$v ??
        _$ProfileResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ProfileResponse', 'id'),
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'ProfileResponse', 'username'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ProfileResponse', 'email'),
          firstName: BuiltValueNullFieldError.checkNotNull(
              firstName, r'ProfileResponse', 'firstName'),
          paternalSurname: BuiltValueNullFieldError.checkNotNull(
              paternalSurname, r'ProfileResponse', 'paternalSurname'),
          maternalSurname: maternalSurname,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
