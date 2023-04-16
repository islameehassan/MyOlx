import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:myolx/Components/modelInfo.dart';

import '../Utilities/DatabaseManager.dart';

// ignore_for_file: prefer_const_constructors

class MakesandModels extends StatefulWidget {
  MakesandModels({Key? key, required this.databaseManager}) : super(key: key);
  static const String id = 'MakesandModels';
  final DatabaseManager databaseManager;

  @override
  State<MakesandModels> createState() => _MakesandModelsState();
}

class _MakesandModelsState extends State<MakesandModels> {

  List<String> topMakes = [];
  List<String> topModels = [];


  String? selectedMake = '';
  String? selectedModel = '';
  String avgPrice = '';
  String message = '';
  RangeValues selectedYearsRange = const RangeValues(2000, 2021);
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Makes and Models'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Top 5 Makes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Show the top 5 makes using a future builder using the model info widget
            SizedBox(
              height: 150,
              child: FutureBuilder(
                future: widget.databaseManager.getTopFiveMakes(),
                builder: (context, AsyncSnapshot<Map<String, Pair<String, String>>> snapshot){
                  if (snapshot.hasData) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return modelInfo(
                          model: snapshot.data!.keys.elementAt(index),
                          noOfAds: snapshot.data!.values.elementAt(index).first,
                          avgPrice: snapshot.data!.values.elementAt(index).second,
                        );
                      }, separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(width: 20);
                    },
                    );
                  }
                  else {
                    return const CircularProgressIndicator(
                      color: Colors.red,
                    );
                  }
                },
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 2,
            ),
            Text(
              'Top 5 Models',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Show the top 5 models using a future builder
            SizedBox(
              height: 150,
              child: FutureBuilder(
                future: widget.databaseManager.getTopFiveModels(),
                builder: (context, AsyncSnapshot<Map<String, Pair<String, String>>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return modelInfo(
                          model: snapshot.data!.keys.elementAt(index),
                          noOfAds: snapshot.data!.values.elementAt(index).first,
                          avgPrice: snapshot.data!.values.elementAt(index).second,
                        );
                      }, separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(width: 20);
                    },
                    );
                  }
                  else {
                    return CircularProgressIndicator(
                      color: Colors.red,
                    );
                  }
                },
              ),
            ),
            Divider(
              color: Colors.black,
              thickness: 2,
            ),
            // search by make or model(but not both) to get average price for this make or model for a given year range
            Text(
              'Search by Make or Model',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: selectedModel != '' && selectedModel != 'null',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Make',
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedMake = value.toString();
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    readOnly: selectedMake != '' && selectedMake != 'null',
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Model',
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedModel = value.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Select Year Range',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // use a range slider to select a year range
            RangeSlider(
              activeColor: Colors.red,
              values: selectedYearsRange,
              min: 2000,
              max: 2023,
              divisions: 21,
              labels: RangeLabels(
                selectedYearsRange.start.toInt().toString(),
                selectedYearsRange.end.toInt().toString(),
              ),
              onChanged: (value) {
                setState(() {
                  selectedYearsRange = value;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            // show the average price for the selected make or model
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                print(selectedYearsRange.start);
                // display a message if no make or model is selected, otherwise get the average price for the user's selection
                if (selectedMake == '' && selectedModel == '') {
                  setState(() {
                    message = 'Please select a make or model';
                  });
                }
                else {
                  setState(() {
                    message = '';
                    loading = true;
                  });
                  // get the average price for the selected make or model
                  String? avgPrice = await widget.databaseManager.getModelorMakeAverageforRangeYear(selectedMake, selectedModel, selectedYearsRange.start.toInt().toString(), selectedYearsRange.end.toInt().toString());
                  setState(() {
                    this.avgPrice = avgPrice ?? 'No Results Found';
                    loading = false;
                  });
                }
              },
              child: const Text('Search'),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if(loading)
              const CircularProgressIndicator(
                color: Colors.red,),
            const SizedBox(
              height: 10,
            ),
            if(!loading)
            Text(
              (avgPrice == 'No Results Found') ? avgPrice : 'Average Price: $avgPrice EGP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]
        ),
      ),
    );
  }
}
