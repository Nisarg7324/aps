import 'package:automated_payroll_system/homescreen.dart';
import 'package:automated_payroll_system/loginscreen.dart';
import 'package:automated_payroll_system/model/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

// TODO: Logout

Future<void> main() async {
  // initializing firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:const KeyboardVisibilityProvider(
          child: LoginStateCheck(),
      ),
    );
  }
}

// To check if shared preference ID is available or not
// If not available, then start the app with login screen
class LoginStateCheck extends StatefulWidget {
  const LoginStateCheck({Key? key}) : super(key: key);

  @override
  State<LoginStateCheck> createState() => _LoginStateCheckState();
}

class _LoginStateCheckState extends State<LoginStateCheck> {
  bool userOnlineState = false; // set false by default
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    _getCurrentUserState();
    _requestLocationPermission();
  }

  void _getCurrentUserState() async {
    sharedPreferences = await SharedPreferences.getInstance();

    try {
      if(sharedPreferences.getString("email") != null) {
        setState(() {
          User.username = sharedPreferences.getString("email")!; // saving employee e-mail address to the class
          userOnlineState = true;
          User.isOnline = userOnlineState;
        });
      }
    } catch (e) {
      setState(() {
        userOnlineState = false;
        User.isOnline = userOnlineState;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If user is online then go to home screen else login screen
    return User.isOnline ? const HomeScreen() : const LoginScreen();
  }

  _requestLocationPermission() async {
    var permissionStatus = await Permission.location.request();
    if (permissionStatus.isGranted) {
      print("done");
    } else if (permissionStatus.isDenied) {
      _requestLocationPermission();
    } else if (permissionStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
