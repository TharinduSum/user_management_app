//handling address data and converting it to/from JSON for API communication.
class Address {
  final int? id;
  final String addressLineOne;
  final String? addressLineTwo;
  final String city;
  final String country;
  final int? userId;

  Address({
    this.id,
    required this.addressLineOne,
    this.addressLineTwo,
    required this.city,
    required this.country,
    this.userId,
  });

  //jsonToAddressObjct
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      addressLineOne: json['address_line_one'],
      addressLineTwo: json['address_line_two'],
      city: json['city'],
      country: json['country'],
      userId: json['user_id'],
    );
  }

  //AddrObjToJson
  Map<String, dynamic> toJson() {
    return {
      'address_line_one': addressLineOne,
      'address_line_two': addressLineTwo,
      'city': city,
      'country': country,
    };
  }
}