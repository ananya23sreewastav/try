import 'package:flutter/material.dart';
import 'login.dart';
import 'sign.dart';
import 'first.dart';
import 'user.dart';
import 'planner.dart'; // Importing the Planner page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainSwipe App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => LoginPage(), // Route for login page
        '/sign': (context) => SignPage(), // Route for sign up page
        '/first': (context) => FirstPage(), // Route for first page
        '/user': (context) => UserPage(), // Route for user page
        '/planner': (context) => PlannerPage(), // Route for planner page
      },
    );
  }
}
