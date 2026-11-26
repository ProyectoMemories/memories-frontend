//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'client_platform.g.dart';

/// Dónde se inició la sesión (D51).
class ClientPlatform extends EnumClass {
  @BuiltValueEnumConst(wireName: r'android')
  static const ClientPlatform android = _$android;
  @BuiltValueEnumConst(wireName: r'web')
  static const ClientPlatform web = _$web;

  static Serializer<ClientPlatform> get serializer =>
      _$clientPlatformSerializer;

  const ClientPlatform._(String name) : super(name);

  static BuiltSet<ClientPlatform> get values => _$values;
  static ClientPlatform valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ClientPlatformMixin = Object with _$ClientPlatformMixin;
