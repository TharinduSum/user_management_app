import 'package:flutter/material.dart';
import '../models/user.dart';

import '../services/api_service.dart';
import 'user_detail_screen.dart';
import 'create_user_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _apiService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateUserScreen()),
          );
          if (result == true) {
            _loadUsers();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add User',
      ),
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
              onPressed: _loadUsers,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Text('No users found. Create a new user to get started.'),
      );
    }

    return ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: user.profilePicture != null
                ? CircleAvatar(
              backgroundImage: NetworkImage(user.profilePicture!),
            )
                : CircleAvatar(
              child: Text(user.firstName[0] + user.lastName[0]),
            ),
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.occupation),
                if (user.address != null)
                  Text('${user.address!.city}, ${user.address!.country}',
                      style: TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserDetailScreen(userId: user.id),
                ),
              );
              if (result == true) {
                _loadUsers();
              }
            },
          ),
        );
      },
    );
  }
}