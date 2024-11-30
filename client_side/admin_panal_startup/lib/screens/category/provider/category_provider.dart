import 'dart:io';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';

import '../../../services/http_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';

class CategoryProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final addCategoryFormKey = GlobalKey<FormState>();
  TextEditingController categoryNameCtrl = TextEditingController();
  Category? categoryForUpdate;


  File? selectedImage;
  XFile? imgXFile;


  CategoryProvider(this._dataProvider);

  addCategory() async {
    try {
      // Check if an image is selected
      if (selectedImage == null) {
        SnackBarHelper.showErrorSnackBar('Please choose an image');
        return;
      }

      // Prepare form data map
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text.trim(),
        'image': 'no_data', // Default value for image
      };

      // Create FormData
      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      // Send request to add category
      final response = await service.addItem(endpointUrl: 'categories', itemData: form);

      // Check response status
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        // Check success flag in API response
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message ?? 'Category added successfully');
          print('Category added');
          _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to add category: ${apiResponse.message ?? 'Unknown error'}');
        }
      } else {
        // Handle non-OK responses
        final errorMessage = response.body?['message'] ?? response.statusText ?? 'Unknown error';
        SnackBarHelper.showErrorSnackBar('Error: $errorMessage');
      }
    } catch (e) {
      // Handle unexpected errors
      print("Error adding category: $e");
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }



  updateCategory() async {
    try {
      // Prepare form data map
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': categoryForUpdate?.image ?? ''
      };

      // Create FormData
      final FormData form = await createFormData(imgXFile: imgXFile, formData: formDataMap);

      // Send request to add category
      final response =
      await service.updateItem(endpointUrl: 'categories', itemData: form, itemId: categoryForUpdate?.sId ?? '');

      // Check response status
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        // Check success flag in API response
        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message ?? 'Category added successfully');
          print('Category added');
          _dataProvider.getAllCategory();
        } else {
          SnackBarHelper.showErrorSnackBar('Failed to add category: ${apiResponse.message ?? 'Unknown error'}');
        }
      } else {
        // Handle non-OK responses
        final errorMessage = response.body?['message'] ?? response.statusText ?? 'Unknown error';
        SnackBarHelper.showErrorSnackBar('Error: $errorMessage');
      }
    } catch (e) {
      // Handle unexpected errors
      print("Error adding category: $e");
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
    }
  }

  submitCategory() {
    if(categoryForUpdate != null){
      updateCategory();
    }
    else {
      addCategory();
    }
  }


  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  deleteCategory(Category category) async {
    try {
      Response response = await service.deleteItem(endpointUrl: 'categories', itemId: category.sId ?? '');
      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Category Deleted Successfully');
          _dataProvider.getAllCategory();
        }
      } else {
        SnackBarHelper.showErrorSnackBar('Error ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }




  //? to create form data for sending image with body
  Future<FormData> createFormData({required XFile? imgXFile, required Map<String, dynamic> formData}) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    final FormData form = FormData(formData);
    return form;
  }

  //? set data for update on editing
  setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    } else {
      clearFields();
    }
  }

  //? to clear text field and images after adding or update category
  clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
  }
}
