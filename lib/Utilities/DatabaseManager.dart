import 'dart:async';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';
import 'package:dartx/dartx_io.dart';
import 'package:myolx/Utilities/carAd.dart';

// import a library to use pair in dart
/*
* This class is responsible for connecting to the database and performing all the database operations
*/

class DatabaseManager{
  var _conn;
  bool _isConnected = false;
  String _emailAddress = "";
  String _username = "";
  Map<String, List<String>> _brandsANDmodels = {};
  List<String> _locations = [];
  List<String> _extraFeatures = [];

  /*
  * connect to the database
  * private method
  * called by the class after the user has logged in or signed up only.
  */

  Future<void> _connect() async{
    print("Connecting to the database");
    var settings = ConnectionSettings(
      host: 'db4free.net',
      port: 3306,
      user: 'islam_hassan',
      password: 'xuBmXDq4hvqs8Ks',
      db: "my_olx",
      );
    try{
      _conn = await MySqlConnection.connect(settings);
      _isConnected = true;
      print("Connected to the database");
    }
    catch(e){
      print("Error connecting to the database");
      print(e);
    }
  }

  /*
  * getters
  */
  bool get isConnected => _isConnected;
  get conn => _conn;
  String get emailAddress => _emailAddress;
  String get username => _username;
  Map<String, List<String>> get brandANDmodels => _brandsANDmodels;
  List<String> get locations => _locations;
  List<String> get extraFeatures => _extraFeatures;

  /*
  * check if the user exists
  */
  Future<String> checkIfUserExists(String emailAddress) async{
    if(!_isConnected){
      await _connect();
    }
    Results userTuple = await _conn.query('select * from User where Email_Address="$emailAddress"');
    if(userTuple.isEmpty) {
      return "Email Address Not Found";
    }
    else{
      return "Found";
    }
  }

  /*
  * authenticate the user, return a message
  */

  Future<String> authenticateUser(String emailAddress, String pass) async{
    String message = await checkIfUserExists(emailAddress);
    if(message != "Found"){
      return message;
    }

    Results userTuple = await _conn.query('select * from User where Email_Address="$emailAddress"');
    String userPass = userTuple.first.fields["PASSWORD"];
    if(userPass != pass) {
      return "Password is incorrect";
    }
    else{
      _emailAddress = emailAddress;
      _username = userTuple.first.fields["Username"];
      return "Success";
    }
  }

  /*
  * register a new user
  */
  Future<void> registerNewUser(String emailAddress, String username, String password, String gender, DateTime dateOfBirth) async{
    if(!_isConnected){
      await _connect();
    }
    try{
      gender = gender == 'Male' ? 'M' : 'F';
      String newDate = DateFormat("yyyy-MM-dd").format(dateOfBirth);

      await _conn.query('insert into User values (?, ?, ?, ?, ?)', [emailAddress, username, gender, newDate, password]);
      _emailAddress = emailAddress;
      _username = username;
    }
    catch(e){
      print(e);
    }
  }

  /*
  * upload the user preferences
  * IMPORTANT NOTE: currently preferences are not used in the app, they are only retrieved for storage in the database.
  * In later versions of the app, the user should encounter ads that suit their preferences, if no filters are provided by the user.
  */
  Future<void> uploadUserPreferences(List<String> selectedModels) async{
    try{
      print("Uploading User Preferences");
      for(int i = 0; i < selectedModels.length; i++){
        List<String> splittEd = selectedModels[i].split('(');
        String modelName = splittEd[0];
        String brandName = splittEd[1].split(')')[0];

        await _conn.query('insert into UserPreferences(Email_Address, Brand, Model) values (?, ?, ?)', [_emailAddress, brandName, modelName]);
      }
    }
    catch(e){
      print(e);
    }
  }

  /*
  * get the brands and models and store it in a map for usage later
  */

