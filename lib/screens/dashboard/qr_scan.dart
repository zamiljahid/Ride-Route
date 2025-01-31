import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:delivary/screens/dashboard/store_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Include this package in your pubspec.yaml
import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lottie/lottie.dart';

import 'model/store_model.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen>
    with SingleTickerProviderStateMixin {
  String? qrCode;
  bool isQR = false;
  Store? storeData;
  bool isNavigated = false;


  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
  }


  Future<void> scanQR() async {
    final qrController = Completer<QRViewController>();
    bool isQRScanned = false;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: (controller) {
                  qrController.complete(controller);
                  controller.scannedDataStream.listen((scanData) async {
                    if (!isQRScanned) {
                      isQRScanned = true; // Prevent multiple triggers
                      await handleScannedData(scanData.code);
                    }
                  });
                },
              ),
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Pause and dispose the controller on pop
    qrController.future.then((controller) {
      controller.dispose();
    });
  }

  Future<void> handleScannedData(String? qrCode) async {
    if (qrCode == null) return;

    try {
      print("Scanned QR Code: $qrCode");

      Map<String, dynamic> jsonData = jsonDecode(qrCode);
      setState(() {
        storeData = Store.fromJson(jsonData);
      });
      print("Fetched store data: ${storeData?.toJson()}");
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context); // Close scanner screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => StoreScreen(
            storeData: storeData
        )),
      );
    } catch (e) {
      print("Error parsing store data: $e");
      if (e is FormatException) {
        print("The scanned data is not valid JSON.");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height, // Set height to viewport height
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap to scan store QR code',
                  style: TextStyle(
                    color: CustomColors.black,
                    fontSize: 18,
                    fontFamily: 'Rowdies',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 90.0),
                    child: Container(
                      height: 300,
                      width: 220,
                      child: GestureDetector(
                        // onTap: (){
                        //   print("object");
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => const StoreScreen()),
                        //   );
                        // },
                        onTap: scanQR,
                        child: Container(
                          decoration: BoxDecoration(
                            color: CustomColors.navyBlue.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: CustomColors.navyBlue,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Lottie.asset(
                                          'animation/qrScan.json',
                                          height: MediaQuery.of(context).size.height / 2.9,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
