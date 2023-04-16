import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:myolx/Components/loading.dart';
import 'package:myolx/Screens/HomeScreen.dart';
import 'package:myolx/Screens/LoginScreen.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
class BrandsScreen extends StatefulWidget {
  const BrandsScreen({Key? key, required this.databaseManager})
      : super(key: key);
  static const id = 'brandsANDmodels';
  final DatabaseManager databaseManager;

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  late final DatabaseManager databaseManager;
  late Map<String, List<String>> brandsmodelsSelections;
  bool loadingSpinner = false;

  @override
  void initState() {
    super.initState();
    databaseManager = widget.databaseManager;
    brandsmodelsSelections = databaseManager.brandANDmodels;
  }

  List<String> getModels(){
    List<String> models = [];
    for (var i = 0; i < _selectedBrands.length; i++) {
      for (var j = 0; j < brandsmodelsSelections[_selectedBrands[i]]!.length; j++) {
        models.add("${brandsmodelsSelections[_selectedBrands[i]]![j]}(${_selectedBrands[i]})");
      }
    }
    return models;
  }

  List<String> _selectedBrands = [];
  List<String> _selectedModels = [];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() {
              loadingSpinner = true;
            });
            await databaseManager.uploadUserPreferences(_selectedModels);
            await databaseManager.getBrands();
            await databaseManager.getLocations();
            await databaseManager.getExtraFeatures();
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  databaseManager: databaseManager,
                ),
              ),
            );
            setState(() {
              loadingSpinner = false;
            });
          },
          backgroundColor: Colors.redAccent,
          child: const Icon(Icons.arrow_forward),
        ),
        appBar: AppBar(
          title: const Text("Brands"),
          backgroundColor: Colors.redAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              ListView(
                children: [
                  Center(
                    child: Text(
                      "Select the brands and the models you prefer",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Brands: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      MultiSelectDialogField(
                        items: brandsmodelsSelections.entries
                            .map((e) => MultiSelectItem(e.key, e.key))
                            .toList(),
                        listType: MultiSelectListType.CHIP,
                        searchable: true,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                        chipDisplay: MultiSelectChipDisplay(
                          chipColor: Colors.black54,
                          textStyle: const TextStyle(color: Colors.white),
                          onTap: (item) {
                            setState(() {
                              _selectedBrands.remove(item);
                            });
                          },
                        ),
                        onConfirm: (List<Object?> values) {
                          setState(() {
                            _selectedBrands = values.cast<String>();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Models: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      MultiSelectDialogField(
                        items: getModels()
                            .map((e) => MultiSelectItem(e, e))
                            .toList(),
                        listType: MultiSelectListType.CHIP,
                        searchable: true,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                        chipDisplay: MultiSelectChipDisplay(
                          chipColor: Colors.black54,
                          textStyle: const TextStyle(color: Colors.white),
                          onTap: (item) {
                            setState(() {
                              _selectedModels.remove(item);
                            });
                          },
                        ),
                        onConfirm: (List<Object?> values) {
                          setState(() {
                            _selectedModels = values.cast<String>();
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              loadingSpinner ? loading() : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