  Future<void> getBrands() async{
    if(!isConnected){
      await _connect();
    }
    Results brands = await _conn.query('select distinct(Brand), Model from CarAd');
    Map<String, List<String>> brandModels = {};
    for(var brand in brands) {
      String brandName = brand.fields["Brand"];
      String modelName = brand.fields["Model"];
      if (brandModels.containsKey(brandName)) {
        brandModels[brandName]!.add(modelName);
      }
      else {
        brandModels[brandName] = [modelName];
      }
    }
    _brandsANDmodels = brandModels;
  }
  /*
  * get all locations sorted alphabetically
  */
  Future<List<String>> getLocations() async{
    Results locations = await _conn.query('select distinct(Location) from CarAd order by 1');
    List<String> locationsList = [];
    for(var location in locations){
      locationsList.add(location.fields["Location"]);
    }
    _locations = locationsList;
    return locationsList;
  }
  /*
  * get all extra features sorted alphabetically
  */
  Future<List<String>> getExtraFeatures() async{
    Results features = await _conn.query('select distinct(Feature) from CarExtraFeatures order by 1');
    List<String> featuresList = [];
    for(var feature in features){
      featuresList.add(feature.fields["Feature"]);
    }
    _extraFeatures = featuresList;
    return featuresList;
  }

  /*
  *  get the average price and the number of ads for each model of a given brand
  */
  Future<Map<String, Pair<String, String>>> getModelsInfoforBrand(String Brand) async{
    Results models = await _conn.query('select Model, avg(Price) as AveragePrice, count(*) as Count from CarAd where Brand="$Brand" group by Model');
    Map<String, Pair<String, String>> modelsInfo = {};
    for(var model in models){
      String modelName = model.fields["Model"];
      int averagePrice = model.fields["AveragePrice"].toInt();
      int count = model.fields["Count"];
      modelsInfo[modelName] = Pair(averagePrice.toString(), count.toString());
    }
    return modelsInfo;
  }

  /*
  * get all the ads for a given brand, model, location, year, body type, price range, mileage range, payment option, extra features.
  * Page is the page number of the ads to be returned, 10 ads per page, used for pagination in the app (to optimize the performance)
  */

