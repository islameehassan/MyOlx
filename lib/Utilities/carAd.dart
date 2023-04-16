import 'package:flutter/material.dart';

class CarAd{
  // ignore_for_file: non_constant_identifier_names
  String? Ad_Id;
  String? Ad_Description;
  String? Brand;
  String? Model;
  String? CarYear;
  String? Price;
  String? Location;
  String? Payment_Method;
  String? Odometer_Lower_Range;
  String? Odometer_Upper_Range;
  String? BodyType;
  String? FuelType;
  String? Transmission;
  String? Color;
  String? Engine_Capacity_Lower_Range;
  String? Engine_Capacity_Upper_Range;
  String? Owner_PhoneNumber;
  String? User_EmailAddress;
  String? Selling_Price;
  String? Review;
  String? Rating;
  String? Owner_Username;
  String? Owner_JoinDate;
  List<String>? Features;
  // Constructor
  CarAd({
    required this.Ad_Id,
    required this.Ad_Description,
    required this.Brand,
    required this.Model,
    required this.CarYear,
    required this.Price,
    required this.Location,
    this.Payment_Method,
    required this.Odometer_Lower_Range,
    required this.Odometer_Upper_Range,
    required this.BodyType,
    required this.Features,
    this.FuelType = 'Not Specified',
    // all remaining fields are optional
    this.Transmission = 'Not Specified',
    this.Color = 'Not Specified',
    this.Engine_Capacity_Lower_Range = 'Not Specified',
    this.Engine_Capacity_Upper_Range = 'Not Specified',
    this.Owner_PhoneNumber = 'Not Specified',
    this.User_EmailAddress = 'Not Specified',
    this.Selling_Price = 'Not Specified',
    this.Review = 'Not Specified',
    this.Rating = 'Not Specified',
    this.Owner_Username = 'Not Specified',
    this.Owner_JoinDate = 'Not Specified',
  });
}