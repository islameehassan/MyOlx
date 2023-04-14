import 'package:flutter/material.dart';
import 'package:myolx/Screens/AreasScreen.dart';
import 'package:myolx/Screens/LoginScreen.dart';
import 'package:myolx/Screens/SignUpScreen.dart';
import 'package:myolx/Screens/BrandsScreen.dart';
import 'package:myolx/Screens/HomeScreen.dart';
import 'package:myolx/Screens/AreasScreen.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
// ignore_for_file: prefer_const_constructors

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyOLX',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.redAccent,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all(Colors.black),
        ),
      ),
      initialRoute: BrandsScreen.id,
      routes: {
        LoginScreen.id: (context)=> const LoginScreen(),
        SignUpScreen.id: (context)=> const SignUpScreen(),
        BrandsScreen.id: (context)=> BrandsScreen(databaseManager: DatabaseManager(), brandModels: const {}),
        HomeScreen.id : (context)=>  HomeScreen(databaseManager: DatabaseManager()),
        AreaScreen.id : (context)=>  AreaScreen(databaseManager: DatabaseManager()),
      },
    );
  }
}