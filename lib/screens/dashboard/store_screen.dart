import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
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
  String? qrCode, selectedCodeType,selectedMethodType;
  bool isQR = false;
  bool isMenuOpen = false;
  late AnimationController _controller;
  List<String> selectedProducts = [];
  TextEditingController productCodeController = TextEditingController();
  late Animation<double> _animation;
  Store? storeData;
  bool isLoading = false;
  bool isDownloading = false;

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

  Future<void> _scanBarcode() async {
    var result = await BarcodeScanner.scan();
    if (result.rawContent.isNotEmpty) {
      setState(() {
        selectedProducts
            .add(result.rawContent);
      });
    }
  }
  // void downloadAndOpenPdf(BuildContext context, String pdfUrl) async {
  //   try {
  //     Directory appDocDir = await getApplicationDocumentsDirectory();
  //     String fileName = pdfUrl.split('/').last;
  //     String filePath = '${appDocDir.path}/$fileName';
  //
  //     FileDownloader.downloadFile(
  //       url: pdfUrl,
  //       name: fileName,
  //       onDownloadCompleted: (String path) {
  //         print("Downloaded Path: $path");
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text("Download completed! Opening PDF..."),
  //             duration: Duration(seconds: 2),
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //
  //         showPdfDialog(context, filePath);
  //       },
  //       onDownloadError: (String error) {
  //         print('Download error: $error');
  //
  //         // Show Snackbar on Download Error
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text("Download failed: $error"),
  //             backgroundColor: Colors.red,
  //             duration: Duration(seconds: 3),
  //             behavior: SnackBarBehavior.floating,
  //           ),
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     print("Error downloading file: $e");
  //   }
  // }

  void showPdfDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Invoice PDF"),
          content: Container(
            height: 400,
            child: PDFView(
              filePath: filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageSnap: true,
              fitPolicy: FitPolicy.BOTH,
              onError: (error) {
                print("PDF Error: $error");
              },
              onRender: (_pages) {
                print("PDF Rendered: $_pages pages");
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
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
                                                selectedProducts.clear();
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
                                                selectedProducts.clear();
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
                                                selectedProducts.clear();
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
                                          selectedProducts.clear();
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
                                          selectedProducts.clear();
                                          selectedCodeType = value!;
                                        });
                                      },
                                    ),
                                    const Text("Product Code"),
                                  ],
                                ),
                                if (selectedAction == "Drop off" && selectedCodeType != null)
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      activeColor: CustomColors.customeBlue,
                                      value: "CASH",
                                      groupValue: selectedMethodType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedProducts.clear();
                                          selectedMethodType = value!;
                                        });
                                      },
                                    ),
                                    const Text("CASH"),
                                    const SizedBox(width: 20),
                                    Radio<String>(
                                      activeColor: CustomColors.customeBlue,
                                      value: "POS",
                                      groupValue: selectedMethodType,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedProducts.clear();
                                          selectedMethodType = value!;
                                        });
                                      },
                                    ),
                                    const Text("POS"),
                                  ],
                                ),
                                if (selectedCodeType!= null)
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
                                          icon: const Icon(Icons.camera_alt,
                                              color: Colors.white),
                                          onPressed:
                                              _scanBarcode, // Trigger the barcode scan when pressed
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: const BorderSide(
                                                  color: Colors.white),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.check,
                                                  color: Colors.white),
                                              onPressed: () async {
                                                String productCode =
                                                    productCodeController.text
                                                        .trim();
                                                if (productCode.isNotEmpty) {
                                                  setState(() {
                                                    selectedProducts.add(
                                                        productCode); // Add product to list
                                                  });
                                                  productCodeController
                                                      .clear(); // Clear input field
                                                } else {
                                                  print(
                                                      'No product code entered');
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
                                              padding:
                                                  const EdgeInsets.all(20.0),
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
                                                icon: const Icon(Icons.close,
                                                    color: Colors.white,
                                                    size: 16),
                                                onPressed: () {
                                                  setState(() {
                                                    selectedProducts.remove(
                                                        product);
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
                                if (selectedProducts.isNotEmpty)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CustomColors.customeBlue,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            try {
                                              setState(() {
                                                isLoading =
                                                    true;
                                              });

                                              final token =
                                                  SharedPrefs.getString(
                                                      'token');
                                              print(token.toString());
                                              if (token == null) {
                                                ErrorDialog.showErrorDialog(
                                                    context,
                                                    401,
                                                    'Authentication token is missing. Please log in again.');
                                                return;
                                              }
                                              final itemType =
                                                  selectedCodeType == "Box Code"
                                                      ? "box"
                                                      : "product";
                                              String? actionUrl;
                                              if (selectedAction ==
                                                  "Drop off") {
                                                actionUrl =
                                                    "/api/create-dropoff/";
                                              } else if (selectedAction ==
                                                  "Return") {
                                                actionUrl =
                                                    "/api/initiate-return/";
                                              } else if (selectedAction ==
                                                  "Inventory") {
                                                actionUrl =
                                                    "/api/take-inventory/";
                                              } else {
                                                ErrorDialog.showErrorDialog(
                                                    context,
                                                    400,
                                                    'Invalid action selected.');
                                                return;
                                              }
                                              final payload = {
                                                "driver_id": SharedPrefs.getString('driver_id'),
                                                "store_id": widget.storeData?.id,
                                                "items": selectedProducts,
                                                "item_type": itemType,
                                                if (selectedAction == "Drop off")
                                                  "method_of_collection": selectedMethodType.toString(),
                                              };
                                              print(jsonEncode(payload)
                                                  .toString());
                                              final response = await ApiClient()
                                                  .postActions(payload, token,
                                                      actionUrl, context);
                                              setState(() {
                                                isLoading =
                                                    false;
                                              });
                                              if (response != null) {
                                                print("Action completed successfully: ${response.toString()}");
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    final parsedResponse =
                                                    response is String ? jsonDecode(response) : response;
                                                    List successfullyMatched = [];
                                                    List successfullyUpdated = [];
                                                    List successfullyAdded = [];
                                                    List missingProducts = [];
                                                    List errors = [];
                                                    int totalProductsMatched = 0;
                                                    int totalProductsUpdated = 0;
                                                    int totalProductsAdded = 0;
                                                    int totalMissingProducts = 0;
                                                    int totalErrors = 0;
                                                    String actionTitle = 'Action Completed';
                                                    if (parsedResponse.containsKey('successfully_matched')) {
                                                      successfullyMatched = parsedResponse['successfully_matched'] ?? [];
                                                      missingProducts = parsedResponse['missing_products_marked_as_sold'] ?? [];
                                                      errors = parsedResponse['errors'] ?? [];
                                                      totalProductsMatched = parsedResponse['total_products_matched'] ?? 0;
                                                      totalMissingProducts = parsedResponse['total_missing_products'] ?? 0;
                                                      totalErrors = parsedResponse['total_errors'] ?? 0;
                                                      actionTitle = 'Take Inventory Action Completed';
                                                    }
                                                    else if (parsedResponse.containsKey('successfully_updated')) {
                                                      successfullyUpdated = parsedResponse['successfully_updated'] ?? [];
                                                      errors = parsedResponse['errors'] ?? [];
                                                      totalProductsUpdated = parsedResponse['total_products_updated'] ?? 0;
                                                      totalErrors = parsedResponse['total_errors'] ?? 0;
                                                      actionTitle = 'Initiate Return Action Completed';
                                                    }
                                                    else if (parsedResponse.containsKey('successfully_added')) {
                                                      successfullyAdded = parsedResponse['successfully_added'] ?? [];
                                                      errors = parsedResponse['errors'] ?? [];
                                                      totalProductsAdded = parsedResponse['total_products_added'] ?? 0;
                                                      totalErrors = parsedResponse['total_errors'] ?? 0;
                                                      actionTitle = 'Create Dropoff Action Completed';
                                                    }
                                                    return AlertDialog(

                                                      backgroundColor: CustomColors.navyBlue.withOpacity(.7),
                                                      title: Text(
                                                        actionTitle,
                                                        style: const TextStyle(
                                                          color: CustomColors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                      content: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            if (successfullyMatched.isNotEmpty) ...[
                                                              const Text(
                                                                'Successfully Matched:',
                                                                style: TextStyle(
                                                                  color: CustomColors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              ...successfullyMatched.map(
                                                                    (item) => Text(
                                                                  '- $item',
                                                                  style: const TextStyle(color: CustomColors.white, fontSize: 16),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10),
                                                            ],
                                                            if (successfullyUpdated.isNotEmpty) ...[
                                                              const Text(
                                                                'Successfully Updated:',
                                                                style: TextStyle(
                                                                  color: CustomColors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              ...successfullyUpdated.map(
                                                                    (item) => Text(
                                                                  '- $item',
                                                                  style: const TextStyle(color: CustomColors.white, fontSize: 16),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10),
                                                            ],
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
                                                            if (missingProducts.isNotEmpty) ...[
                                                              const Text(
                                                                'Missing Products Marked as Sold:',
                                                                style: TextStyle(
                                                                  color: CustomColors.white,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                              ...missingProducts.map(
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
                                                                  '- ${error['item_code'] ?? ''}: ${error['error'] ?? ''}',
                                                                  style: const TextStyle(color: CustomColors.white, fontSize: 16),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10),
                                                            ],
                                                            const Divider(color: CustomColors.white),
                                                            if (totalProductsMatched > 0) ...[
                                                              Text(
                                                                'Total Products Matched: $totalProductsMatched',
                                                                style: const TextStyle(color: CustomColors.white, fontSize: 18),
                                                              ),
                                                            ],
                                                            if (totalMissingProducts > 0) ...[
                                                              Text(
                                                                'Total Missing Products: $totalMissingProducts',
                                                                style: const TextStyle(color: CustomColors.white, fontSize: 18),
                                                              ),
                                                            ],
                                                            if (totalProductsUpdated > 0) ...[
                                                              Text(
                                                                'Total Products Updated: $totalProductsUpdated',
                                                                style: const TextStyle(color: CustomColors.white, fontSize: 18),
                                                              ),
                                                            ],
                                                            if (totalProductsAdded > 0) ...[
                                                              Text(
                                                                'Total Products Added: $totalProductsAdded',
                                                                style: const TextStyle(color: CustomColors.white, fontSize: 18),
                                                              ),
                                                            ],
                                                            Text(
                                                              'Total Errors: $totalErrors',
                                                              style: const TextStyle(color: CustomColors.white, fontSize: 18),
                                                            ),
                                                            if (parsedResponse.containsKey('small_invoice') && parsedResponse['small_invoice'] != null) ...[
                                                              const SizedBox(height: 10),
                                                            Center(
                                                              child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: CustomColors.customeBlue,
                                                                ),
                                                                onPressed: isDownloading ? null : () async {
                                                                  // String pdfUrl = "https://logicgate99.pythonanywhere.com/media/invoices/invoice_759cc2c9-fc4e-4dc7-9916-dcceafc5d976_48gSVs0.pdf";
                                                                  String pdfUrl = "https://logicgate99.pythonanywhere.com${parsedResponse['small_invoice']}";
                                                                  Directory appDocDir = await getApplicationDocumentsDirectory();
                                                                  String fileName = pdfUrl.split('/').last;
                                                                  String filePath = '${appDocDir.path}/$fileName';

                                                                  setState(() {
                                                                    isDownloading = true;
                                                                  });

                                                                  try {
                                                                    FileDownloader.downloadFile(
                                                                      url: pdfUrl,
                                                                      name: fileName,
                                                                      onDownloadCompleted: (String path) {
                                                                        Navigator.pop(context);
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text("Invoice Downloaded in your Device"),
                                                                            duration: Duration(seconds: 2),
                                                                            behavior: SnackBarBehavior.floating,
                                                                          ),
                                                                        );
                                                                        setState(() {
                                                                          isDownloading = false;
                                                                        });
                                                                      },
                                                                      onDownloadError: (String error) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text("Download failed: $error"),
                                                                            backgroundColor: Colors.red,
                                                                            duration: Duration(seconds: 3),
                                                                            behavior: SnackBarBehavior.floating,
                                                                          ),
                                                                        );
                                                                        setState(() {
                                                                          isDownloading = false;
                                                                        });
                                                                      },
                                                                    );
                                                                  } catch (e) {
                                                                    print("Error downloading file: $e");
                                                                    setState(() {
                                                                      isDownloading = false;
                                                                    });
                                                                  }
                                                                },
                                                                child: isDownloading
                                                                    ? SizedBox(
                                                                  width: 20, height: 20,
                                                                  child: CircularProgressIndicator(
                                                                    strokeWidth: 2,
                                                                    color: Colors.white,
                                                                  ),
                                                                )
                                                                    : Text('Download Invoice',style:
                                                                TextStyle(color: Colors.white),),
                                                              ),
                                                            ),
                                                           ],
                                                            if (parsedResponse.containsKey('small_invoice') && parsedResponse['small_invoice'] == null) ...[
                                                              const SizedBox(height: 10),
                                                              Center(
                                                                child: ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: CustomColors.customeBlue,
                                                                  ),
                                                                  onPressed:()  {
                                                                    Navigator.pop(context);
                                                                  },
                                                                  child: Text('Done',style:
                                                                  TextStyle(color: Colors.white),),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            } catch (e) {
                                              setState(() {
                                                isLoading =
                                                    false;
                                              });
                                              print('Error during action: $e');
                                              ErrorDialog.showErrorDialog(
                                                  context,
                                                  500,
                                                  'An unexpected error occurred. Please try again.');
                                            }
                                          },
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                     color:  Colors.black
                                    )
                                        : const Text(
                                            'Submit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  )
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
