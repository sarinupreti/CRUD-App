import 'package:flutter/material.dart';
import 'task.dart';
import 'register.dart';
import 'splash.dart';
import 'login.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        /// title of the project
        title: 'Flutter Demo',

        /// main theme for of the project.
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),

        /// initial page which opens after the app is runned. Splash screen is passed in the home parameters
        home: SplashPage(),

        /// routes for different screens in the applications
        routes: <String, WidgetBuilder>{
          '/task': (BuildContext context) => TaskPage(title: 'Task'),
          '/home': (BuildContext context) => HomePage(title: 'Home'),
          '/login': (BuildContext context) => LoginPage(),
          '/register': (BuildContext context) => RegisterPage(),
        });
  }
}
