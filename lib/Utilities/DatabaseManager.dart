import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';

class DatabaseManager{
  // Authenticate-Username & Password
  // Register New User
  // Check if the user exists (by checking the emailaddress(the primary key)

  var _conn;
  bool _isConnected = false;

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

  bool get isConnected => _isConnected;

  // Login Authentication

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
      return "Success";
    }
  }

  // Register New User
  Future<void> registerNewUser(String emailAddress, String username, String password, String gender, DateTime dateOfBirth) async{
    if(!_isConnected){
      await _connect();
    }
    try{
      gender = gender == 'Male' ? 'M' : 'F';
      String newDate = DateFormat("yyyy-MM-dd").format(dateOfBirth);

      await _conn.query('insert into User(Email_Address, Username, PASSWORD, Gender, BirthDate) values (?, ?, ?, ?, ?)', [emailAddress, username, password, gender, newDate]);
      await _conn.commit();
    }
    catch(e){
      print(e);
    }
  }

  // Get Brands and models for each brand
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
    return brandModels;
  }

  void closeConnection() async{
    if(!_isConnected){
      return;
    }
    await _conn.close();
    _isConnected = false;
    print("Connection Closed");
  }
}