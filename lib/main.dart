import 'package:flutter/material.dart';
import 'package:Hope/pages/landing_page.dart';

void main() => runApp(MyApp());

const APIKEY = 'APIKEY'; // Add your API KEY Here

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project Hope',
      home: LandingPage(),
    );
  }
}
