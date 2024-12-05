import 'dart:convert';
import 'dart:ui';

import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:delivary/screens/splash%20screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import '../../api/api_client.dart';
import '../../error handler/error_handler.dart';
import '../../fcm_service.dart';
import '../../location.dart';
import '../../shared_preference.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String? loginID;
  String? password;
  TextEditingController loginIdKeyController = TextEditingController();
  TextEditingController passwordKeyController = TextEditingController();
  bool passwordVisible = false;
  String? version;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  FCMService fcmService = FCMService();
  LocationService locationService = LocationService();


  @override
  void initState() {
    super.initState();
  }



  String? _emailErrorText;

  String? _validateEmail(String? value) {
    RegExp emailRegex = RegExp(r'^[\w-.]+@[a-zA-Z]+\.[a-zA-Z]{2,}$');
    final isEmailValid = emailRegex.hasMatch(value ?? '');
    if (!isEmailValid) {
      return 'Please enter a valid Login ID';
    }
    return null;
  }

  void displayMessageToUser(String message, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.customeBlue,
      body: Form(
        key: _formKey,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text(
                        "Rasd Almodon",
                        style: TextStyle(
                            fontSize: 32,
                            fontFamily: 'Rowdies',
                            color: CustomColors.white),
                      ),
                    ),
                    Lottie.asset('animation/delivery.json', height: 300),
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, right: 20, left: 20, bottom: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), // Adjust opacity for transparency
                          borderRadius: BorderRadius.circular(15), // Optional: to give rounded corners
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1), // Optional: Glass border
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15), // Ensure the blur is limited to the container
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Adjust blur strength
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontFamily: 'Rowdies',
                                      color: CustomColors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
                                  child: TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmail,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(color: Colors.white), // Input text color set to white
                                    controller: loginIdKeyController,
                                    cursorColor: CustomColors.white, // Cursor color set to white
                                    decoration: InputDecoration(
                                      errorText: _emailErrorText,
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: CustomColors.white,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent, // Adjust fill transparency
                                      icon: Icon(
                                        Icons.person,
                                        size: 35,
                                        color: CustomColors.white,
                                      ),
                                      labelText: 'Login ID',
                                      labelStyle: const TextStyle(color: Colors.white,                             fontFamily: 'Rowdies',
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 15),
                                  child: TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) => value!.length < 3 ? 'Please enter the Password' : null,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(color: Colors.white), // Input text color set to white
                                    obscureText: !passwordVisible,
                                    controller: passwordKeyController,
                                    cursorColor: CustomColors.white, // Cursor color set to white
                                    decoration: InputDecoration(
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                        borderSide: BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0),
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.transparent, // Adjust fill transparency
                                      icon: Icon(
                                        Icons.key,
                                        size: 35,
                                        color: CustomColors.white,
                                      ),
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(color: Colors.white,                             fontFamily: 'Rowdies',
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordVisible ? Icons.visibility : Icons.visibility_off,
                                          color: CustomColors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                SizedBox(
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.white,
                    ),
                    onPressed: () async {
                      String loginId = loginIdKeyController.text.trim();
                      String password = passwordKeyController.text.trim();
                      if (loginId.isEmpty || password.isEmpty) {
                        ErrorDialog.showErrorDialog(context, 400, 'Please fill in both login ID and password.');
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });
                      Map<String, String> payload = {
                        'username': loginId,
                        'password': password,
                      };
                      try {
                        var response = await ApiClient().postWithoutToken(payload, context);
                        if (response != null) {
                          // No need to call jsonDecode again
                          var responseData = response;  // response is already a Map<String, dynamic>

                          String? token = responseData["auth_token"];
                          var user = responseData["user"];
                          String? uId = user?["u_id"]?.toString();
                          String? driverId = user?["driver_id"]?.toString();

                          if (token != null) {
                            await SharedPrefs.setString('token', token);
                            await SharedPrefs.setString('id', uId ?? '');
                            await SharedPrefs.setString('driver_id', driverId ?? '');

                            print(token.toString());
                            print(uId.toString());
                            print(driverId.toString());

                            fcmService.initialize(driverId.toString(), token);
                            LocationService().startLocationUpdates(driverId!, token);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SplashScreen()),
                            );
                          } else {
                            int statusCode = responseData["statusCode"];
                            String errorMessage = responseData["Message"];
                            ErrorDialog.showErrorDialog(context, statusCode, errorMessage);
                          }
                        }
                      } catch (e) {
                        print('Unexpected error: $e');
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child:Text(
                      'LOGIN',
                      style: TextStyle(
                        color: CustomColors.customeBlue,
                        fontFamily: 'Rowdies',
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                    const SizedBox(
                      height: 50,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: version != null
                          ? Text(
                        "Version ${version}",
                        style: const TextStyle(
                            fontFamily: 'Rowdies',
                            color: Colors.black, fontSize: 10),
                      )
                          : Text(" "),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isLoading,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  color: CustomColors.white,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

