import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hello_farmer/firebase_options.dart';
import 'package:hello_farmer/models/user.dart';
import 'package:hello_farmer/screens/splash_screen.dart';
import 'package:hello_farmer/services/auth_service.dart';
import 'package:hello_farmer/wrapper.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'Hello Farmer',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
