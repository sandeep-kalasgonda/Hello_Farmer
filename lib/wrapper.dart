import 'package:flutter/material.dart';
import 'package:hello_farmer/models/user.dart';
import 'package:hello_farmer/screens/authenticate_screen.dart';
import 'package:hello_farmer/screens/home_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);

    // return either the Home or Authenticate widget
    if (user == null) {
      return AuthenticateScreen();
    } else {
      return MyHomePage(title: 'Hello Farmer');
    }
  }
}
