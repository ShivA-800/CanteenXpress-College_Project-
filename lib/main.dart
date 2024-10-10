import 'package:flutter/material.dart';
import 'package:online_food_order_app/screens/landingPage.dart';
import 'package:provider/provider.dart';
import 'notifiers/authNotifier.dart';

// void main() {
//   runApp(MyApp());
// }

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AuthNotifier(),
      ),
      // ChangeNotifierProvider(
      //   create: (_) => FoodNotifier(),
      // ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CanteeXpress',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primaryColor: const Color.fromRGBO(255, 63, 111, 1),
      ),
      home: const Scaffold(
        body: LandingPage(),
      ),
    );
  }
}
