import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:delivary/screens/dashboard/home_screen.dart';
import 'package:delivary/screens/splash%20screen/splash_screen.dart';
import 'package:delivary/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'fcm_service.dart';
import 'firebase_options.dart';
import 'location.dart';

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    print('Location permissions are permanently denied.');
  } else if (permission == LocationPermission.denied) {
    print('Location permissions are denied.');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestLocationPermission();
  await SharedPrefs.init();

  // Initialize Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logAppOpen();  // Log app open event

  runApp(const ProviderScope(child: MainClass()));
}

class MainClass extends StatefulWidget {
  const MainClass({Key? key}) : super(key: key);

  @override
  MainClassState createState() => MainClassState();
}

class MainClassState extends State<MainClass> {
  FCMService fcmService = FCMService();
  LocationService locationService = LocationService();

  // Firebase Analytics instance
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    final driverId = SharedPrefs.getString('driver_id') ?? '0';
    final token = SharedPrefs.getString('token') ?? '0';

    analytics.logEvent(
      name: 'app_initialized',
      parameters: <String, Object>{
        'driver_id': driverId,
        'token': token,
      },
    );

    fcmService.initialize(driverId, token);

    LocationService().startLocationUpdates(driverId, token);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: FCMService.navigatorKey, // Set the navigator key for navigation
      home: const SplashScreen(), // Set your initial screen
      routes: {
        '/home': (context) => HomeScreen(), // Define routes
      },
    );
  }
}
