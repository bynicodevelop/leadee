import 'package:flutter/material.dart';
import 'package:leadeetuto/screens/Guest.dart';
import 'package:leadeetuto/screens/services/UserService.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: RaisedButton(
            onPressed: () async {
              await _userService.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => GuestScreen(),
                ),
                (route) => false,
              );
            },
            child: Text('logout'),
          ),
        ),
      ),
    );
  }
}
