import 'package:flutter/material.dart';

class CarAd{
  // ignore_for_file: non_constant_identifier_names
  late String? Ad_Id;
  late String? Ad_Description;
  late String? Brand;
  late String? Model;
  late int? CarYear;
  late int? Price;
  late String? Location;
  late String? Payment_Method;
  late int? Odometer_Lower_Range;
  late int? Odometer_Upper_Range;
  late String? BodyType;
  late List<String>? Features;
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
  });
}