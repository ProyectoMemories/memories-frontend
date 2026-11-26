# memories_api.model.TokenResponse

## Load the model package
```dart
import 'package:memories_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accessToken** | **String** |  | 
**tokenType** | **String** |  | [optional] [default to 'bearer']
**expiresIn** | **int** | Segundos que dura el token de acceso. | 
**refreshToken** | **String** | Solo en Android. En web viaja en una cookie httpOnly. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


