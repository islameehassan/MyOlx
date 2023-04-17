import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:myolx/Screens/AreasScreen.dart';
import 'package:myolx/Screens/OwnersScreen.dart';
import 'LoginScreen.dart';
import 'package:myolx/Utilities/carAd.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:myolx/Components/endDrawer.dart';
import 'package:myolx/Components/adListTile.dart';
import 'package:myolx/Components/modelInfo.dart';
import 'package:myolx/Screens/MakesandModelsScreen.dart';
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
      // check if the widget is still mounted
      if (!mounted) {
        return;
      }
      final newItems = await databaseManager.getAds(
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
      final isLastPage = newItems.length == 0;
      if (isLastPage) {
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
    brandModels = databaseManager.brandANDmodels;
    List<String> brands = [];
    for (var i = 0; i < brandModels.length; i++) {
      brands.add(brandModels.keys.elementAt(i));
    }
    setState(() {
      this.brands = brands;
    });
  }

  // Variables for filtering the ads
  String selectedBrand = "Audi";
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
  String selectedBrandToFilterForModels = "Audi";

  // Variable to refresh the page after filtering
  bool drawerCalled = false;

  @override
  void dispose() {
    print('dispose');
    _pagingController.dispose();
    super.dispose();
  }

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

    _pagingController.refresh();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
            child: SingleChildScrollView(
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
                    'Filtered Results',
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
          ),
        ),
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
                  builder: (context) => OwnersScreen(databaseManager: databaseManager),
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
                      AreasScreen(databaseManager: databaseManager),
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
                  builder: (context) => MakesandModels(databaseManager: databaseManager),
                ),
              );
            },
          ),
          // log out button
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
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
