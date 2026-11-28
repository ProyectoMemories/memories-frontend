//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'profile_response.g.dart';

/// ProfileResponse
///
/// Properties:
/// * [id]
/// * [username]
/// * [email]
/// * [firstName]
/// * [paternalSurname]
/// * [maternalSurname] - null si la persona no lo escribió al registrarse.
@BuiltValue()
abstract class ProfileResponse
    implements Built<ProfileResponse, ProfileResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'first_name')
  String get firstName;

  @BuiltValueField(wireName: r'paternal_surname')
  String get paternalSurname;

  /// null si la persona no lo escribió al registrarse.
  @BuiltValueField(wireName: r'maternal_surname')
  String? get maternalSurname;

  ProfileResponse._();

  factory ProfileResponse([void updates(ProfileResponseBuilder b)]) =
      _$ProfileResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProfileResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProfileResponse> get serializer =>
      _$ProfileResponseSerializer();
}

class _$ProfileResponseSerializer
    implements PrimitiveSerializer<ProfileResponse> {
  @override
  final Iterable<Type> types = const [ProfileResponse, _$ProfileResponse];

  @override
  final String wireName = r'ProfileResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProfileResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
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
    yield r'maternal_surname';
    yield object.maternalSurname == null
        ? null
        : serializers.serialize(
            object.maternalSurname,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProfileResponse object, {
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
    required ProfileResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProfileResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProfileResponseBuilder();
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
