import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:search_choices/search_choices.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:myolx/components/roundedbutton.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.databaseManager}) : super(key: key);
  static const id = 'HomeScreen';
  final DatabaseManager databaseManager;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // drawer that will be pulled from the right side of the screen
  late final databaseManager;
  late final Map<String, List<String>> brandModels;
  late final List<String> brands;
  late final List<String> locations;
  bool downloaded = false;

  @override
  void initState() {
    super.initState();
    databaseManager = widget.databaseManager;
    locations = databaseManager.locations;
    getBrands();
  }

  void getBrands() {
    brandModels =  databaseManager.brandModels;
    List<String> brands = [];
    for (var i = 0; i < brandModels.length; i++) {
      brands.add(brandModels.keys.elementAt(i));
    }
    setState(() {
      this.brands = brands;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: myDrawer(databaseManager: databaseManager),
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.filter_alt),
            ),
          ),
        ],
        title: const Text('MyOLX'),
      ),
    );
  }
}






/*
* This is the drawer that will be pulled from the right side of the screen
*/



class myDrawer extends StatefulWidget {
  const myDrawer({super.key, required this.databaseManager});
  final DatabaseManager databaseManager;
  @override
  State<myDrawer> createState() => _myDrawerState();
}

class _myDrawerState extends State<myDrawer> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  late final DatabaseManager databaseManager;
  late final List<String> brands;
  late final List<String> locations;



  final List<String> bodyTypes = [
    'Sedan',
    'SUV',
    'Pickup',
    '4X4',
    'Hatchback',
    'Coupe',
    'Van/Bus',
    'Cabriolet',
    'Other',
  ];

  List<RadioListTile> bodyTypeRadioListTiles(){
    List<RadioListTile> bodyTypeRadioListTiles = [];
    for (var i = 0; i < bodyTypes.length; i++) {
      bodyTypeRadioListTiles.add(
        RadioListTile(
          activeColor: Colors.pinkAccent,
          value: bodyTypes[i],
          groupValue: selectedBodyType,
          onChanged: (value) {
            setState(() {
              selectedBodyType = value.toString();
            });
          },
          title: Text(bodyTypes[i]),
        ),
      );
    }
    return bodyTypeRadioListTiles;
  }

  List<DropdownMenuItem<int>> years(){
    List<DropdownMenuItem<int>> years = [];
    for (var i = 2000; i <= 2023; i++) {
      years.add(
        DropdownMenuItem(
          value: i,
          child: Text(i.toString()),
        ),
      );
    }
    return years;
  }

  List<DropdownMenuItem<String>> getBrands(){
    List<DropdownMenuItem<String>> brands = [];
    for (var i = 0; i < this.brands.length; i++) {
      brands.add(
        DropdownMenuItem(
          value: this.brands[i],
          child: Text(this.brands[i]),
        ),
      );
    }
    return brands;
  }

  List<DropdownMenuItem<String>> getLocations(){
    List<DropdownMenuItem<String>> locations = [];
    for (var i = 0; i < this.locations.length; i++) {
      locations.add(
        DropdownMenuItem(
          value: this.locations[i],
          child: Text(this.locations[i]),
        ),
      );
    }
    return locations;
  }

  List<DropdownMenuItem<String>> getExtraFeatures(){
    List<DropdownMenuItem<String>> extraFeatures = [];
    for (var i = 0; i < databaseManager.extraFeatures.length; i++) {
      extraFeatures.add(
        DropdownMenuItem(
          value: databaseManager.extraFeatures[i],
          child: Text(databaseManager.extraFeatures[i]),
        ),
      );
    }
    return extraFeatures;
  }

  late String selectedBodyType;
  late String selectedBrand;
  late String selectedLocation;
  late int selectedMinYear;
  List<String> selectedExtraFeatures = [];
  late String username;

  @override
  void initState() {
    super.initState();
    databaseManager = widget.databaseManager;
    brands = widget.databaseManager.brandModels.keys.toList();
    locations = widget.databaseManager.locations;
    selectedBrand = brands[0];
    selectedLocation = locations[0];
    selectedMinYear = 2000;
    selectedBodyType = bodyTypes[0];
    username = databaseManager.username;
  }

  int minPrice = 0;
  int maxPrice = 10000000;
  int minMileage = 0;
  int maxMileage = 1000000;
  String selectedPaymentMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Drawer(
            width: 250,
            semanticLabel: 'Filters',
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                addAutomaticKeepAlives: true,
                children: [
                  // Welcome Message and Logout Button
                  myDrawerHeader(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            'Welcome $username',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Please select the filters you want to apply',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.branding_watermark),
                    title: const Text(
                      'Brand',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SearchChoices.single(
                      items: getBrands(),
                      value: selectedBrand,
                      hint: 'Select Brand',
                      searchHint: 'Select Brand',
                      onChanged: (value) {
                        setState(() {
                          selectedBrand = value.toString();
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SearchChoices.single(
                      items: getLocations(),
                      value: selectedLocation,
                      hint: 'Select Location',
                      searchHint: 'Select Location',
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value.toString();
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text(
                      'Year',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SearchChoices.single(
                      items: years(),
                      value: selectedMinYear,
                      hint: 'Select Year',
                      searchHint: 'Select Year',
                      onChanged: (value) {
                        setState(() {
                          selectedMinYear = value as int;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: const Text(
                      'Body Type',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SearchChoices.single(
                      items: bodyTypes.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      )).toList(),
                      value: selectedBodyType,
                      hint: 'Select Body Type',
                      searchHint: 'Select Body Type',
                      onChanged: (value) {
                        setState(() {
                          selectedBodyType = value.toString();
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text(
                      'Extra Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: SearchChoices.multiple(
                      items: getExtraFeatures(),
                      hint: 'Select Extra Features',
                      searchHint: 'Select Extra Features',
                      onChanged: (value) {
                        setState(() {
                          selectedExtraFeatures = value;
                        });
                      },
                      isExpanded: true,
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text(
                      'Price',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              minPrice = int.parse(value);
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Min Price',
                          ),
                        ),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              maxPrice = int.parse(value);
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Max Price',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.speed),
                    title: const Text(
                      'Mileage',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              minMileage = int.parse(value);
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Min Mileage',
                          ),
                        ),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              maxMileage = int.parse(value);
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Max Mileage',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 1.2,
                  ),
                  // payment options (either cash or installment)
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: const Text(
                      'Payment Options',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // three radio buttons (cash, installment, both)
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile(
                          value: 1,
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value as String;
                            });
                          },
                          title: const Text('Cash'),
                        ),
                        RadioListTile(
                          value: 2,
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value as String;
                            });
                          },
                          title: const Text('Installment'),
                        ),
                        RadioListTile(
                          value: 3,
                          groupValue: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value as String;
                            });
                          },
                          title: const Text('Both'),
                        ),
                      ],
                    ),
                  ),
              ],),
            ),
          ),
        ],
      ),
    );
  }
}

class myDrawerHeader extends StatelessWidget {
  myDrawerHeader({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1.2,
          ),
        ),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: child,
    );
  }
}