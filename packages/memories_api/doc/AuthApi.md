# memories_api.api.AuthApi

## Load the API package
```dart
import 'package:memories_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**changePasswordApiV1AuthPasswordChangePost**](AuthApi.md#changepasswordapiv1authpasswordchangepost) | **POST** /api/v1/auth/password/change | Change Password
[**forgotPasswordApiV1AuthPasswordForgotPost**](AuthApi.md#forgotpasswordapiv1authpasswordforgotpost) | **POST** /api/v1/auth/password/forgot | Forgot Password
[**loginApiV1AuthLoginPost**](AuthApi.md#loginapiv1authloginpost) | **POST** /api/v1/auth/login | Login
[**logoutApiV1AuthLogoutPost**](AuthApi.md#logoutapiv1authlogoutpost) | **POST** /api/v1/auth/logout | Logout
[**refreshApiV1AuthRefreshPost**](AuthApi.md#refreshapiv1authrefreshpost) | **POST** /api/v1/auth/refresh | Refresh
[**registerApiV1AuthRegisterPost**](AuthApi.md#registerapiv1authregisterpost) | **POST** /api/v1/auth/register | Register
[**resendVerificationApiV1AuthVerifyEmailResendPost**](AuthApi.md#resendverificationapiv1authverifyemailresendpost) | **POST** /api/v1/auth/verify-email/resend | Resend Verification
[**resetPasswordApiV1AuthPasswordResetPost**](AuthApi.md#resetpasswordapiv1authpasswordresetpost) | **POST** /api/v1/auth/password/reset | Reset Password
[**verifyEmailApiV1AuthVerifyEmailPost**](AuthApi.md#verifyemailapiv1authverifyemailpost) | **POST** /api/v1/auth/verify-email | Verify Email


# **changePasswordApiV1AuthPasswordChangePost**
> changePasswordApiV1AuthPasswordChangePost(changePasswordRequest)

Change Password

Cambia la contraseña y cierra todas las sesiones, también esta (HU-07).

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final ChangePasswordRequest changePasswordRequest = ; // ChangePasswordRequest | 

try {
    api.changePasswordApiV1AuthPasswordChangePost(changePasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->changePasswordApiV1AuthPasswordChangePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordRequest** | [**ChangePasswordRequest**](ChangePasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **forgotPasswordApiV1AuthPasswordForgotPost**
> JsonObject forgotPasswordApiV1AuthPasswordForgotPost(forgotPasswordRequest)

Forgot Password

Envía el enlace de recuperación. Responde igual exista o no la cuenta.

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final ForgotPasswordRequest forgotPasswordRequest = ; // ForgotPasswordRequest | 

try {
    final response = api.forgotPasswordApiV1AuthPasswordForgotPost(forgotPasswordRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->forgotPasswordApiV1AuthPasswordForgotPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordRequest** | [**ForgotPasswordRequest**](ForgotPasswordRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **loginApiV1AuthLoginPost**
> TokenResponse loginApiV1AuthLoginPost(loginRequest)

Login

Inicia sesión con correo o nombre de usuario (HU-03).

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final LoginRequest loginRequest = ; // LoginRequest | 

try {
    final response = api.loginApiV1AuthLoginPost(loginRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->loginApiV1AuthLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginRequest** | [**LoginRequest**](LoginRequest.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutApiV1AuthLogoutPost**
> logoutApiV1AuthLogoutPost(refreshTokenRequest)

Logout

Revoca la sesión de este dispositivo (HU-05). Repetirlo no da error.

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final RefreshTokenRequest refreshTokenRequest = ; // RefreshTokenRequest | 

try {
    api.logoutApiV1AuthLogoutPost(refreshTokenRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->logoutApiV1AuthLogoutPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshTokenRequest** | [**RefreshTokenRequest**](RefreshTokenRequest.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshApiV1AuthRefreshPost**
> TokenResponse refreshApiV1AuthRefreshPost(refreshTokenRequest)

Refresh

Rota el token de renovación (HU-04). Android: en el cuerpo; web: cookie.

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final RefreshTokenRequest refreshTokenRequest = ; // RefreshTokenRequest | 

try {
    final response = api.refreshApiV1AuthRefreshPost(refreshTokenRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->refreshApiV1AuthRefreshPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshTokenRequest** | [**RefreshTokenRequest**](RefreshTokenRequest.md)|  | [optional] 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **registerApiV1AuthRegisterPost**
> UserResponse registerApiV1AuthRegisterPost(registerRequest)

Register

Crea la cuenta sin verificar y envía el correo de verificación (HU-01).

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final RegisterRequest registerRequest = ; // RegisterRequest | 

try {
    final response = api.registerApiV1AuthRegisterPost(registerRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->registerApiV1AuthRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerRequest** | [**RegisterRequest**](RegisterRequest.md)|  | 

### Return type

[**UserResponse**](UserResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resendVerificationApiV1AuthVerifyEmailResendPost**
> JsonObject resendVerificationApiV1AuthVerifyEmailResendPost(resendVerificationRequest)

Resend Verification

Reenvía el enlace. Responde igual exista o no la cuenta (HU-02).

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final ResendVerificationRequest resendVerificationRequest = ; // ResendVerificationRequest | 

try {
    final response = api.resendVerificationApiV1AuthVerifyEmailResendPost(resendVerificationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->resendVerificationApiV1AuthVerifyEmailResendPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resendVerificationRequest** | [**ResendVerificationRequest**](ResendVerificationRequest.md)|  | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resetPasswordApiV1AuthPasswordResetPost**
> resetPasswordApiV1AuthPasswordResetPost(resetPasswordRequest)

Reset Password

Guarda la contraseña nueva y cierra todas las sesiones (HU-06).

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final ResetPasswordRequest resetPasswordRequest = ; // ResetPasswordRequest | 

try {
    api.resetPasswordApiV1AuthPasswordResetPost(resetPasswordRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->resetPasswordApiV1AuthPasswordResetPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordRequest** | [**ResetPasswordRequest**](ResetPasswordRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyEmailApiV1AuthVerifyEmailPost**
> verifyEmailApiV1AuthVerifyEmailPost(verifyEmailRequest)

Verify Email

Activa la cuenta con el token del enlace del correo (HU-02).

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getAuthApi();
final VerifyEmailRequest verifyEmailRequest = ; // VerifyEmailRequest | 

try {
    api.verifyEmailApiV1AuthVerifyEmailPost(verifyEmailRequest);
} on DioException catch (e) {
    print('Exception when calling AuthApi->verifyEmailApiV1AuthVerifyEmailPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyEmailRequest** | [**VerifyEmailRequest**](VerifyEmailRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

