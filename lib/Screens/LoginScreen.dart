import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myolx/Components/loading.dart';
import 'package:myolx/Components/roundedButton.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'SignUpScreen.dart';
import 'HomeScreen.dart';
import 'package:myolx/Components/myTextField.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: use_build_context_synchronously

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const id = 'LoginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DatabaseManager databaseManager = DatabaseManager();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  String emailAddress = "";
  String password = "";
  String message = "";
  bool loadingSpinner = false;

  Future<void> logOnDatabase() async {
    String tempMessage = "";

    setState(() {
      loadingSpinner = true;
      message = "";
    });

    if (emailAddress.isEmpty) {
      tempMessage = "Please enter your email address";
    } else if (password.isEmpty) {
      tempMessage = "Please enter your password";
    } else if (RegExp(r"^\w+@\w+\.\w+$").hasMatch(emailAddress) == false &&
        RegExp(r"^\w+@\w+\.\w+\.\w+$").hasMatch(emailAddress) == false) {
      tempMessage = "Please enter a valid email address";
    } else {
      String loginMessage =
          await databaseManager.authenticateUser(emailAddress, password);
      if (loginMessage == "Success") {
        await databaseManager.getBrands();
        await databaseManager.getLocations();
        await databaseManager.getExtraFeatures();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(databaseManager: databaseManager),
          ),
        );
        emailAddressController.clear();
        passwordController.clear();
      } else {
        tempMessage = loginMessage;
        if(tempMessage == 'Email Address Not Found'){
          emailAddressController.clear();
        }
        passwordController.clear();
      }
    }
    setState(() {
      loadingSpinner = false;
      message = tempMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
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
                        Hero(
                          tag: 'logo',
                          child: Container(
                            height: 150,
                            child: Image.asset('assets/images/logo.jpeg'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        myTextField(
                          controller: emailAddressController,
                          obscureText: false,
                          hintText: 'Enter your email address',
                          onChanged: (value) {
                            emailAddress = value;
                          },
                          icon: Icons.email_outlined,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        myTextField(
                          controller: passwordController,
                          obscureText: true,
                          hintText: 'Enter your password',
                          onChanged: (value) {
                            password = value;
                          },
                          icon: Icons.lock_outline,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Text(
                          message,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Pacifico',
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        RoundedButton(
                          text: "LOGIN",
                          press: () async {
                            await logOnDatabase();
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
                ],
              ),
              // add blur effect to the background when loading
              loadingSpinner
                  ? loading()
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
