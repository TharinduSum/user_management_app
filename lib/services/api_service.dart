import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';
import '../models/address.dart';

class ApiService { //usrReltedApiOprationsHndlCRUD
  final String baseUrl = 'http://10.0.2.2:8000';//spcialIPtoAccsLoclHost(127)

  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users/'));

    if (response.statusCode == 200) {
      // Parse the response body
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<User> getUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  Future<User> createUser(String username, String firstName, String lastName,
      String occupation, Address address) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'occupation': occupation,
        'address': address.toJson(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<User> updateUser(int userId, {String? firstName, String? lastName,
    String? occupation, Address? address}) async {
    // Build update object with only non-null fields
    final Map<String, dynamic> updateData = {};

    if (firstName != null) updateData['first_name'] = firstName;
    if (lastName != null) updateData['last_name'] = lastName;
    if (occupation != null) updateData['occupation'] = occupation;
    if (address != null) updateData['address'] = address.toJson();

    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updateData),
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  Future<String> uploadProfilePicture(int userId, String filePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/users/$userId/profile-picture'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['filename'];
    } else {
      throw Exception('Failed to upload profile picture: ${response.statusCode}');
    }
  }

  Future<void> deleteAddress(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId/address'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete address: ${response.statusCode}');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }
}