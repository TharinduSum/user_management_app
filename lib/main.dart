import 'package:flutter/material.dart';
import 'screens/user_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        //defltDesignLngugtoBulApps_ltstVrsinGoglMateDesSystm
        useMaterial3: true,
      ),
      home: UserListScreen(),
    );
  }
}