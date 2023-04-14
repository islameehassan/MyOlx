import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:search_choices/search_choices.dart';


// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables


/*
* Screen to display the top 5 areas with the most ads, and let the user search by any make or model to get the average price of the car across all ads in all areas
* */

class AreaScreen extends StatefulWidget {
  AreaScreen({Key? key, required this.databaseManager}) : super(key: key);
  static const id = 'Areas';
  final DatabaseManager databaseManager;

  @override
  State<AreaScreen> createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  late final DatabaseManager databaseManager;
  late final List<String> brands;
  late final List<String> models;
  @override
  void initState() {
    super.initState();
    // get the top 5 areas with the most ads
    // get the list of all makes and models
    databaseManager = widget.databaseManager;
    Map<String, List<String>> result = databaseManager.brandModels;
    // get all keys (brands)
    brands = result.keys.toList();
    // get all values (models)
    models = result.values.toList().expand((element) => element).toList();

  }

  Future<Map<String, Pair<String, String>>> getTopFiveAreas() async{
    // get the top 5 areas with the most ads
    Map<String, Pair<String, String>> topFiveAreas = await databaseManager.getTopFiveAreas();
    setState(() {
      topAreas = topFiveAreas.keys.toList();
    });
    return topFiveAreas;
  }


  String selectedBrand = "";
  String selectedModel = "";
  String selectedArea = "";
  bool areasLoaded = false;
  List<String> topAreas = [];
  String averagePrice = "";
  String message = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Areas'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top 5 Areas',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              // list of top 5 areas
              Column(
                children: [
                  FutureBuilder(
                    future: getTopFiveAreas(),
                    builder: (context, AsyncSnapshot<Map<String, Pair<String, String>>> snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data!.keys.map((area){
                            return cityInfo(
                              areaName: area,
                              numberOfAds: snapshot.data![area]!.first,
                              averagePrice: snapshot.data![area]!.second,
                            );
                          }).toList(),
                        );
                      }
                      else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                  ),
                  Text(
                    'Search by Make or Model to get the average price of the car across all ads in one of the top 5 areas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // Select a location
                  Text(
                    'Select a location',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  SearchChoices.single(
                    items: topAreas.map((area) {
                      return DropdownMenuItem(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    value: selectedArea,
                    hint: 'Select Area',
                    searchHint: 'Select Area',
                    onChanged: (value) {
                      setState(() {
                        selectedArea = value.toString();
                      });
                    },
                    isExpanded: true,
                  ),
                  // choose a location
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Select a Make or Model',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SearchChoices.single(
                    readOnly: selectedModel != 'null' && selectedModel != '',
                    items: brands.map((brand) {
                      return DropdownMenuItem(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
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
                  // message if the user has not selected a make or model
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SearchChoices.single(
                    readOnly: selectedBrand != 'null' && selectedBrand != '',
                    items: models.map((model) {
                      return DropdownMenuItem(
                        value: model,
                        child: Text(model),
                      );
                    }).toList(),
                    value: selectedModel,
                    hint: 'Select Model',
                    searchHint: 'Select Model',
                    onChanged: (value) {
                      setState(() {
                        selectedModel = value.toString();
                      });
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      if((selectedBrand == 'null' && selectedModel == 'null') || selectedArea == 'null' || (selectedBrand == '' && selectedModel == '') || selectedArea == '') {
                        setState(() {
                          message = 'Please select a make or model and a location';
                        });
                        return;
                      }
                      if (selectedBrand != 'null') {
                        averagePrice = await databaseManager.getAvgBrandPrice(selectedBrand, selectedArea);
                      }
                      else if (selectedModel != 'null') {
                        averagePrice = await databaseManager.getAvgModelPrice(selectedModel, selectedArea);
                      }
                      setState(() {
                      });
                    },
                    child: const Text('Search'),
                  ),
                  // Result
                  const SizedBox(
                    height: 10.0,
                  ),
                  // message if the user has not selected a make or model or location
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.redAccent,
                      ),
                    ),
                  Text(
                    'Average Price: $averagePrice EGP',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class cityInfo extends StatelessWidget {
  const cityInfo({Key? key, required this.areaName, required this.averagePrice, required this.numberOfAds}) : super(key: key);
  final String areaName;
  final String averagePrice;
  final String numberOfAds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      width: MediaQueryData.fromWindow(WidgetsBinding.instance!.window).size.width,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 1,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            areaName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          // Avg price and number of ads
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Avg price per Car: ',
                style: TextStyle(
                  color: Colors.grey[300],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$averagePrice EGP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Number of ads: ',
                style: TextStyle(
                  color: Colors.grey[300],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    numberOfAds,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

