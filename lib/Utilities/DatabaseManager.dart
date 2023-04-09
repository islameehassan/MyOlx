import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';

/*
* This class is responsible for connecting to the database and performing all the database operations
*/

class DatabaseManager{
  var _conn;
  bool _isConnected = false;
  String _emailAddress = "";
  String _username = "";
  Map<String, List<String>> _brandModels = {};
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
  String get emailAddress => _emailAddress;
  String get username => _username;
  Map<String, List<String>> get brandModels => _brandModels;
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

      await _conn.query('insert into User(Email_Address, Username, PASSWORD, Gender, BirthDate) values (?, ?, ?, ?, ?)', [emailAddress, username, password, gender, newDate]);
      _emailAddress = emailAddress;
      _username = username;
    }
    catch(e){
      print(e);
    }
  }

  /*
  * get the brands and models
  */
  Future<Map<String, List<String>>> getBrands() async{
    if(!_isConnected){
      await _connect();
    }
    Results brands = await _conn.query('select distinct(Brand), Model from CarAd');
    Map<String, List<String>> brandModels = {};
    for(var brand in brands){
      String brandName = brand.fields["Brand"];
      String modelName = brand.fields["Model"];
      if(modelName != 'Other') {
        if (brandModels.containsKey(brandName)) {
          brandModels[brandName]!.add(modelName);
        }
        else {
          brandModels[brandName] = [modelName];
        }
      }
    }
    _brandModels = brandModels;
    return brandModels;
  }

  Future<List<String>> getLocations() async{
    Results locations = await _conn.query('select distinct(Location) from CarAd order by 1');
    List<String> locationsList = [];
    for(var location in locations){
      locationsList.add(location.fields["Location"]);
    }
    _locations = locationsList;
    return locationsList;
  }

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
  * upload the user preferences
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
  * close the connection
  */
  void closeConnection() async{
    await _conn.close();
    _isConnected = false;
    _emailAddress = "";
    _username = "";
  }
}