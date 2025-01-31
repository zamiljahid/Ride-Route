import 'dart:convert';
import 'package:delivary/screens/dashboard/model/cash_flow_model.dart';
import 'package:delivary/screens/dashboard/model/product_model.dart';
import 'package:delivary/screens/dashboard/model/store_location_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../error handler/error_handler.dart';
import '../screens/dashboard/model/pending_store_model.dart';
import '../screens/dashboard/model/profile_model.dart';
import '../screens/dashboard/model/user_model.dart';
const String baseUrl = 'https://logicgate99.pythonanywhere.com';
const String authTokenUrl = '/auth/token/login/';
const String authUserUrl = '/auth/users/me/';
const String cashFlowUrl = '/api/get-cashflow-data/';
const String storeLocationUrl = '/api/stores/';
const String pendingStoreUrl = '/api/pickups';
const String profileUrl = '/api/drivers';
const String productUrl = '/api/products/';
const String changePassUrl = '/auth/users/set_password/';

class ApiClient {

  Future<dynamic> postWithoutToken(dynamic payload, BuildContext context) async {
    try {
      var url = Uri.parse(baseUrl + authTokenUrl);
      print('Request URL: $url');
      print('Payload: ${jsonEncode(payload)}');
      var response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        String errorMessage = 'An error occurred. Please try again.';
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody is Map && responseBody.containsKey('non_field_errors')) {
            errorMessage = (responseBody['non_field_errors'] as List).join(', ');
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
        }
        ErrorDialog.showErrorDialog(context, response.statusCode, errorMessage);
        return null;
      }
    } catch (e) {
      print('Unexpected error: $e');
      ErrorDialog.showErrorDialog(
          context, 500, 'Unexpected error occurred. Please try again later.');
      return null;
    }
  }


  Future<dynamic> postChangePassword(dynamic payload, BuildContext context, String token) async {
    try {
      var url = Uri.parse(baseUrl + changePassUrl);
      print(url.toString());
      print(payload.toString());
      var response = await http.post(
        url,
        body: payload,
        headers: {
          'Authorization': 'Token $token',
        },
      );
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'status': 'success'};
      } else {
        String errorMessage = 'An error occurred. Please try again.';
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('non_field_errors')) {
            errorMessage = (responseBody['non_field_errors'] as List).join(', ');
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
        }
        ErrorDialog.showErrorDialog(context, response.statusCode, errorMessage);
        return {'status': 'error', 'message': errorMessage};
      }
    } catch (e) {
      print('Unexpected error: $e');
      ErrorDialog.showErrorDialog(context, 500, 'Unexpected error occurred. Please try again later.');
      return {'status': 'error', 'message': 'Unexpected error occurred.'};
    }
  }


  Future<ProfileModel?> getProfile(
      String api, String token, BuildContext context)
  async {
    try {
      var url = Uri.parse(baseUrl + profileUrl + api);
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
        },
      );
      print(url.toString());
      print(response.body.toString());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = json.decode(response.body);
        if (jsonData is List && jsonData.isNotEmpty) {
          return ProfileModel.fromJson(jsonData[0]);
        } else if (jsonData is Map<String, dynamic>) {
          return ProfileModel.fromJson(jsonData);
        } else {
          print('Unexpected JSON format.');
          return null;
        }
      } else {
        String errorMessage = 'An error occurred. Please try again.';
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('non_field_errors')) {
            errorMessage =
                (responseBody['non_field_errors'] as List).join(', ');
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
        }
        ErrorDialog.showErrorDialog(context, response.statusCode, errorMessage);
        return null;
      }
    } catch (e) {
      print('Unexpected error in profile data: $e');
      ErrorDialog.showErrorDialog(
          context, 500, 'Unexpected error occurred. Please try again later.');
      return null;
    }
  }
  Future<CashFlowModel?> getCashFlow(String token) async {
    final url =Uri.parse(baseUrl + cashFlowUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );
    print(url.toString());
    print(response.body.toString());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      CashFlowModel user = CashFlowModel.fromJson(data);
      return user;
    } else {
      print('Error fetching data: ${response.statusCode}');
      return null;
    }
  }

  Future<List<StoreLocationModel>?> getStoreLocation(String token) async {
    final url =Uri.parse(baseUrl + storeLocationUrl);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );
    print(url.toString());
    print(response.body.toString());
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<StoreLocationModel> storeLocations = data
          .map((storeData) => StoreLocationModel.fromJson(storeData))
          .toList();
      return storeLocations;
    } else {
      print('Error fetching data: ${response.statusCode}');
      return null;
    }
  }
  Future<List<PendingStoreModel>> getPendingStores(String token, String driverId, String status, String date)
  async {
    try {
      var url = Uri.parse(baseUrl + pendingStoreUrl + driverId + status + date);

      final response = await http.get(url, headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      });
      print(url.toString());
      print(response.body.toString());
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData
            .map((data) => PendingStoreModel.fromJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<dynamic> patchStoreStatus(dynamic payload, String token, String productId, BuildContext context)
  async {
    try {
      var url = Uri.parse(baseUrl + pendingStoreUrl + '$productId/');
      print(url.toString());
      print(payload.toString());
      var response = await http.patch(
        url,
        body: payload,
        headers: {
          'Authorization': 'Token $token',
        },
      );
      print(url.toString());
      print(response.body.toString());
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        String errorMessage = 'An error occurred. Please try again.';
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('non_field_errors')) {
            errorMessage =
                (responseBody['non_field_errors'] as List).join(', ');
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
        }
        ErrorDialog.showErrorDialog(context, response.statusCode, errorMessage);
        return null;
      }
    } catch (e) {
      print('Unexpected error patch store status: $e');
      ErrorDialog.showErrorDialog(
          context, 500, 'Unexpected error occurred. Please try again later.');
      return null;
    }
  }

  Future<dynamic> postActions(dynamic payload, String token, String actionUrl, BuildContext context) async {
    try {
      var url = Uri.parse(baseUrl + actionUrl);
      print(url.toString());
      print(payload.toString());

      var response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      print(response.body.toString());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        var responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['error'];
        try {
          var responseBody = jsonDecode(response.body);
          if (responseBody.containsKey('non_field_errors')) {
            errorMessage = (responseBody['non_field_errors'] as List).join(', ');
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
        }
        ErrorDialog.showErrorDialog(context, response.statusCode, errorMessage);
        return null;
      }
    } catch (e) {
      print('Unexpected error in post action: $e');
      ErrorDialog.showErrorDialog(
          context, 500, 'Unexpected error occurred. Please try again later.');
      return null;
    }
  }

}
