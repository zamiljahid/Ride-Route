import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:delivary/screens/dashboard/model/profile_model.dart';
import 'package:delivary/screens/dashboard/profile_screen.dart';
import 'package:delivary/screens/dashboard/map_screen.dart';
import 'package:flutter/material.dart';
import 'qr_scan.dart';
import 'graph_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
final items = <Widget>[
  const Icon(Icons.auto_graph, size: 30, color: Colors.white),

  const Icon(Icons.add, size: 30, color: Colors.white),
  const Icon(
    Icons.home,
    size: 30,
    color: Colors.white,
  ),
  const Icon(Icons.map, size: 30, color: Colors.white),
  const Icon(Icons.person, size: 30, color: Colors.white),
];

class _DashboardScreenState extends State<DashboardScreen> {
  int index = 2;
  ProfileModel? user;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final screen = [
       GraphScreen(),
      const QRScreen(),
       HomeScreen(),
      const MapScreen(),
       ProfileScreen(),
    ];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.white,
      body: screen[index],
      bottomNavigationBar: Container(
          height: 75,
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            child: CurvedNavigationBar(
              index: index,
              height: 60,
              color: CustomColors.blue,
              buttonBackgroundColor: CustomColors.blue,
              backgroundColor: CustomColors.customeBlue,
              animationDuration: const Duration(milliseconds: 300),
              items: items,
              onTap: (index) => setState(() => this.index = index),
            ),
          )),
    );
  }
}
