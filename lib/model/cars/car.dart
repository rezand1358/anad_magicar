import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class Car {
  int carId;
  int carModelDetailId;
  String productDate;
  int colorTypeConstId;
  String pelaueNumber;
  int deviceId;
  int totlaDistance;
  int carStatusConstId;
  String description;
  bool isActive;
  String brandTitle;
  String carModelTitle;
  String carModelDetailTitle;
  String colorTitle;
  int businessUnitId;
  int owner;
  String version;
  String createdDate;

  Car({
    @required this.carId,
    @required this.carModelDetailId,
    @required this.productDate,
    @required this.colorTypeConstId,
    @required this.pelaueNumber,
    @required this.deviceId,
    @required this.totlaDistance,
    @required this.carStatusConstId,
    @required this.description,
    @required this.isActive,
    @required this.brandTitle,
    @required this.carModelTitle,
    @required this.carModelDetailTitle,
    @required this.businessUnitId,
    @required this.colorTitle,
    @required this.owner,
    @required this.version,
    @required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'CarId': this.carId,
      'CarModelDetailId': this.carModelDetailId,
      'ProductDate': this.productDate,
      'ColorTypeConstId': this.colorTypeConstId,
      'ColorTitle': this.colorTitle,
      'PlaqueNumber': this.pelaueNumber,
      'DeviceId': this.deviceId,
      'TotlaDistance': this.totlaDistance,
      'CarStatusConstId': this.carStatusConstId,
      'Description': this.description,
      'CarModelDetailTitle': this.carModelDetailTitle,
      'CarModelTitle': this.carModelTitle,
      'IsActive': this.isActive,
      'BrandTitle': this.brandTitle,
      'BusinessUnitId': this.businessUnitId,
      'Owner': this.owner,
      'Version': this.version,
      'CreatedDate': this.createdDate,
    };
  }

  factory Car.fromMap(Map<String, dynamic> map) {
    return new Car(
      carId: map['CarId'] ,
      carModelDetailId: map['CarModelDetailId'] ,
      productDate: map['ProductDate'] ,
      colorTypeConstId: map['ColorTypeConstId'] ,
      colorTitle: map['ColorTitle'],
      pelaueNumber: map['PlaqueNumber'] ,
      deviceId: map['DeviceId'],
      brandTitle: map['BrandTitle'],
      carModelTitle: map['CarModelTitle'],
      carModelDetailTitle: map['CarModelDetailTitle'],
      totlaDistance: map['TotlaDistance'],
      carStatusConstId: map['CarStatusConstId'] ,
      description: map['Description'] ,
      isActive: map['IsActive'] ,
      businessUnitId: map['BusinessUnitId'] ,
      owner: map['Owner'] ,
      version: map['Version'] ,
      createdDate: map['CreatedDate'] ,
    );
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(carId: json["CarId"],
      carModelDetailId: json["CarModelDetailId"],
      productDate: json["ProductDate"],
      colorTypeConstId: json["ColorTypeConstId"],
      pelaueNumber: json["PlaqueNumber"],
      deviceId: json["DeviceId"],
      carModelTitle: json["CarModelTitle"],
      carModelDetailTitle: json["CarModelDetailTitle"],
      totlaDistance:json["TotlaDistance"],
      carStatusConstId: json["CarStatusConstId"],
      description: json["Description"],
      brandTitle: json["BrandTitle"],
      colorTitle: json["ColorTitle"],
      isActive: json["IsActive"],
      businessUnitId: json["BusinessUnitId"],
      owner: json["Owner"],
      version: json["Version"],
      createdDate: json["CreatedDate"],);
  }

  Map<String, dynamic> toJson() {
    return {
      "CarId": this.carId,
      "CarModelDetailId": this.carModelDetailId,
      "ProductDate": this.productDate,
      "ColorTypeConstId": this.colorTypeConstId,
      "PlaqueNumber": this.pelaueNumber,
      "DeviceId": this.deviceId,
      "TotlaDistance": this.totlaDistance,
      "CarStatusConstId": this.carStatusConstId,
      "Description": this.description,
      "IsActive": this.isActive,
      "ColorTitle": this.colorTitle,
      "BrandTitle": this.brandTitle,
      "CarModelTitle": this.carModelTitle,
      "CarModelDetailTitle": this.carModelDetailTitle,
      "BusinessUnitId": this.businessUnitId,
      "Owner": this.owner,
      "Version": this.version,
      "CreatedDate": this.createdDate,
    };
  }
  Map<String, dynamic> toJsonForSaveCar() {
    return {
      "brandId": this.carId,
      "modelId": this.carModelDetailId,
      "tip": this.productDate,
      "pelak": this.colorTypeConstId,
      "PlaqueNumber": this.pelaueNumber,
      "DeviceId": this.deviceId,
      "TotlaDistance": this.totlaDistance,
      "BrandTitle": this.brandTitle,
      "ColorTitle": this.colorTitle,
      "CarModelTitle": this.carModelTitle,
      "CarModelDetailTitle": this.carModelDetailTitle,
      "CarStatusConstId": this.carStatusConstId,
      "Description": this.description,
      "IsActive": this.isActive,
      "BusinessUnitId": this.businessUnitId,
      "Owner": this.owner,
      "Version": this.version,
      "CreatedDate": this.createdDate,
    };
  }

}
