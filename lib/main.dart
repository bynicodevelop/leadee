import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:leadeetuto/screens/Guest.dart';
import 'package:leadeetuto/screens/dashboard/Home.dart';
import 'package:leadeetuto/screens/services/UserService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(App());
}

class App extends StatelessWidget {
  UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leadee',
      home: StreamBuilder(
        stream: _userService.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return HomeScreen();
            }

            return GuestScreen();
          }

          return SafeArea(
            child: Scaffold(
              body: Center(
                child: Text('Loading...'),
              ),
            ),
          );
        },
      ),
    );
  }
}
