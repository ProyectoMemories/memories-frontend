// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_platform.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ClientPlatform _$android = const ClientPlatform._('android');
const ClientPlatform _$web = const ClientPlatform._('web');

ClientPlatform _$valueOf(String name) {
  switch (name) {
    case 'android':
      return _$android;
    case 'web':
      return _$web;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ClientPlatform> _$values =
    BuiltSet<ClientPlatform>(const <ClientPlatform>[
  _$android,
  _$web,
]);

class _$ClientPlatformMeta {
  const _$ClientPlatformMeta();
  ClientPlatform get android => _$android;
  ClientPlatform get web => _$web;
  ClientPlatform valueOf(String name) => _$valueOf(name);
  BuiltSet<ClientPlatform> get values => _$values;
}

abstract class _$ClientPlatformMixin {
  // ignore: non_constant_identifier_names
  _$ClientPlatformMeta get ClientPlatform => const _$ClientPlatformMeta();
}

Serializer<ClientPlatform> _$clientPlatformSerializer =
    _$ClientPlatformSerializer();

class _$ClientPlatformSerializer
    implements PrimitiveSerializer<ClientPlatform> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'android': 'android',
    'web': 'web',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'android': 'android',
    'web': 'web',
  };

  @override
  final Iterable<Type> types = const <Type>[ClientPlatform];
  @override
  final String wireName = 'ClientPlatform';

  @override
  Object serialize(Serializers serializers, ClientPlatform object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ClientPlatform deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ClientPlatform.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
