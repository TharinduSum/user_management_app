import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'edit_user_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}
//UsrDtailStateMangement
class _UserDetailScreenState extends State<UserDetailScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
 //fetcngUserData
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _apiService.getUser(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user: $e';
        _isLoading = false;
      });
    }
  }
//upldPrf Pic
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isSaving = true);

      await _apiService.uploadProfilePicture(widget.userId, image.path);

      // Reload user to get updated profile picture
      await _loadUser();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
//delete usr
  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    try {
      await _apiService.deleteUser(widget.userId);
      Navigator.pop(context, true); // Return to previous screen with refresh flag
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete user: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _user != null
            ? Text('${_user!.firstName} ${_user!.lastName}')
            : Text('User Details'),
        actions: [
          if (_user != null) ...[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _isSaving ? null : () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditUserScreen(user: _user!),
                  ),
                );
                if (result == true) {
                  _loadUser(); // Reload user data after edit
                }
              },
              tooltip: 'Edit User',
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _isSaving ? null : _deleteUser,
              tooltip: 'Delete User',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUser,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return Center(child: Text('User not found'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfilePicture(),
          SizedBox(height: 24),

          // UserInformationCard
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User Information',
                      style: Theme.of(context).textTheme.titleLarge),
                  Divider(),
                  SizedBox(height: 8),

                  _infoRow('Username', _user!.username),
                  _infoRow('Name', '${_user!.firstName} ${_user!.lastName}'),
                  _infoRow('Occupation', _user!.occupation),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // AddressCard
          if (_user!.address != null)
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Address',
                            style: Theme.of(context).textTheme.titleLarge),
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: _isSaving ? null : () async {
                            try {
                              setState(() => _isSaving = true);
                              await _apiService.deleteAddress(widget.userId);
                              await _loadUser();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Address deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete address: $e')),
                              );
                            } finally {
                              setState(() => _isSaving = false);
                            }
                          },
                          tooltip: 'Delete Address',
                        ),
                      ],
                    ),
                    Divider(),
                    SizedBox(height: 8),

                    _infoRow('Address Line 1', _user!.address!.addressLineOne),
                    if (_user!.address!.addressLineTwo != null)
                      _infoRow('Address Line 2', _user!.address!.addressLineTwo!),
                    _infoRow('City', _user!.address!.city),
                    _infoRow('Country', _user!.address!.country),
                  ],
                ),
              ),
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No address information available'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 3),
          ),
          child: _user!.profilePicture != null
              ? CircleAvatar(
            backgroundImage: NetworkImage(_user!.profilePicture!),
          )
              : CircleAvatar(
            child: Text(
              _user!.firstName[0] + _user!.lastName[0],
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        if (!_isSaving)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: _pickAndUploadImage,
              tooltip: 'Change profile picture',
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}