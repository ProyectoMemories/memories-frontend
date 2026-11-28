# memories_api.api.UsersApi

## Load the API package
```dart
import 'package:memories_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMyProfileApiV1UsersMeGet**](UsersApi.md#getmyprofileapiv1usersmeget) | **GET** /api/v1/users/me | Get My Profile


# **getMyProfileApiV1UsersMeGet**
> ProfileResponse getMyProfileApiV1UsersMeGet()

Get My Profile

Datos de quien inició sesión (HU-01). El id sale del token (RNF-02).

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getUsersApi();

try {
    final response = api.getMyProfileApiV1UsersMeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UsersApi->getMyProfileApiV1UsersMeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProfileResponse**](ProfileResponse.md)

### Authorization

[HTTPBearer](../README.md#HTTPBearer)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