  Future<List<CarAd>> getAds(String brand, String location, String year, String bodyType, String minPrice, String maxPrice, String minMileage, String maxMileage, String paymentOption, List<String> userExtraFeatures, int page) async{

    // parse the filters to be used in the query
   List<String> parsedFilters = parseFilters(brand, location, year, bodyType, minPrice, maxPrice, minMileage, maxMileage, paymentOption);
   // check if all filters are empty, if so, return 100 random ads
   bool allEmpty = true;
    for(var filter in parsedFilters){
      if(filter != ""){
        allEmpty = false;
        break;
      }
    }

    if(allEmpty && userExtraFeatures.isEmpty){
      return [];
    }
    else if(!allEmpty) {
      parsedFilters[0] = "where ${parsedFilters[0]}";
    }
    Results ads = await _conn.query('select * from CarAd ${parsedFilters[0]}${parsedFilters[1]}${parsedFilters[2]}${parsedFilters[3]} ${parsedFilters[4]} ${parsedFilters[5]}${parsedFilters[6]} ${parsedFilters[7]} order by Ad_Id limit $page,10');
    List<CarAd> adsList = [];
    for(var ad in ads){
      String adId = ad.fields["Ad_Id"].toString();
      Results tempExtraFeatures = await _conn.query('select Feature from CarExtraFeatures where Ad_Id="$adId"');

      if(tempExtraFeatures.isEmpty && userExtraFeatures.isNotEmpty){
        continue;
      }
      List<String> featuresList = [];
      for(var feature in tempExtraFeatures){
        featuresList.add(feature.fields["Feature"]);
      }
      // check if all user features are in the ad features
      if(!featuresFound(featuresList, userExtraFeatures)){
        continue;
      }

      String adDescription = ad.fields["Ad_Description"];
      String brand = ad.fields["Brand"];
      String model = ad.fields["Model"];
      String year = ad.fields["CarYear"].toString();
      String? bodyType = ad.fields["Body_Type"];
      String location = ad.fields["Location"];
      String price = ad.fields["Price"].toString();
      String? minMileage = ad.fields["Odometer_Lower_Range"].toString();
      String? maxMileage = ad.fields["Odometer_Upper_Range"].toString();
      String? paymentMethod = ad.fields["Payment_Method"];
      String? fuelType = ad.fields["Fuel_Type"];
      String? transmission = ad.fields["Transmission"];
      String? engineCapacityLowerRange = ad.fields["Engine_Capacity_Lower_Range"].toString();
      String? engineCapacityUpperRange = ad.fields["Engine_Capacity_Upper_Range"].toString();
      String? color = ad.fields["Color"];
      String? OwnerPhoneNumber = ad.fields["Owner_PhoneNo"];
      String? UserEmailAddress = ad.fields["User_Email_Address"];
      String? review = ad.fields["Review"];
      String? rating = ad.fields["Rating"].toString();
      String? sellingPrice = ad.fields["Selling_Price"].toString();

      // get the owner user name and join date
      Results owner = await _conn.query('select UserName, Join_Date from Owner where PhoneNumber=$OwnerPhoneNumber');
      String? ownerUserName = owner.first.fields["UserName"];
      String? ownerJoinDate = owner.first.fields["Join_Date"].toString().split(' ')[0];

      // if the field is null and optional, leave the field as its default value
      CarAd carAd = CarAd(Ad_Id: adId, Ad_Description: adDescription, Brand: brand, Model: model, CarYear: year, BodyType: bodyType, Location: location, Price: price, Odometer_Lower_Range: minMileage, Odometer_Upper_Range: maxMileage, Payment_Method: paymentMethod, FuelType: fuelType, Transmission: transmission, Engine_Capacity_Lower_Range: engineCapacityLowerRange, Engine_Capacity_Upper_Range: engineCapacityUpperRange, Color: color, Owner_PhoneNumber: OwnerPhoneNumber, User_EmailAddress: UserEmailAddress, Review: review, Rating: rating, Features: featuresList, Owner_Username: ownerUserName, Owner_JoinDate: ownerJoinDate, Selling_Price: sellingPrice);
      adsList.add(carAd);
    }
    return adsList;
  }

