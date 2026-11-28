//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:memories_api/src/date_serializer.dart';
import 'package:memories_api/src/model/date.dart';

import 'package:memories_api/src/model/account_status.dart';
import 'package:memories_api/src/model/change_password_request.dart';
import 'package:memories_api/src/model/client_platform.dart';
import 'package:memories_api/src/model/error_response.dart';
import 'package:memories_api/src/model/field_error.dart';
import 'package:memories_api/src/model/forgot_password_request.dart';
import 'package:memories_api/src/model/http_validation_error.dart';
import 'package:memories_api/src/model/health_response.dart';
import 'package:memories_api/src/model/location_inner.dart';
import 'package:memories_api/src/model/login_request.dart';
import 'package:memories_api/src/model/profile_response.dart';
import 'package:memories_api/src/model/refresh_token_request.dart';
import 'package:memories_api/src/model/register_request.dart';
import 'package:memories_api/src/model/resend_verification_request.dart';
import 'package:memories_api/src/model/reset_password_request.dart';
import 'package:memories_api/src/model/token_response.dart';
import 'package:memories_api/src/model/user_response.dart';
import 'package:memories_api/src/model/validation_error.dart';
import 'package:memories_api/src/model/validation_error_response.dart';
import 'package:memories_api/src/model/verify_email_request.dart';

part 'serializers.g.dart';

@SerializersFor([
  AccountStatus,
  ChangePasswordRequest,
  ClientPlatform,
  ErrorResponse,
  FieldError,
  ForgotPasswordRequest,
  HTTPValidationError,
  HealthResponse,
  LocationInner,
  LoginRequest,
  ProfileResponse,
  RefreshTokenRequest,
  RegisterRequest,
  ResendVerificationRequest,
  ResetPasswordRequest,
  TokenResponse,
  UserResponse,
  ValidationError,
  ValidationErrorResponse,
  VerifyEmailRequest,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(FieldError)]),
        () => ListBuilder<FieldError>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LocationInner)]),
        () => ListBuilder<LocationInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ValidationError)]),
        () => ListBuilder<ValidationError>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
