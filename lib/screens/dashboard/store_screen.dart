import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:delivary/screens/dashboard/model/product_model.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Include this package in your pubspec.yaml
import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_client.dart';
import '../../error handler/error_handler.dart';
import '../../shared_preference.dart';
import 'model/store_model.dart';

class StoreScreen extends StatefulWidget {
  final Store? storeData;

  const StoreScreen({Key? key, this.storeData}) : super(key: key);

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  String? qrCode, selectedCodeType;
  bool isQR = false;
  bool isMenuOpen = false;
  late AnimationController _controller;
  List<String> selectedProducts = [];
  TextEditingController productCodeController = TextEditingController();
  late Animation<double> _animation;
  Store? storeData;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
  }


  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
      isMenuOpen ? _controller.forward() : _controller.reverse();
    });
  }

  String? selectedAction = null;

  bool isScanning = false;

// Function to open the barcode scanner
  Future<void> _scanBarcode() async {
    var result = await BarcodeScanner.scan(); // Start scanning
    if (result.rawContent.isNotEmpty) {
      setState(() {
        productCodeController.text = result.rawContent; // Set the scanned barcode to the input field
        selectedProducts.add(result.rawContent); // Add scanned product to the list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double angle = _controller.value * 2 * pi;
                  Alignment beginAlignment = Alignment(cos(angle), sin(angle));
                  Alignment endAlignment = Alignment(-cos(angle), -sin(angle));
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CustomColors.customeBlue,
                          CustomColors.blue,
                        ],
                        begin: beginAlignment,
                        end: endAlignment,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Image.asset(
                          'assets/images/reset.png',
                          height: 35,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: CustomColors.customeBlue,
                          boxShadow: const [
                            BoxShadow(
                              color: CustomColors.navyBlue,
                              offset: Offset(4.0, 4.0),
                              blurRadius: 15.0,
                              spreadRadius: 1.0,
                            ),
                            BoxShadow(
                              color: CustomColors.navyBlue,
                              offset: Offset(-4.0, -4.0),
                              blurRadius: 15.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Store Details',
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontFamily: 'Rowdies',
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                widget.storeData?.storeName ?? 'Unknown Store',
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontFamily: 'Rowdies',
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                'Location: ${widget.storeData?.storeLocation}',
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontFamily: 'Rowdies',
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Contact: ${widget.storeData?.pointOfContact}',
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontFamily: 'Rowdies',
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'WhatsApps number: ${widget.storeData?.whatsappNumber}',
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontFamily: 'Rowdies',
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Email: ${widget.storeData?.email}',
                                style: const TextStyle(
                                  color: CustomColors.white,
                                  fontFamily: 'Rowdies',
                                  fontSize: 12,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: SpeedDial(
                                        icon: null,
                                        child: Image.asset(
                                          'assets/images/press.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                        backgroundColor: CustomColors.white,
                                        overlayColor: CustomColors.customeBlue,
                                        overlayOpacity: 0.5,
                                        curve: Curves.slowMiddle,
                                        animationCurve: Curves.bounceIn,
                                        children: [
                                          SpeedDialChild(
                                            child: Image.asset(
                                              'assets/images/inventory.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                            backgroundColor: CustomColors.white,
                                            label: 'Inventory',
                                            labelStyle: TextStyle(
                                                fontFamily: 'Rowdies',
                                                color: CustomColors.black),
                                            onTap: () {
                                              setState(() {
                                                selectedAction = "Inventory";
                                              });
                                            },
                                          ),
                                          SpeedDialChild(
                                            child: Image.asset(
                                              'assets/images/return.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                            backgroundColor: CustomColors.white,
                                            label: 'Return',
                                            labelStyle: TextStyle(
                                                fontFamily: 'Rowdies',
                                                color: CustomColors.black),
                                            onTap: () {
                                              setState(() {
                                                selectedAction = "Return";
                                              });
                                            },
                                          ),
                                          SpeedDialChild(
                                            child: Image.asset(
                                              'assets/images/dropOff.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                            backgroundColor: CustomColors.white,
                                            label: 'Drop off',
                                            labelStyle: TextStyle(
                                                fontFamily: 'Rowdies',
                                                color: CustomColors.black),
                                            onTap: () {
                                              setState(() {
                                                selectedAction = "Drop off";
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Tap for Actions',
                                      style: const TextStyle(
                                        fontFamily: 'Rowdies',
                                        color: CustomColors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  selectedAction ?? "No Action Selected",
                  style: TextStyle(
                    fontFamily: 'Rowdies',
                    color: CustomColors.customeBlue,
                    fontSize: 30,
                  ),
                ),
                Visibility(
                  visible: selectedAction != null,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            activeColor: CustomColors.customeBlue,
                            value: "Box Code",
                            groupValue: selectedCodeType,
                            onChanged: (value) {
                              setState(() {
                                selectedCodeType = value!;
                              });
                            },
                          ),
                          const Text("Box Code"),
                          const SizedBox(width: 20),
                          Radio<String>(
                            activeColor: CustomColors.customeBlue,
                            value: "Product Code",
                            groupValue: selectedCodeType,
                            onChanged: (value) {
                              setState(() {
                                selectedCodeType = value!;
                              });
                            },
                          ),
                          const Text("Product Code"),
                        ],
                      ),
                      // Add Code Section
                      if (selectedCodeType != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: CustomColors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                onPressed: _scanBarcode, // Trigger the barcode scan when pressed
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: productCodeController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Rowdies',
                                ),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  hintText: 'Enter $selectedCodeType',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'Rowdies',
                                  ),
                                  filled: true,
                                  fillColor: CustomColors.blue,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(color: Colors.white),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.check, color: Colors.white),
                                    onPressed: () async {
                                      String productCode = productCodeController.text.trim();
                                      if (productCode.isNotEmpty) {
                                        setState(() {
                                          selectedProducts.add(productCode); // Add product to list
                                        });
                                        productCodeController.clear(); // Clear input field
                                      } else {
                                        print('No product code entered');
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      const SizedBox(height: 20),
                      // Product list display
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: selectedProducts.map((product) {
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              color: CustomColors.blue,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      product,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -14,
                                    right: -14,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                      onPressed: () {
                                        setState(() {
                                          selectedProducts.remove(product); // Remove product from list
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Submit button section
                      if (selectedProducts.isNotEmpty)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.customeBlue,
                          ),
                          onPressed: () async {
                            try {
                              final token = SharedPrefs.getString('token');
                              print(token.toString());
                              if (token == null) {
                                ErrorDialog.showErrorDialog(context, 401, 'Authentication token is missing. Please log in again.');
                                return;
                              }
                              final itemType = selectedCodeType == "Box Code" ? "box" : "product";
                              String? actionUrl;
                              if (selectedAction == "Drop off") {
                                actionUrl = "/api/create-dropoff/";
                              } else if (selectedAction == "Return") {
                                actionUrl = "/api/initiate-return/";
                              } else if (selectedAction == "Inventory") {
                                actionUrl = "/api/take-inventory/";
                              } else {
                                ErrorDialog.showErrorDialog(context, 400, 'Invalid action selected.');
                                return;
                              }
                              final payload = {
                                "driver_id": SharedPrefs.getString('driver_id'),
                                "store_id": '6',
                                "items": selectedProducts.join(","),
                                "item_type": itemType,
                              };
                              final response = await ApiClient().postActions(payload, token, actionUrl, context);
                              if (response != null) {
                                print("Action completed successfully: ${response.toString()}");
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final parsedResponse = response is String ? jsonDecode(response) : response;

                                    final successfullyAdded = parsedResponse['successfully_added'] as List;
                                    final errors = parsedResponse['errors'] as List;
                                    final totalProductsAdded = parsedResponse['total_products_added'];
                                    final totalErrors = parsedResponse['total_errors'];

                                    return AlertDialog(
                                      backgroundColor: CustomColors.navyBlue.withOpacity(.7),
                                      title: const Text(
                                        'Action Completed',
                                        style: TextStyle(
                                          color: CustomColors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (successfullyAdded.isNotEmpty) ...[
                                              const Text(
                                                'Successfully Added:',
                                                style: TextStyle(
                                                  color: CustomColors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              ...successfullyAdded.map(
                                                    (item) => Text(
                                                  '- $item',
                                                  style: const TextStyle(color: CustomColors.white, fontSize: 16),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                            if (errors.isNotEmpty) ...[
                                              const Text(
                                                'Errors:',
                                                style: TextStyle(
                                                  color: CustomColors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              ...errors.map(
                                                    (error) => Text(
                                                  '- ${error['item_code']}: ${error['error']}',
                                                  style: const TextStyle(color: CustomColors.white, fontSize: 16),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                            const Divider(color: CustomColors.white),
                                            Text(
                                              'Total Products Added: $totalProductsAdded',
                                              style: const TextStyle(color: CustomColors.white, fontSize: 18),
                                            ),
                                            Text(
                                              'Total Errors: $totalErrors',
                                              style: const TextStyle(color: CustomColors.white, fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'OK',
                                            style: TextStyle(
                                              color: CustomColors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              print('Error during action: $e');
                              ErrorDialog.showErrorDialog(context, 500, 'An unexpected error occurred. Please try again.');
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }


  @override
  void dispose() {
    _controller.dispose();
    productCodeController.dispose();
    super.dispose();
  }
}
