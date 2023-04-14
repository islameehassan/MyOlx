import 'dart:ffi';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:myolx/Screens/AreasScreen.dart';
import 'package:myolx/Screens/LoginScreen.dart';
import 'package:myolx/Utilities/carAd.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:myolx/Components/endDrawer.dart';
import 'package:myolx/Components/adListTile.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.databaseManager}) : super(key: key);
  static const id = 'HomeScreen';
  final DatabaseManager databaseManager;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseManager _databaseManager = DatabaseManager();
  final PagingController<int, adListTile> _pagingController =
      PagingController(firstPageKey: 0);

  late final DatabaseManager databaseManager;
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
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      if (_databaseManager.isConnected == false) {
        await _databaseManager.authenticateUser(
            'islamee@aucegypt.edu', 'helloPHP');
      }
      final newItems = await _databaseManager.getAds(
          selectedBrand,
          selectedLocation,
          selectedYear,
          selectedBodyType,
          selectedMinPrice,
          selectedMaxPrice,
          selectedMinMileage,
          selectedMaxMileage,
          selectedPaymentMethod,
          selectedExtraFeatures,
          pageKey);

      final items = _buildItems(newItems.length, newItems);
      final isLastPage = newItems.length < 10;
      if (isLastPage) {
        print('last page');
        print(items.length);
        _pagingController.appendLastPage(items);
      } else {
        final nextPageKey = pageKey + items.length;
        _pagingController.appendPage(items, nextPageKey);
      }
    } catch (error) {
      print('error: $error');
      _pagingController.error = error;
    }
  }

  List<adListTile> _buildItems(int count, List<CarAd> ads) {
    return List.generate(
      count,
      (index) => adListTile(carAd: ads[index]),
    );
  }

  void getBrands() {
    brandModels = databaseManager.brandModels;
    List<String> brands = [];
    for (var i = 0; i < brandModels.length; i++) {
      brands.add(brandModels.keys.elementAt(i));
    }
    setState(() {
      this.brands = brands;
    });
  }

  // Variables for filtering the ads
  String selectedBrand = "Honda";
  String selectedLocation = "";
  String selectedYear = '';
  String selectedBodyType = '';
  List<String> selectedExtraFeatures = [];
  String selectedMinPrice = '';
  String selectedMaxPrice = '';
  String selectedMinMileage = '';
  String selectedMaxMileage = '';
  String selectedPaymentMethod = "";

  // Variable to control which brand's models to show
  String selectedBrandToFilterForModels = "Honda";

  // Variable to refresh the page after filtering
  bool drawerCalled = false;

  @override
  Widget build(BuildContext context) {
    function(
            selectedBrand,
            selectedLocation,
            selectedYear,
            selectedBodyType,
            selectedMinPrice,
            selectedMaxPrice,
            selectedMinMileage,
            selectedMaxMileage,
            selectedPaymentMethod,
            selectedExtraFeatures) =>
        setState(() {
          setState(() {
            this.selectedBrand = selectedBrand;
            if (this.selectedBrand.isNotNullOrEmpty) {
              selectedBrandToFilterForModels = selectedBrand;
            }
            this.selectedLocation = selectedLocation;
            this.selectedYear = selectedYear;
            this.selectedBodyType = selectedBodyType;
            this.selectedMinPrice = selectedMinPrice;
            this.selectedMaxPrice = selectedMaxPrice;
            this.selectedMinMileage = selectedMinMileage;
            this.selectedMaxMileage = selectedMaxMileage;
            this.selectedPaymentMethod = selectedPaymentMethod;
            this.selectedExtraFeatures = selectedExtraFeatures;
            drawerCalled = true;
          });
        });

    setState(() {
      if (drawerCalled) {
        _pagingController.refresh();
        drawerCalled = false;
      }
    });

    @override
    void dispose() {
      print('dispose');
      _pagingController.dispose();
      super.dispose();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      drawer: startDrawer(
        databaseManager: databaseManager,
      ),
      endDrawer: myEndDrawer(
          databaseManager: databaseManager, passDataToParent: function),
      appBar: AppBar(
        backgroundColor: Colors.red,
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
        title: Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SafeArea(
          child: PageView(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // add a row of buttons that show different capabilities of the app (Show adds and top sellers, search sellers, top 5 areas, etc.)
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Top 5 Sellers in Cairo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 300,
                      child: FutureBuilder(
                        future: databaseManager.getTopSellers(),
                        builder: (context,
                            AsyncSnapshot<List<List<String>>> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  child: userInfo(
                                    name: snapshot.data![index][0],
                                    phoneNo: snapshot.data![index][1],
                                    noOfAds: snapshot.data![index][2],
                                    avgPrice: snapshot.data![index][3],
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
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
                      '$selectedBrandToFilterForModels Models in Cairo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: FutureBuilder(
                        future: databaseManager.getModelsInfoforBrand(
                            selectedBrandToFilterForModels),
                        builder: (context,
                            AsyncSnapshot<Map<String, Pair<String, String>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(10),
                                  child: modelInfo(
                                    model: snapshot.data!.keys.elementAt(index),
                                    avgPrice: snapshot.data!.values
                                        .elementAt(index)
                                        .first,
                                    noOfAds: snapshot.data!.values
                                        .elementAt(index)
                                        .second,
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                    // Set a title for the list
                    const Text(
                      'Filterd Results',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PagedListView<int, adListTile>(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<adListTile>(
                          itemBuilder: (context, item, index) => item,
                          firstPageErrorIndicatorBuilder: (context) =>
                              const Center(
                              child: Text(
                              'Error Loading First Page',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          noItemsFoundIndicatorBuilder: (context) =>
                              const Center(
                            child: Text(
                              'No Items Found',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          firstPageProgressIndicatorBuilder: (context) =>
                              const Center(
                            child: CircularProgressIndicator(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
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

class userInfo extends StatelessWidget {
  const userInfo(
      {Key? key,
      required this.name,
      required this.phoneNo,
      required this.avgPrice,
      required this.noOfAds})
      : super(key: key);
  final String name;
  final String phoneNo;
  final String avgPrice;
  final String noOfAds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      width: 280,
      height: 20,
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
            name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          // phone number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone number: ',
                style: TextStyle(
                  color: Colors.grey[300],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    phoneNo,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
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
                    '$avgPrice EGP',
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
                    noOfAds,
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

class modelInfo extends StatelessWidget {
  const modelInfo(
      {Key? key,
      required this.model,
      required this.avgPrice,
      required this.noOfAds})
      : super(key: key);
  final String model;
  final String avgPrice;
  final String noOfAds;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      width: 280,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.redAccent.shade700,
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
            model,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          // phone number
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
                    // add a comma to the price each three digits
                    '${avgPrice.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} EGP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Avg price and number of ads
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
                    noOfAds,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class startDrawer extends StatelessWidget {
  const startDrawer({Key? key, required this.databaseManager})
      : super(key: key);
  final DatabaseManager databaseManager;

  @override
  Widget build(BuildContext context) {
    // the user can see also other pages like owners, areas, and models
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.redAccent,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Owners'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Areas'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AreaScreen(databaseManager: databaseManager),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Models'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
