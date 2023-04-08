import 'package:flutter/material.dart';
import 'package:myolx/Screens/LoginScreen.dart';
import 'package:myolx/Screens/SignUpScreen.dart';
import 'package:myolx/constants.dart';
import 'package:myolx/components/roundedbutton.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

class WelcomeScreen extends StatelessWidget {
  static const id = 'WelcomeScreen';

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "MyOLX",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 80,
                      fontFamily: 'weasthood',
                      fontWeight: FontWeight.w900,
                    ),
                    ),
                  Text(
                    "Shop your favourite cars with us",
                    style: TextStyle(
                      color: Color(0xFFB6B6B6),
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Hero(
                tag: 'logo',
                child: Image(
                  image: AssetImage('assets/images/logo.jpeg'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RoundedButton(
                      text: "LOGIN",
                      press: () {
                        Navigator.pushNamed(context, LoginScreen.id);
                      },
                    ),
                    RoundedButton(
                      text: "SIGN UP",
                      press: () {
                        Navigator.pushNamed(context, SignUpScreen.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
