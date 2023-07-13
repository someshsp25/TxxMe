import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:txxme/helper/helper_function.dart';
import 'package:txxme/shared/constants.dart';
import 'package:txxme/pages/home_page.dart';
import 'package:txxme/pages/auth/login_page.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb){
    // run the initialisation for the web
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: Constants.apiKey ,
          appId: Constants.appId,
          messagingSenderId: Constants.messagingSenderId,
          projectId: Constants.projectId,
      )
    );
  }
  else{
    await Firebase.initializeApp();
  }


  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _isSignedIn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async{
    await HelperFunction.getUserLoggedInStatus().then((value) {
      if(value!=null){
        setState(() {
          _isSignedIn=value;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
      ),
      debugShowCheckedModeBanner: false,
      home: _isSignedIn ? HomePage() : LoginPage(),
    );
  }
}
