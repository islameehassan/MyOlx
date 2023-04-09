import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myolx/Screens/BrandsScreen.dart';
import 'package:myolx/components/roundedbutton.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:myolx/Screens/SignUpScreen.dart';
import 'package:myolx/components/myTextField.dart';


// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const id = 'LoginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final DatabaseManager databaseManager;
  late String emailAddress;
  late String password;
  late String message;
  late bool loadingSpinner;

  @override
  void initState(){
    super.initState();
    databaseManager = DatabaseManager();
    emailAddress = "";
    password = "";
    message = "";
    loadingSpinner = false;
  }

  Future<void> logOnDatabase() async{
    String tempMessage = "";

    setState(() {
      loadingSpinner = true;
      message = "";
    });

    if(emailAddress.isEmpty) {
      tempMessage = "Please enter your email address";
    }
    else if(password.isEmpty){
      tempMessage = "Please enter your password";
    }
    else if(RegExp(r"^\w+@\w+\.\w+$").hasMatch(emailAddress) == false
        && RegExp(r"^\w+@\w+\.\w+\.\w+$").hasMatch(emailAddress) == false){
      tempMessage = "Please enter a valid email address";
    }
    else{
      String loginMessage = await databaseManager.authenticateUser(emailAddress, password);
      if(loginMessage == "Success"){
        Navigator.pushNamed(context, LoginScreen.id);
          // TODO: Navigate to the home screen and pass the user's email address and then remove the email address and password from the state
      }
      else{
          tempMessage = loginMessage;
          emailAddress = "";
          password = "";
      }
    }
    setState(() {
      loadingSpinner = false;
      message = tempMessage;
    });
  }

  @override
  void dispose(){
    super.dispose();
    databaseManager.closeConnection();
    emailAddress = "";
    password = "";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: loadingSpinner,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
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
                      "$message",
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
                        Navigator.pushNamed(context, BrandsScreen.id);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
