# memories_api.api.HealthApi

## Load the API package
```dart
import 'package:memories_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthHealthGet**](HealthApi.md#healthhealthget) | **GET** /health | Health


# **healthHealthGet**
> HealthResponse healthHealthGet()

Health

Responde si el proceso de la API está vivo.

### Example
```dart
import 'package:memories_api/api.dart';

final api = MemoriesApi().getHealthApi();

try {
    final response = api.healthHealthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthHealthGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**HealthResponse**](HealthResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

