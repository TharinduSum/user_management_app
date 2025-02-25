import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class CreateUserScreen extends StatefulWidget {
  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>(); //mngeValidation
  final ApiService _apiService = ApiService(); //sendDtatoBackend

  bool _isLoading = false; //tackIfReqIsLoading?
  String? _errorMessage; //storeErrorMsg

  //StorUsrInptBeforSubmisin
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  String _occupation = '';
  String _addressLine1 = '';
  String? _addressLine2;
  String _city = '';
  String _country = '';

  //usrCreationLOgic
  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Creataddressobj
      final address = Address(
        addressLineOne: _addressLine1,
        addressLineTwo: _addressLine2,
        city: _city,
        country: _country,
      );

      await _apiService.createUser(
        _username,
        _firstName,
        _lastName,
        _occupation,
        address,
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create user: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New User'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              Text(
                'User Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) => _username = value!,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value!,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
                onSaved: (value) => _lastName = value!,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Occupation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an occupation';
                  }
                  return null;
                },
                onSaved: (value) => _occupation = value!,
              ),
              SizedBox(height: 24),

              // Address Section
              Text(
                'Address Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address Line 1',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
                onSaved: (value) => _addressLine1 = value!,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Address Line 2 (Optional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _addressLine2 = value,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
                onSaved: (value) => _city = value!,
              ),
              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a country';
                  }
                  return null;
                },
                onSaved: (value) => _country = value!,
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _createUser,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Create User'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}