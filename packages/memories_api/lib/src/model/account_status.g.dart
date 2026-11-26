// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const AccountStatus _$unverified = const AccountStatus._('unverified');
const AccountStatus _$active = const AccountStatus._('active');
const AccountStatus _$deactivated = const AccountStatus._('deactivated');
const AccountStatus _$pendingDeletion =
    const AccountStatus._('pendingDeletion');
const AccountStatus _$suspended = const AccountStatus._('suspended');

AccountStatus _$valueOf(String name) {
  switch (name) {
    case 'unverified':
      return _$unverified;
    case 'active':
      return _$active;
    case 'deactivated':
      return _$deactivated;
    case 'pendingDeletion':
      return _$pendingDeletion;
    case 'suspended':
      return _$suspended;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<AccountStatus> _$values =
    BuiltSet<AccountStatus>(const <AccountStatus>[
  _$unverified,
  _$active,
  _$deactivated,
  _$pendingDeletion,
  _$suspended,
]);

class _$AccountStatusMeta {
  const _$AccountStatusMeta();
  AccountStatus get unverified => _$unverified;
  AccountStatus get active => _$active;
  AccountStatus get deactivated => _$deactivated;
  AccountStatus get pendingDeletion => _$pendingDeletion;
  AccountStatus get suspended => _$suspended;
  AccountStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<AccountStatus> get values => _$values;
}

abstract class _$AccountStatusMixin {
  // ignore: non_constant_identifier_names
  _$AccountStatusMeta get AccountStatus => const _$AccountStatusMeta();
}

Serializer<AccountStatus> _$accountStatusSerializer =
    _$AccountStatusSerializer();

class _$AccountStatusSerializer implements PrimitiveSerializer<AccountStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'unverified': 'unverified',
    'active': 'active',
    'deactivated': 'deactivated',
    'pendingDeletion': 'pending_deletion',
    'suspended': 'suspended',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'unverified': 'unverified',
    'active': 'active',
    'deactivated': 'deactivated',
    'pending_deletion': 'pendingDeletion',
    'suspended': 'suspended',
  };

  @override
  final Iterable<Type> types = const <Type>[AccountStatus];
  @override
  final String wireName = 'AccountStatus';

  @override
  Object serialize(Serializers serializers, AccountStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  AccountStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      AccountStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
