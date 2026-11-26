// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation_error_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ValidationErrorResponse extends ValidationErrorResponse {
  @override
  final String code;
  @override
  final String message;
  @override
  final BuiltList<FieldError> errors;

  factory _$ValidationErrorResponse(
          [void Function(ValidationErrorResponseBuilder)? updates]) =>
      (ValidationErrorResponseBuilder()..update(updates))._build();

  _$ValidationErrorResponse._(
      {required this.code, required this.message, required this.errors})
      : super._();
  @override
  ValidationErrorResponse rebuild(
          void Function(ValidationErrorResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ValidationErrorResponseBuilder toBuilder() =>
      ValidationErrorResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ValidationErrorResponse &&
        code == other.code &&
        message == other.message &&
        errors == other.errors;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, errors.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ValidationErrorResponse')
          ..add('code', code)
          ..add('message', message)
          ..add('errors', errors))
        .toString();
  }
}

class ValidationErrorResponseBuilder
    implements
        Builder<ValidationErrorResponse, ValidationErrorResponseBuilder> {
  _$ValidationErrorResponse? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  ListBuilder<FieldError>? _errors;
  ListBuilder<FieldError> get errors =>
      _$this._errors ??= ListBuilder<FieldError>();
  set errors(ListBuilder<FieldError>? errors) => _$this._errors = errors;

  ValidationErrorResponseBuilder() {
    ValidationErrorResponse._defaults(this);
  }

  ValidationErrorResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _message = $v.message;
      _errors = $v.errors.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ValidationErrorResponse other) {
    _$v = other as _$ValidationErrorResponse;
  }

  @override
  void update(void Function(ValidationErrorResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ValidationErrorResponse build() => _build();

  _$ValidationErrorResponse _build() {
    _$ValidationErrorResponse _$result;
    try {
      _$result = _$v ??
          _$ValidationErrorResponse._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ValidationErrorResponse', 'code'),
            message: BuiltValueNullFieldError.checkNotNull(
                message, r'ValidationErrorResponse', 'message'),
            errors: errors.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'errors';
        errors.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ValidationErrorResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
