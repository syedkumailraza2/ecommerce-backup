import 'package:flutter_login/flutter_login.dart';
import 'package:naf_garments/models/api_response.dart';
import 'package:naf_garments/utility/snack_bar_helper.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/user.dart';
import '../login_screen.dart';
import '../../../services/http_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utility/constants.dart';


class UserProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final box = GetStorage();

  UserProvider(this._dataProvider);

 Future<String?> login(LoginData data) async {
  try {
    Map<String, dynamic> loginData = {"name": data.name.toLowerCase(), "password": data.password};
    final response = await service.addItem(endpointUrl: 'users/login', itemData: loginData);
    if (response.isOk) {
      final ApiResponse<User> apiResponse = 
        ApiResponse<User>.fromJson(response.body, (json) => User.fromJson(json as Map<String, dynamic>));
      if (apiResponse.success == true) {
        User? user = apiResponse.data;
        saveLoginInfo(user);
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        print('Login success');
        return null;
      } else {
        SnackBarHelper.showErrorSnackBar('Failed to Login: ${apiResponse.message}');
        return 'Failed to Login';
      }
    } else {
      SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      return 'Error ${response.body?['message'] ?? response.statusText}';
    }
  } catch (e) {
    SnackBarHelper.showErrorSnackBar('Unexpected error: $e');
    return 'Unexpected error';
  }
}


 Future<String?> register(SignupData data) async {
    try {
      Map<String, dynamic> user = {"name": data.name?.toLowerCase(), "password": data.password};
final response = await service.addItem(endpointUrl: 'users/register', itemData: user);
print("Response: ${response.body}");


if (response.isOk) {
    ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
    if (apiResponse.success == true) {
        SnackBarHelper.showSuccessSnackBar(apiResponse.message);
        print('Register Success');
        return null;
    } else {
        SnackBarHelper.showErrorSnackBar('Failed to Register: ${apiResponse.message}');
        return 'Failed to Register: ${apiResponse.message}';
    }
} else {
    SnackBarHelper.showErrorSnackBar('Error ${response.body?["message"] ?? response.statusText}');
    return 'Error ${response.body?["message"] ?? response.statusText}';
}

    } catch (e) {
     print("Error while signup: ${e}");
     SnackBarHelper.showErrorSnackBar('An error occured: $e');
     return 'An error occured: $e';
    }
  }


  Future<void> saveLoginInfo(User? loginUser) async {
    await box.write(USER_INFO_BOX, loginUser?.toJson());
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
  }

  User? getLoginUsr() {
    Map<String, dynamic>? userJson = box.read(USER_INFO_BOX);
    User? userLogged = User.fromJson(userJson ?? {});
    return userLogged;
  }

  logOutUser() {
    box.remove(USER_INFO_BOX);
    Get.offAll(const LoginScreen());
  }
}
