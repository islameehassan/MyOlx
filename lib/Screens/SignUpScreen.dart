import 'package:flutter/material.dart';
import 'package:myolx/Screens/BrandsScreen.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:myolx/Components/myTextField.dart';
import 'package:myolx/constants.dart';
import 'package:myolx/Components/roundedbutton.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);
  static const id = 'SignUp';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final DatabaseManager databaseManager = DatabaseManager();
  String emailAddress = "";
  String username = "";
  String password = "";
  String gender = "Female";
  DateTime birthdate = DateTime.now();
  String message = "";
  bool loadingSpinner = false;


  void birthDatePicker() {
    showDatePicker(
        context: context,
        initialDate: birthdate,
        //which date will display when user open the picker
        firstDate: DateTime(1950),
        //what will be the previous supported year in picker
        lastDate: DateTime
            .now()) //what will be the up to supported date in picker
        .then((pickedDate) {
      //then usually do the future job
      if (pickedDate == null) {
        //if user tap cancel then this function will stop
        return;
      }
      setState(() {
        //for rebuilding the ui
        birthdate = pickedDate;
      });
    });
  }

  Future<void> validateUser() async{
    // Validate if the user already exists in the database (assumption is that the email address is unique)
    // If the user exists, then display a message to the user
    String tempMessage = "";
    setState(() {
      loadingSpinner = true;
      message = "";
    });
    tempMessage = await databaseManager.checkIfUserExists(emailAddress);
    if(tempMessage == "Found") {
      tempMessage = "User already exists";
    }
    else if(emailAddress.isEmpty){
      tempMessage = "Please enter an email address";
    }
    else if(RegExp(r"^\w+@\w+\.\w+$").hasMatch(emailAddress) == false
        && RegExp(r"^\w+@\w+\.\w+\.\w+$").hasMatch(emailAddress) == false)
    {
      tempMessage = "Please enter a valid email address";
    }
    else if(username.isEmpty){
      tempMessage = "Please enter a username";
    }
    else if(password.length < 8){
      tempMessage = "Password must be at least 8 characters";
    }
    else{
      try {
        await databaseManager.registerNewUser(
            emailAddress, username, password, gender, birthdate);
        tempMessage = "User successfully registered";
        Map<String, List<String>> brandModel = await databaseManager.getBrands();
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BrandsScreen(
                  databaseManager: databaseManager,
                  brandModels: brandModel,
                ))
        );
      }
      catch(e){
        tempMessage = "Error: $e";
      }
    }
    setState(() {
      message = tempMessage;
      loadingSpinner = false;
    });
  }

  @override
  void dispose(){
    super.dispose();
    emailAddress = "";
    username = "";
    password = "";
    message = "";
  }

  @override
  // 4 fields for the sign up page
  // EmailAddress, Username, Birthdate, Gender, Password

  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loadingSpinner,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment:  CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Hero(
                    tag: 'logo',
                    child: Image(
                      image: AssetImage('assets/images/logo.jpeg'),
                      height: 80.0,
                    ),
                  ),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              myTextField(
                obscureText: false,
                onChanged: (value) {
                  emailAddress = value;
                },
                hintText: "Enter your email",
                icon: Icons.email,
              ),
              const SizedBox(
                height: 8.0,
              ),
              myTextField(
                obscureText: false,
                onChanged: (value) {
                  username = value;
                },
                hintText: "Enter your username",
                icon: Icons.person,
              ),
              const SizedBox(
                height: 8.0,
              ),
              myTextField(
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                hintText: "Enter your password",
                icon: Icons.lock,
              ),
              const SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Gender: ",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        activeColor: Colors.black,
                        title: Text('Male'),
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (value){
                          gender = value!;
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.black,
                        title: Text('Female'),
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (value){
                          gender = value!;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              // Date of birth
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    Text(
                      "Birthdate: ",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: IconButton(
                          onPressed: birthDatePicker,
                          icon: Icon(
                            Icons.calendar_today,
                            size: 30.0,
                          ),
                          color: Colors.black,
                        ),
                        trailing: Text(
                            "${birthdate.day}/${birthdate.month}/${birthdate.year}",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
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
              const SizedBox(
                height: 10.0,
              ),
              RoundedButton(
                text: 'SignUp',
                press: () async {
                  await validateUser();
                },
              )
            ],
          ),
        )
      )
    );
  }
}