import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myolx/Screens/HomeScreen.dart';
import 'package:myolx/Screens/LoginScreen.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';

import '../Utilities/carAd.dart';

// ignore_for_file: prefer_const_constructors

class AdScreen extends StatefulWidget {
  const AdScreen({Key? key, required this.carAd}) : super(key: key);
  static const String id = 'AdScreen';
  final CarAd carAd;


  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  late final CarAd carAd;

  @override
  void initState() {
    super.initState();
    carAd = widget.carAd;
    print(carAd.Selling_Price);
  }
  Widget build(BuildContext context){
    print(carAd.Engine_Capacity_Lower_Range.runtimeType);
    // A scren to display the ad details from the car ad object
    return Scaffold(
      appBar: AppBar(
        title: Text('Ad'),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(
                mainAxisAlignment : MainAxisAlignment.end,
                children: [
                  Chip(
                    label: Text(carAd.User_EmailAddress == null ? "Available" : "Sold", style: TextStyle(color: Colors.white),),
                    backgroundColor: carAd.User_EmailAddress == null ? Colors.green : Colors.red,
                  ),
                ],
              ),
              // add a chip to notify the user if the ad is sold or not
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      // show the ad details in two columns, one for the attribute name and the other for the value
                      Text(
                        "Brand: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Model: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Year: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Price: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Mileage: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Location: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Transmission: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Body Type: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Color: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Engine Capacity (CC): ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Fuel Type: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Payment Method(s): ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // show the values of the other columns
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 36,
                        ),
                        // show the ad details in two columns, one for the attribute name and the other for the value
                        Text(
                          "${carAd.Brand}",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${carAd.Model}",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${carAd.CarYear}",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${carAd.Price?.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} EGP",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          (carAd.Odometer_Upper_Range == null || carAd.Odometer_Upper_Range == 'null') ? "Not Specified" : carAd.Odometer_Upper_Range == carAd.Odometer_Lower_Range ? '${carAd.Odometer_Upper_Range} km' : '${carAd.Odometer_Lower_Range} - ${carAd.Odometer_Upper_Range} km',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${carAd.Location}",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          carAd.Transmission == null ? 'Not Specified' : '${carAd.Transmission}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          carAd.BodyType == null ? 'Not Specified' : '${carAd.BodyType}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          carAd.Color == null ? 'Not Specified' : '${carAd.Color}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          (carAd.Engine_Capacity_Lower_Range == null || carAd.Engine_Capacity_Lower_Range == 'null') ? "Not Specified" : carAd.Engine_Capacity_Upper_Range == carAd.Engine_Capacity_Lower_Range ? '${carAd.Engine_Capacity_Upper_Range} CC' : '${carAd.Engine_Capacity_Lower_Range} - ${carAd.Engine_Capacity_Upper_Range} CC',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          carAd.FuelType == null ? 'Not Specified' : '${carAd.FuelType}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          carAd.Payment_Method == null ? 'Not Specified' : '${carAd.Payment_Method}',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Text("Description", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text(carAd.Ad_Description!, style: TextStyle(fontSize: 15),),
              SizedBox(height: 20,),
              Text("Extra Features", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              // show extra features chips in a list view
              Wrap(
                children: [
                  for (var feature in carAd.Features!)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Chip(
                        label: Text(feature),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20,),
              // Show the owner details
              Text("Owner Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Phone: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Name: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Join Date: ",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${carAd.Owner_PhoneNumber}",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${carAd.Owner_Username}",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "${carAd.Owner_JoinDate}",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              // a button to buy the car, show a custom dialog to confirm the purchase, let the user enter their email address, review, and rating out of 5
              // the user can only buy the car if he is logged in, do not show any details of the car
              if(carAd.User_EmailAddress == null || carAd.User_EmailAddress == 'null')
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      int rating = 0;
                      bool showSpinner = false;
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController emailController = TextEditingController();
                          TextEditingController reviewController = TextEditingController();
                          TextEditingController priceController = TextEditingController();
                          return ModalProgressHUD(
                            inAsyncCall: showSpinner,
                            child: AlertDialog(
                              title: Text("Buy Car"),
                              content: StatefulBuilder(
                                builder: (context, setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Enter your email address:"),
                                      TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          hintText: "Email Address",
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Enter your review:"),
                                      TextField(
                                        controller: reviewController,
                                        decoration: InputDecoration(
                                          hintText: "Review",
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Enter your selling price:"),
                                      TextField(
                                        keyboardType: TextInputType.number,
                                        controller: priceController,
                                        decoration: InputDecoration(
                                          hintText: "Selling Price",
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Enter your rating:"),
                                      // show 5 stars to rate the car
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          for (int i = 0; i < 5; i++)
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  rating = i + 1;
                                                });
                                              },
                                              icon: Icon(
                                                Icons.star,
                                                color: i < rating ? Colors.yellow : Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async{
                                    if(emailController.text.isEmpty || reviewController.text.isEmpty || priceController.text.isEmpty || rating == 0){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Please fill all the fields"),
                                        ),
                                      );
                                      return;
                                    }
                                    else if(priceController.text == '0' || RegExp(r'^-\d+$').hasMatch(priceController.text) == true){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Please enter a valid price"),
                                        ),
                                      );
                                      return;
                                    }
                                    final DatabaseManager databaseManager = DatabaseManager();
                                    setState(() {
                                      showSpinner = true;
                                    });
                                    await databaseManager.addSale(carAd.Ad_Id!, emailController.text!, reviewController.text!, priceController.text, rating.toString());
                                    setState(() {
                                      showSpinner = false;
                                    });
                                    // navigate to the home page and refresh the paging controller
                                    databaseManager.getBrands();
                                    databaseManager.getLocations();
                                    databaseManager.getExtraFeatures();
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen(databaseManager: databaseManager,)));
                                  },
                                  child: Text("Buy"),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text("Buy Now", style: TextStyle(fontSize: 20),),
                  ),
                ),



              // review section and rating if the car was bought
              // this section should not be shown if the car was not bought
              if (carAd.Review != null)
                Text("Deal Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              // show the review of the car if it was bought (it is only one review)
              if (carAd.Review != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Buyer Email Address: ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Selling Price: ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "Rating: ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${carAd.User_EmailAddress}",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "${carAd.Selling_Price} EGP",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "${carAd.Rating}",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                  ],
                ),
              if(carAd.Review != null)
                Text("Review", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              // show the only review of the car
              if(carAd.Review != null)
                Text(
                  "${carAd.Review}",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
