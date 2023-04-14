import 'package:flutter/material.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:search_choices/search_choices.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables




class myEndDrawer extends StatefulWidget{
  const myEndDrawer({super.key, required this.databaseManager, required this.passDataToParent});
  final DatabaseManager databaseManager;
  final void Function(dynamic selectedBrand, dynamic selectedLocation, dynamic selectedYear, dynamic selectedBodyType, dynamic selectedMinPrice, dynamic selectedMaxPrice, dynamic selectedMinMileage, dynamic selectedMaxMileage, dynamic selectedPaymentMethod, dynamic selectedExtraFeatures) passDataToParent;
  @override
  State<myEndDrawer> createState() => _myEndDrawerState();
}

class _myEndDrawerState extends State<myEndDrawer>{
  late final DatabaseManager databaseManager;
  late final List<String> brands;
  late final List<String> locations;

  @override



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

  List<DropdownMenuItem<String>> years(){
    List<DropdownMenuItem<String>> years = [];
    for (var i = 2000; i <= 2023; i++) {
      years.add(
        DropdownMenuItem(
          value: '$i',
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

  String selectedBodyType = '';
  String selectedBrand = '';
  String selectedLocation = '';
  String selectedYear = '';
  List<String> selectedExtraFeatures = [];
  late String username;
  String minPrice = '';
  String maxPrice = '';
  String minMileage = '';
  String maxMileage = '';
  String selectedPaymentMethod = 'Both';

  @override
  void initState() {
    super.initState();
    databaseManager = widget.databaseManager;
    databaseManager.getBrands();
    brands = widget.databaseManager.brandModels.keys.toList();
    locations = widget.databaseManager.locations;
    username = databaseManager.username;
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        width: 250,
        semanticLabel: 'Filters',
        child: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: ListView(
            addAutomaticKeepAlives: true,
            children: [
              // Welcome Message and Logout Button
              DrawerHeader(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Please select the filters you want to apply',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.passDataToParent(selectedBrand, selectedLocation, selectedYear.toString(), selectedBodyType, minPrice.toString(), maxPrice.toString(), minMileage.toString(), maxMileage.toString(), selectedPaymentMethod.toString(), selectedExtraFeatures);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ],
                  // apply filters button
                ),
                // apply filters button
              ),
              // Brand
              drawerElement(
                icon: Icons.directions_car,
                title: 'Brand',
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
              // Location
              drawerElement(
                icon: Icons.location_on,
                title: 'Location',
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
              // Year
              drawerElement(
                icon: Icons.calendar_today,
                title: 'Year',
                child: SearchChoices.single(
                  items: years(),
                  value: selectedYear,
                  hint: 'Select Year',
                  searchHint: 'Select Year',
                  onChanged: (value) {
                    setState(() {
                      selectedYear = value.toString();
                    });
                  },
                  isExpanded: true,),
              ),
              Divider(
                color: Colors.black,
                thickness: 1.2,
              ),
              // Body Type
              drawerElement(
                icon: Icons.directions_car,
                title: 'Body Type',
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
              // Price
              drawerElement(
                icon: Icons.attach_money,
                title: 'Price',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          minPrice = value.toString();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Min Price',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          maxPrice = value.toString();
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
              // Mileage
              drawerElement(
                icon: Icons.speed,
                title: 'Mileage',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          minMileage = value.toString();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Min Mileage',
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          maxMileage = value.toString();
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
              // payment options (either cash or installment through Radio Buttons)
              drawerElement(
                icon: Icons.payment,
                title: 'Payment Options',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      activeColor: Colors.redAccent,
                      value: 'Cash',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value.toString();
                        });
                      },
                      title: const Text('Cash'),
                    ),
                    RadioListTile(
                      activeColor: Colors.redAccent,
                      value: 'Installment',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value.toString();
                        });
                      },
                      title: const Text('Installment'),
                    ),
                    RadioListTile(
                      activeColor: Colors.redAccent,
                      value: 'Both',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value.toString();
                        });
                      },
                      title: const Text('Both'),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
                thickness: 1.2,
              ),
              // Extra Features
              drawerElement(
                icon: Icons.add,
                title: 'Extra Features',
                child: SearchChoices.multiple(
                  items: getExtraFeatures(),
                  hint: 'Select Extra Features',
                  searchHint: 'Select Extra Features',
                  onChanged: (value) {
                    setState(() {
                      selectedExtraFeatures = value as List<String>;
                    });
                  },
                  isExpanded: true,
                ),
              ),
            ],),
        ),
      ),
    );
  }
}

class drawerElement extends StatelessWidget {
  const drawerElement({Key? key, required this.child, required this.icon, required this.title})
      : super(key: key);
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: child,
        ),
      ],
    );
  }
}