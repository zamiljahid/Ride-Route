
import 'package:delivary/constants/custome_colors/custome_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String? version;

  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  void initState() {

    super.initState();


    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));

    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
    ]).animate(_controller);
    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomRight, end: Alignment.bottomLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.bottomLeft, end: Alignment.topLeft),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topLeft, end: Alignment.topRight),
          weight: 1),
      TweenSequenceItem<Alignment>(
          tween: Tween<Alignment>(
              begin: Alignment.topRight, end: Alignment.bottomRight),
          weight: 1),
    ]).animate(_controller);

    _controller.repeat();
  }



  String? token;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
              width: double.infinity,
              height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      CustomColors.navyBlue,
                      CustomColors.customeBlue
                    ],
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value)),
            child: Center(child: Text("hello", style: TextStyle(color: CustomColors.goldenSolid, fontSize: 80),))
          );
        },
      ),



      // FutureBuilder(
      //   future: Future.delayed(const Duration(seconds: 4)),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return AnimatedBuilder(
      //         animation: _controller,
      //         builder: (context, _) {
      //           return Container(
      //             decoration: BoxDecoration(
      //                 gradient: LinearGradient(
      //                     colors: [
      //                       CustomColors.navyBlue,
      //                       CustomColors.royalBlue
      //                     ],
      //                     begin: _topAlignmentAnimation.value,
      //                     end: _bottomAlignmentAnimation.value)),
      //             child: const Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //               ],
      //             ),
      //           );
      //         },
      //       );
      //     }
      //     return Builder(builder: (context) {
      //      return DashboardScreen();
      //     });
      //   },
      // ),
    );
  }
}
