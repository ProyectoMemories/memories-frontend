//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:memories_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_request.g.dart';

/// RegisterRequest
///
/// Properties:
/// * [username]
/// * [email]
/// * [password]
/// * [firstName]
/// * [paternalSurname]
/// * [maternalSurname]
/// * [birthDate]
/// * [acceptsPrivacyPolicy]
@BuiltValue()
abstract class RegisterRequest
    implements Built<RegisterRequest, RegisterRequestBuilder> {
  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'password')
  String get password;

  @BuiltValueField(wireName: r'first_name')
  String get firstName;

  @BuiltValueField(wireName: r'paternal_surname')
  String get paternalSurname;

  @BuiltValueField(wireName: r'maternal_surname')
  String? get maternalSurname;

  @BuiltValueField(wireName: r'birth_date')
  Date get birthDate;

  @BuiltValueField(wireName: r'accepts_privacy_policy')
  bool get acceptsPrivacyPolicy;

  RegisterRequest._();

  factory RegisterRequest([void updates(RegisterRequestBuilder b)]) =
      _$RegisterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterRequest> get serializer =>
      _$RegisterRequestSerializer();
}

class _$RegisterRequestSerializer
    implements PrimitiveSerializer<RegisterRequest> {
  @override
  final Iterable<Type> types = const [RegisterRequest, _$RegisterRequest];

  @override
  final String wireName = r'RegisterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    yield r'first_name';
    yield serializers.serialize(
      object.firstName,
      specifiedType: const FullType(String),
    );
    yield r'paternal_surname';
    yield serializers.serialize(
      object.paternalSurname,
      specifiedType: const FullType(String),
    );
    if (object.maternalSurname != null) {
      yield r'maternal_surname';
      yield serializers.serialize(
        object.maternalSurname,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'birth_date';
    yield serializers.serialize(
      object.birthDate,
      specifiedType: const FullType(Date),
    );
    yield r'accepts_privacy_policy';
    yield serializers.serialize(
      object.acceptsPrivacyPolicy,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'first_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.firstName = valueDes;
          break;
        case r'paternal_surname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.paternalSurname = valueDes;
          break;
        case r'maternal_surname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.maternalSurname = valueDes;
          break;
        case r'birth_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.birthDate = valueDes;
          break;
        case r'accepts_privacy_policy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.acceptsPrivacyPolicy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
