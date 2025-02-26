//managing user data and converting it to/from JSON for API communication.
import 'address.dart';

class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePicture;
  final String occupation;
  final Address? address;


  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
    required this.occupation,
    required this.address,
  });

  //jsonToUsrObj
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
      occupation: json['occupation'],
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  //UserObjtoJson
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'occupation': occupation,
      'address': address?.toJson(),
    };
  }
}