  Future<List<List<String>>> getTopSellers() async{
    Results sellers = await _conn.query(
        '''SELECT Owner_PhoneNo, O.UserName, count(*) as numberOfAds, Sum(Price)/count(*) as AvgPricePerCar, Avg(Rating) as AvgRating
        from CarAd CA INNER JOIN Owner O
        on CA.Owner_PhoneNo = O.PhoneNumber
        group by 1,2
        ORDER by 3 DESC
        LIMIT 5;'''
    );
    List<List<String>> sellersList = [];
    for(var seller in sellers){
      List<String> sellerInfo = [];
      String sellerPhoneNo = seller.fields["Owner_PhoneNo"];
      String sellerUsername = seller.fields["UserName"];
      int numberOfAds = seller.fields["numberOfAds"];
      int avgPricePerCar = seller.fields["AvgPricePerCar"].toInt(); // from double to int
      double? avgRating = seller.fields["AvgRating"];

      sellerInfo.add(sellerUsername);
      sellerInfo.add(sellerPhoneNo);
      sellerInfo.add(numberOfAds.toString());
      // add a comma each 3 digits
      sellerInfo.add(avgPricePerCar.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'));
      sellerInfo.add(avgRating.toString());

      sellersList.add(sellerInfo);
    }
    return sellersList;
  }

  Future<List<List<String>>> getSellerInfo(String? phoneNo, String? username) async{
    String phoneNoSelected = "PhoneNumber = '$phoneNo'";
    String usernameSelected = "UserName = '$username'";
    if(phoneNo == null || phoneNo == ''){
      phoneNoSelected = '';
    }
    else if(username == null || username == ''){
      usernameSelected = '';
    }
    else{
      phoneNoSelected = "PhoneNumber = '$phoneNo' and ";
    }
    Results sellers = await _conn.query(
        '''SELECT Owner_PhoneNo, O.UserName, count(*) as numberOfAds, Sum(Price)/count(*) as AvgPricePerYear, Avg(Rating) as AvgRating
        from CarAd CA INNER JOIN Owner O
        on CA.Owner_PhoneNo = O.PhoneNumber
        where $phoneNoSelected $usernameSelected
        group by 1,2
        order by count(*) DESC;'''
    );
    List<List<String>> sellerInfo = [];
    if(sellers.isEmpty){
      return sellerInfo;
    }
    for(var seller in sellers) {
      List<String> currentSeller = [];
      String sellerPhoneNo = seller.fields["Owner_PhoneNo"];
      String sellerUsername = seller.fields["UserName"];
      int? numberOfAds = seller.fields["numberOfAds"];
      int? avgPricePerYear = seller.fields["AvgPricePerYear"]
          .toInt(); // from double to int
      double? avgRating = seller.fields["AvgRating"];

      currentSeller.add(sellerUsername);
      currentSeller.add(sellerPhoneNo);
      currentSeller.add(numberOfAds.toString());
      // add a comma each 3 digits
      currentSeller.add(avgPricePerYear.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'));
      currentSeller.add(avgRating.toString());

      sellerInfo.add(currentSeller);
    }

    return sellerInfo;
  }

  Future<Map<String, Pair<String, String>>> getTopFiveAreas() async{
    Results areas = await _conn.query(
        '''SELECT Location, count(*) as numberOfAds, avg(Price) as AvgPrice
        from CarAd
        group by 1
        ORDER by 2 DESC
        LIMIT 5;'''
    );
    Map<String, Pair<String, String>> areasList = {};
    for(var area in areas){
      String areaName = area.fields["Location"];
      String numberOfAds = area.fields["numberOfAds"].toString();
      String avgPriceString = area.fields["AvgPrice"].toInt().toString();
      avgPriceString = avgPriceString.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      areasList[areaName] = Pair(numberOfAds, avgPriceString);
    }
    return areasList;
  }

  Future<String?> getAvgBrandPrice(String brand, String location) async{

    Results avgPrice = await _conn.query('select avg(Price) as AveragePrice from CarAd where Brand="$brand" and Location="$location"');
    String? avgPriceString = avgPrice.first.fields["AveragePrice"]?.toInt().toString();
    avgPriceString = avgPriceString?.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return avgPriceString;
  }

  Future<String?> getAvgModelPrice(String model, String location) async{
    Results avgPrice = await _conn.query('select avg(Price) as AveragePrice from CarAd where Model="$model" and Location="$location"');
    String? avgPriceString = avgPrice.first.fields["AveragePrice"]?.toInt().toString();
    avgPriceString = avgPriceString?.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return avgPriceString;
  }

  // username is an optional parameter
  Future<List<CarAd>> getOwnerAds(String username, String phoneNum, int page) async{
    Results ads;
    if(phoneNum == '' || phoneNum == 'null'){
      ads = await _conn.query('select * from Owner O inner join CarAd CA on O.PhoneNumber = CA.Owner_PhoneNo where O.UserName="$username" order by Ad_Id limit $page,10');
    }
    else if(username == '' || username == 'null'){
      ads = await _conn.query('select * from CarAd where Owner_PhoneNo="$phoneNum" order by Ad_Id limit $page,10');
    }
    else{
      ads = await _conn.query('select * from Owner O inner join CarAd CA on O.PhoneNumber = CA.Owner_PhoneNo where O.UserName="$username" and O.PhoneNumber = $phoneNum order by Ad_Id limit $page,10');
    }

    List<CarAd> adsList = [];
    for(var ad in ads){
      String adId = ad.fields["Ad_Id"].toString();
      String adDescription = ad.fields["Ad_Description"];
      String brand = ad.fields["Brand"];
      String model = ad.fields["Model"];
      String year = ad.fields["CarYear"].toString();
      String? bodyType = ad.fields["Body_Type"];
      String location = ad.fields["Location"];
      String price = ad.fields["Price"].toString();
      String? minMileage = ad.fields["Odometer_Lower_Range"].toString();
      String? maxMileage = ad.fields["Odometer_Upper_Range"].toString();
      String? paymentMethod = ad.fields["Payment_Method"];
      String? fuelType = ad.fields["Fuel_Type"];
      String? transmission = ad.fields["Transmission"];
      String? engineCapacityLowerRange = ad.fields["Engine_Capacity_Lower_Range"].toString();
      String? engineCapacityUpperRange = ad.fields["Engine_Capacity_Upper_Range"].toString();
      String? color = ad.fields["Color"];
      String? OwnerPhoneNumber = ad.fields["Owner_PhoneNo"];
      String? UserEmailAddress = ad.fields["User_Email_Address"];
      String? review = ad.fields["Review"];
      String? rating = ad.fields["Rating"].toString();
      String? sellingPrice = ad.fields["Selling_Price"].toString();

      // get the owner user name and join date
      Results owner = await _conn.query('select UserName, Join_Date from Owner where PhoneNumber=$OwnerPhoneNumber');
      String ownerUserName = owner.first.fields["UserName"];
      String? ownerJoinDate = owner.first.fields["Join_Date"].toString().split(' ')[0];

      // get the features of the car
      Results features = await _conn.query('select Feature from CarExtraFeatures where Ad_Id=$adId');
      List<String> featuresList = [];
      for(var feature in features){
        featuresList.add(feature.fields["Feature"]);
      }

      // if the field is null and optional, leave the field as its default value
      CarAd carAd = CarAd(Ad_Id: adId, Ad_Description: adDescription, Brand: brand, Model: model, CarYear: year, BodyType: bodyType, Location: location, Price: price, Odometer_Lower_Range: minMileage, Odometer_Upper_Range: maxMileage, Payment_Method: paymentMethod, FuelType: fuelType, Transmission: transmission, Engine_Capacity_Lower_Range: engineCapacityLowerRange, Engine_Capacity_Upper_Range: engineCapacityUpperRange, Color: color, Owner_PhoneNumber: OwnerPhoneNumber, User_EmailAddress: UserEmailAddress, Review: review, Rating: rating, Features: featuresList, Owner_Username: ownerUserName, Owner_JoinDate: ownerJoinDate, Selling_Price: sellingPrice);
      adsList.add(carAd);
    }
    return adsList;

  }

  Future<Map<String, Pair<String, String>>> getTopFiveMakes() async{
    Results topFiveMakes = await _conn.query(
        '''SELECT Brand, count(*) as numberOfAds, avg(Price) as AvgPrice
        from CarAd
        group by 1
        ORDER by 2 DESC
        LIMIT 5;'''
    );
    Map<String, Pair<String, String>> topFiveMakesList = {};
    for(var make in topFiveMakes){
      String makeName = make.fields["Brand"];
      String numberOfAds = make.fields["numberOfAds"].toString();
      String avgPriceString = make.fields["AvgPrice"].toInt().toString();
      avgPriceString = avgPriceString.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      topFiveMakesList[makeName] = Pair(numberOfAds, avgPriceString);
    }
    return topFiveMakesList;
  }

  Future<Map<String, Pair<String, String>>> getTopFiveModels() async{
    Results topFiveModels = await _conn.query(
        '''SELECT Model, count(*) as numberOfAds, avg(Price) as AvgPrice
        from CarAd
        group by 1
        ORDER by 2 DESC
        LIMIT 5;'''
    );
    Map<String, Pair<String, String>> topFiveModelsList = {};
    for(var model in topFiveModels){
      String modelName = model.fields["Model"];
      String numberOfAds = model.fields["numberOfAds"].toString();
      String avgPriceString = model.fields["AvgPrice"].toInt().toString();
      avgPriceString = avgPriceString.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
      topFiveModelsList[modelName] = Pair(numberOfAds, avgPriceString);
    }
    return topFiveModelsList;
  }


  Future<String?> getModelorMakeAverageforRangeYear(String? brand, String? model, String startYear, String endYear) async{
    String modelSelect = "model = '$model'";
    if(model == "null" || model == ""){
      modelSelect = "";
    }
    String brandSelect = "brand = '$brand'";
    if(brand == "null" || brand == ""){
      brandSelect = "";
    }
    Results avgPrice = await _conn.query(
        '''SELECT avg(Price) as AvgPrice
        from CarAd
        where $brandSelect $modelSelect and CarYear between $startYear and $endYear;'''
    );
    String? avgPriceString = avgPrice.first.fields["AvgPrice"]?.toInt().toString();
    avgPriceString = avgPriceString?.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return avgPriceString;
  }

  // add a new car sale
  Future<void> addSale(String carAdId, String userEmailaddress, String Review, String SellingPrice, String Rating) async{
    if(!_isConnected){
      // connect

      await _connect();
    }
    // update not insert
    await _conn.query(
        '''UPDATE CarAd
        SET Review = '$Review', Rating = $Rating, User_Email_Address = '$userEmailaddress', Selling_Price = $SellingPrice
        WHERE Ad_Id = $carAdId;'''
    );
    print("Sale added");
  }
  /*
  * close the connection
  */
  void closeConnection() async{
    await _conn.close();
    _isConnected = false;
    _emailAddress = "";
    _username = "";
  }

  // method to check if all features in the user features list are in the ad features list
  bool featuresFound(List<String> featuresList, List<String> userExtraFeatures) {
    for(int i = 0; i < userExtraFeatures.length; i++){
      if(!featuresList.contains(userExtraFeatures[i])){
        return false;
      }
    }
    return true;
  }

  List<String> parseFilters(String brand, String location, String year, String bodyType, String minPrice, String maxPrice, String minMileage, String maxMileage, String paymentOption) {
    String brandSelect = (brand == '' || brand == 'null') ? '' : 'Brand="$brand"';
    String locationSelect = (location == '' || location == 'null')? '' : 'Location="$location"';
    String yearSelect = (year == '' || year == 'null') ? '' : 'CarYear="$year"';
    String bodyTypeSelect = (bodyType == '' || bodyType == 'null') ? '' : 'Body_Type="$bodyType"';
    String priceSelect = minPrice == '' && maxPrice == '' ? '' : 'Price between $minPrice and $maxPrice';
    String minMileageSelect = minMileage == '' ? '' : 'Odometer_Lower_Range between $minMileage and $maxMileage';
    String maxMileageSelect = maxMileage == '' ? '' : 'Odometer_Upper_Range between $minMileage and $maxMileage';
    String paymentOptionSelect = ((paymentOption == 'Both' || paymentOption == '') ? '' : 'Payment_Method="$paymentOption"');

    List<String> selectList = [brandSelect, locationSelect, yearSelect, bodyTypeSelect, priceSelect, minMileageSelect, maxMileageSelect, paymentOptionSelect];
    bool nonEmptySelectFound = false;
    for(int i = 0; i < selectList.length; i++){
      if(selectList[i] != '' && nonEmptySelectFound){
        selectList[i] = ' and ${selectList[i]}';
      }
      else if(selectList[i] != ''){
        nonEmptySelectFound = true;
      }
    }
    return selectList;
  }
}