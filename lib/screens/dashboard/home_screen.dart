import 'package:delivary/screens/dashboard/model/cash_flow_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../api/api_client.dart';
import '../../constants/custome_colors/custome_colors.dart';
import '../../fcm_service.dart';
import '../../location.dart';
import '../../shared_preference.dart';
import 'model/pending_store_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PendingStoreModel> pendingStores = [];
  CashFlowModel? cashFlowData;
  FCMService fcmService = FCMService();
  LocationService locationService = LocationService();
  late Future<void> _loadDataFuture;


  String? pos, cash;

  @override
  void initState() {
    super.initState();
    fcmService.initialize(SharedPrefs.getString('driver_id').toString(),
        SharedPrefs.getString('token').toString());
    getLocationAndUpdate();
    _loadDataFuture = loadInitialData();
  }

  Future<void> getLocationAndUpdate() async {
    Position position = await locationService.getCurrentLocation();
    await locationService.sendLocationToBackend(
        position,
        SharedPrefs.getString('driver_id').toString(),
        SharedPrefs.getString('token').toString());
  }

  Future<void> loadInitialData() async {
    final String? token = SharedPrefs.getString('token');
    final String driverId =
        "?driver=${SharedPrefs.getString('driver_id').toString()}";
    const String status = "&status=pending&created_at=";
    final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (token == null) {
      print("Token not found");
      return;
    }

    try {
      CashFlowModel? fetchedCashFlow = await ApiClient().getCashFlow(token);
      if (fetchedCashFlow != null) {
        setState(() {
          cashFlowData = fetchedCashFlow;
          pos = cashFlowData?.pos;
          cash = cashFlowData?.cash;
        });
      } else {
        print("Failed to fetch cash flow data.");
      }

      List<PendingStoreModel> fetchedPendingStores = await ApiClient().getPendingStores(token, driverId, status, date);
      print("Fetched Pending Stores: ${fetchedPendingStores.length}");

      setState(() {
        pendingStores = fetchedPendingStores;
      });
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getTotalCashFlow() {
    final int cashValue = int.tryParse(cash ?? "0") ?? 0;
    final int posValue = int.tryParse(pos ?? "0") ?? 0;

    return (cashValue + posValue).toString();
  }

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CustomColors.navyBlue.withOpacity(.8),
          title: Text(
            'Confirm Delivery',
            style: TextStyle(color: CustomColors.white),
          ),
          content: Text(
            'Are you sure you want to mark this product as delivered?',
            style: TextStyle(color: CustomColors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if cancelled
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: CustomColors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
              child: Text(
                'Confirm',
                style: TextStyle(color: CustomColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: CustomColors.customeBlue,
                    boxShadow: const [
                      BoxShadow(
                          color: CustomColors.navyBlue,
                          offset: Offset(4.0, 4.0),
                          blurRadius: 15.0,
                          spreadRadius: 1.0),
                      BoxShadow(
                          color: CustomColors.navyBlue,
                          offset: Offset(-4.0, -4.0),
                          blurRadius: 15.0,
                          spreadRadius: 1.0),
                    ]),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Cash Received',
                          style: TextStyle(
                              color: CustomColors.white,
                              fontFamily: 'Rowdies',
                              fontSize: 16)),
                      Text(
                        "${_getTotalCashFlow()} BDT",
                        style: const TextStyle(
                          color: CustomColors.white,
                          fontFamily: 'Rowdies',
                          fontSize: 40,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CustomColors.navyBlue,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.wallet,
                                      color: CustomColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Text((pos?.toString() ?? '0'),
                                        style: const TextStyle(
                                            color: CustomColors.white,
                                            fontFamily: 'Rowdies',
                                            fontWeight: FontWeight.bold)),
                                    const Text('POS',
                                        style: TextStyle(
                                            color: CustomColors.white,
                                            fontFamily: 'Rowdies',
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CustomColors.navyBlue,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.monetization_on_sharp,
                                      color: CustomColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Text((cash?.toString() ?? '0'),
                                        style: const TextStyle(
                                            color: CustomColors.white,
                                            fontFamily: 'Rowdies',
                                            fontWeight: FontWeight.bold)),
                                    const Text('Cash',
                                        style: TextStyle(
                                            color: CustomColors.white,
                                            fontFamily: 'Rowdies',
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: _loadDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Rowdies',
                        ),
                      ),
                    );
                  } else if (pendingStores.isEmpty) {
                    return Center(
                      child: Text(
                        "No Pending Request Available",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Rowdies',
                        ),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: pendingStores.length,
                      itemBuilder: (context, index) {
                        final store = pendingStores[index];
                        return Card(
                          color: CustomColors.blue,
                          child: ExpansionTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: ${store.status}',
                                  style: const TextStyle(
                                      color: Colors.white, fontFamily: 'Rowdies'),
                                ),
                                Text(
                                  'Date: ${store.createdAt}',
                                  style: const TextStyle(
                                      color: Colors.white, fontFamily: 'Rowdies'),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              'Products: ${store.products.length}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            children: [
                              Text(
                                'Products',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              for (var productId in store.products)
                                ListTile(
                                  title: Text(
                                    '$productId',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ListTile(
                                title: ElevatedButton(
                                  onPressed: () async {
                                    print("Marked as Delivered for store ${store.id}");

                                    bool? isConfirmed = await showConfirmationDialog(context);

                                    if (isConfirmed == true) {
                                      final String? token = SharedPrefs.getString('token');
                                      if (token == null) {
                                        print("Token not found");
                                        return;
                                      }

                                      final String productId = store.id.toString();
                                      final Map<String, String> payload = {
                                        "status": "completed",
                                      };

                                      var response = await ApiClient().patchStoreStatus(payload, token, productId, context);
                                      if (response != null) {
                                        loadInitialData();  // Reload data after successful update
                                      }
                                    }
                                  },
                                  child: Text(
                                    'Delivered',
                                    style: TextStyle(color: CustomColors.navyBlue),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
