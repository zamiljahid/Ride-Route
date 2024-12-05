import 'dart:ui';

import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../api/api_client.dart';
import '../../main.dart';
import '../../shared_preference.dart';
import '../splash screen/splash_screen.dart';


class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController newPasswordKeyController = TextEditingController();
  TextEditingController currentPasswordKeyController = TextEditingController();
  bool _isLoading = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.customeBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: CustomColors.white, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('animation/changePass.json', height: 250),
              const SizedBox(height: 10),
              const Text(
                "Change Password",
                style: TextStyle(fontSize: 24, fontFamily: 'Rowdies', color: Colors.white),
              ),
              const SizedBox(height: 10),
              _buildPasswordFields(),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  width: 150,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: _isLoading ? null : _handleChangePassword,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: CustomColors.white)
                        : const Text(
                      'Update',
                      style: TextStyle(
                        color: CustomColors.customeBlue,
                        fontSize: 18,
                        fontFamily: 'Rowdies',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        child: Column(
          children: [
            _buildPasswordField(
              controller: currentPasswordKeyController,
              label: 'Current Password',
              isPasswordVisible: _currentPasswordVisible,
              onToggleVisibility: () {
                setState(() => _currentPasswordVisible = !_currentPasswordVisible);
              },
            ),
            _buildPasswordField(
              controller: newPasswordKeyController,
              label: 'New Password',
              isPasswordVisible: _newPasswordVisible,
              onToggleVisibility: () {
                setState(() => _newPasswordVisible = !_newPasswordVisible);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isPasswordVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: TextFormField(
        controller: controller,
        obscureText: !isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        cursorColor: CustomColors.white,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock, size: 35, color: CustomColors.white),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white, fontFamily: 'Rowdies'),
          filled: true,
          fillColor: Colors.transparent,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: CustomColors.white,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    final currentPassword = currentPasswordKeyController.text.trim();
    final newPassword = newPasswordKeyController.text.trim();

    // Check if fields are empty
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Set loading state to true
    setState(() => _isLoading = true);

    final payload = {"current_password": currentPassword, "new_password": newPassword};

    try {
      // Call the API method to change the password
      final result = await ApiClient().postChangePassword(
        payload,
        context,
        "${SharedPrefs.getString('token').toString()}",
      );

      // Set loading state to false once the API response is received
      setState(() => _isLoading = false);

      // Log the response for debugging
      print('API Response: $result');

      // Handle the API response
      if (result != null && result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        await SharedPrefs.remove('token');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainClass()),
              (Route<dynamic> route) => false,
        );
      } else {
        String errorMessage = result?['message'] ?? 'Failed to change password. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred. Please try again later.')),
      );
    }
  }
}
