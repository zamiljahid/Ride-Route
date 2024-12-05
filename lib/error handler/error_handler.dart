import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/material.dart';

class ErrorDialog {
  static void showErrorDialog(BuildContext context, int statusCode, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomColors.navyBlue.withOpacity(.5),
          title: Text('Error $statusCode !!!', style: TextStyle(color: CustomColors.white, fontWeight: FontWeight.bold, fontSize: 20),),
          content: Text(message, style: TextStyle(color: CustomColors.white, fontSize: 18),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: CustomColors.white, fontSize: 18, fontWeight: FontWeight.bold),),
            ),
          ],
        );
      },
    );
  }
}
