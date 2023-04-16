import 'package:flutter/material.dart';
import 'package:myolx/Utilities/DatabaseManager.dart';
import 'package:myolx/Components/userInfo.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:myolx/Utilities/carAd.dart';
import 'package:myolx/Components/adListTile.dart';
// ignore_for_file: prefer_const_constructors

class OwnersScreen extends StatefulWidget {
  OwnersScreen({Key? key, required this.databaseManager}) : super(key: key);
  static const String id = 'UsersScreen';
  final DatabaseManager databaseManager;

  @override
  State<OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<OwnersScreen> {
  late final DatabaseManager databaseManager;
  late final PagingController<int, CarAd> _pagingController =
      PagingController(firstPageKey: 0);

  void _fetchPage(int pageKey) async {
    try {
      final newItems = await databaseManager.getOwnerAds(selectedUsername, selectedPhoneNum, pageKey);
      final isLastPage = newItems.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 10;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(error);
      _pagingController.error = error;
    }
  }

  void initState() {
    super.initState();
    databaseManager = widget.databaseManager;
    databaseManager.getTopSellers();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    getTopSellers();
  }

  Future<void> getTopSellers() async {
    List<List<String>> topSellers = [];
    topSellers = await databaseManager.getTopSellers();
    setState(() {
      this.topSellers = topSellers;
    });
  }

  Future<List<List<String>>> getSellerInfo() async {
    List<List<String>> sellerInfo = [];
    if(username != '' && phoneNum != ''){
      return sellerInfo;
    }
    try{
      sellerInfo = await databaseManager.getSellerInfo(phoneNum, username);
    }
    catch(e){
      print(e);
    }
    if(sellerInfo.isEmpty){
      setState(() {
        userFound = false;
      });
    }
    else{
      setState(() {
        userFound = true;
      });
    }
    setState(() {
      loadingUser = false;
    });
    return sellerInfo;
  }

  String username = '';
  String phoneNum = '';
  String selectedUsername = '';
  String selectedPhoneNum = '';
  List<List<String>> topSellers = [];
  bool searchByPhone = false;
  bool searchByUsername = false;
  bool userFound = false;
  bool loadingUser = false;

  List<List<String>> selectedUserInfo = [];
  @override
  Widget build(BuildContext context) {
    // show the top five users with the most ads, and has a search bar to display all users' ads
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owners'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                'Top 5 Sellers in Cairo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 250,
                child: topSellers.length != 5? const Center(child: CircularProgressIndicator(color: Colors.redAccent,)) : ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  // build the list of users using userInfo widget
                  itemBuilder: (context, index) {
                    return userInfo(
                      name: topSellers[index][0],
                      phoneNo: topSellers[index][1],
                      noOfAds: topSellers[index][2],
                      avgPrice: topSellers[index][3],
                      avgRating: topSellers[index][4],
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(
                    width: 10,
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                thickness: 2,
              ),
              // search bar
              Text(
                'Search Sellers',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // input text field for the username not a search bar
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onChanged: (value) {
                  username = value;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              // input text field for the phone number not a search bar
              TextField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone Number',
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                onChanged: (value) {
                  phoneNum = value;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              // search button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async{
                    setState(() {
                      selectedUsername = username;
                      selectedPhoneNum = phoneNum;
                      userFound = false;
                      loadingUser = true;
                    });
                    selectedUserInfo = await getSellerInfo();
                    _pagingController.refresh();
                  },
                  child: const Text('Search'),
                ),
              ),
              Text(
                'Sellers ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // display the user info
              if(userFound)
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedUserInfo.length,
                    // build the list of users using userInfo widget
                    itemBuilder: (context, index) {
                      return userInfo(
                        name: selectedUserInfo[index][0],
                        phoneNo: selectedUserInfo[index][1],
                        noOfAds: selectedUserInfo[index][2],
                        avgPrice: selectedUserInfo[index][3],
                        avgRating: selectedUserInfo[index][4],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        width: 15,
                      );
                    },
                  ),
                ),
              // display the user not found message if the user is not found
              if(!userFound && !loadingUser)
                Center(
                  child: const Text(
                    'User not found',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if(loadingUser)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'User(s) Ads',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // display the results of the search
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PagedListView<int, CarAd>(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<CarAd>(
                    itemBuilder: (context, item, index) => adListTile(
                      carAd: item,
                    ),
                    firstPageProgressIndicatorBuilder: (context) =>
                        const Center(
                          child: CircularProgressIndicator(
                          color: Colors.red,
                      ),
                    ),
                    noItemsFoundIndicatorBuilder: (context) => const Center(
                      child: Text(
                        'No ads found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
