import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../services/api_service.dart';
import '../utils/country_data.dart';
import '../widgets/searchable_dropdown.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  // Form fields
  late String _firstName;
  late String _lastName;
  late String _occupation;
  late String _addressLine1;
  String? _addressLine2;
  late String _city;
  late String _country;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with user data
    _firstName = widget.user.firstName;
    _lastName = widget.user.lastName;
    _occupation = widget.user.occupation;

    // Initialize address fields if address exists
    if (widget.user.address != null) {
      _addressLine1 = widget.user.address!.addressLineOne;
      _addressLine2 = widget.user.address!.addressLineTwo;
      _city = widget.user.address!.city;
      _country = widget.user.address!.country;
    } else {
      _addressLine1 = '';
      _city = '';
      _country = '';
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {

      final address = Address(
        id: widget.user.address?.id,
        addressLineOne: _addressLine1,
        addressLineTwo: _addressLine2,
        city: _city,
        country: _country,
        userId: widget.user.id,
      );


      await _apiService.updateUser(
        widget.user.id,
        firstName: _firstName,
        lastName: _lastName,
        occupation: _occupation,
        address: address,
      );


      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User updated successfully')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update user: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
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

              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                child: Text(widget.user.username),
              ),
              SizedBox(height: 16),

              TextFormField(
                initialValue: _firstName,
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
                initialValue: _lastName,
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
                initialValue: _occupation,
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
                initialValue: _addressLine1,
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
                initialValue: _addressLine2,
                decoration: InputDecoration(
                  labelText: 'Address Line 2 (Optional)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _addressLine2 = value,
              ),
              SizedBox(height: 16),

              TextFormField(
                initialValue: _city,
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

              SearchableDropdown(
                items: CountryData.countries,
                value: CountryData.countries.contains(_country) ? _country : null,
                hint: 'Select a country',
                label: 'Country',
                validator: (value) {
                  if (value == null || value!.isEmpty) {
                    return 'Please select a country';
                  }
                  return null;
                },
                onChanged: (String? newValue) {
                  setState(() {
                    _country = newValue!;
                  });
                },
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: _updateUser,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Changes'),
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