import 'package:flutter/material.dart';
import 'package:myolx/Screens/LoginScreen.dart';
import 'package:myolx/Screens/SignUpScreen.dart';
import 'package:myolx/Screens/BrandsScreen.dart';
// ignore_for_file: prefer_const_constructors

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: LoginScreen.id,
      routes: {
        LoginScreen.id: (context)=> const LoginScreen(),
        SignUpScreen.id: (context)=> const SignUpScreen(),
        Brands.id: (context)=> const Brands(username: "", brandModels: {}),
      },
    );
  }
}