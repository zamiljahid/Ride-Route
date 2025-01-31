import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_echart/flutter_echart.dart';

import '../../api/api_client.dart';
import '../../shared_preference.dart';
import 'model/cash_flow_model.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String? pos, cash, delivered, returned;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }
  Future<void> loadUserData() async {
    final String? token = SharedPrefs.getString('token');
    if (token != null) {
      CashFlowModel? fetchedCashFlow = await ApiClient().getCashFlow(token);
      if (fetchedCashFlow != null) {
        setState(() {
          pos = fetchedCashFlow.pos;
          cash = fetchedCashFlow.cash;
          delivered = fetchedCashFlow.deliveredParcel;
          returned = fetchedCashFlow.returnedParcel;
          isLoading = false;  // Data loaded, stop loading indicator
        });
      } else {
        print("Failed to fetch cash flow data.");
        setState(() {
          isLoading = false;  // Even on failure, stop loading indicator
        });
      }
    } else {
      print("User ID or Token not found in SharedPreferences.");
      setState(() {
        isLoading = false;  // Stop loading if token is not found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disables the default back arrow
        backgroundColor: Colors.white,
        title: const Text(
          'G R A P H',
          style: TextStyle(
            fontFamily: 'Rowdies',
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading  // Show loading indicator while data is loading
          ? Center(child: CircularProgressIndicator())
          : (pos == null || cash == null || delivered == null || returned == null)  // Check if any data is null
          ? Center(child: Text('No data to display', style: TextStyle(fontSize: 16, color: Colors.black)))
          : Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0), // Adjust padding as needed
              child: PieChatWidget(
                dataList: [
                  EChartPieBean(
                    title: "Completed Delivery",
                    number: int.parse(delivered!),
                    color: Colors.purple,
                  ),
                  EChartPieBean(
                    title: "Returned Parcel",
                    number: int.parse(returned!),
                    color: Colors.pink,
                  ),
                ],
                isLog: false,
                isBackground: true,
                isLineText: true,
                bgColor: Colors.white,
                isFrontgText: true,
                initSelect: 1,
                openType: OpenType.ANI,
                loopType: LoopType.AUTO_LOOP,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0), // Adjust padding as needed
              child: PieChatWidget(
                dataList: [
                  EChartPieBean(
                    title: "Cash Collected",
                    number: int.parse(cash!),
                    color: Colors.blueAccent,
                  ),
                  EChartPieBean(
                    title: "POS",
                    number: int.parse(pos!),
                    color: CustomColors.customeBlue,
                  ),
                ],
                isLog: false,
                isBackground: true,
                isLineText: true,
                bgColor: Colors.white,
                isFrontgText: true,
                initSelect: 2,
                openType: OpenType.ANI,
                loopType: LoopType.AUTO_LOOP,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
