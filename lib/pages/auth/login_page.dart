import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:txxme/pages/auth/register.dart';
import 'package:txxme/service/auth_service.dart';
import 'package:txxme/service/database_service.dart';
import 'package:txxme/widgets/widgets.dart';

import '../../helper/helper_function.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final formKey = GlobalKey<FormState>();

class _LoginPageState extends State<LoginPage> {

  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191C20),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Colors.blue,),) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'TxxMe',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10,),
                const Text(
                  textAlign: TextAlign.center,
                  'Connect. Chat. TxxME: Where Conversations Come Alive!',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Container(
                  child: Stack(
                    children: <Widget>[
                      Image.asset('assets/images/login2.png'),
                      Image.asset('assets/images/login1.png'),
                    ],
                  ),
                ),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(
                        Icons.email,
                      color: Colors.white,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  validator: (value) {
                    return RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value!)
                        ? null
                        : "Please enter a valid email";
                  },
                ),
                const SizedBox(height: 15,),
                TextFormField(
                  obscureText: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: "Password",
                    prefixIcon: Icon(
                        Icons.lock,
                      color: Colors.white,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (val) {
                    if (val!.length < 6) {
                      return "Password must be at least 6 characters";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                const SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0))
                          )
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      login();
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                Text.rich(TextSpan(
                  text: "Don't have an account?  ",
                  style: const TextStyle(color: Colors.red ,  fontSize: 14,),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Register Here",
                      style: TextStyle(color: Colors.red,fontSize: 14,
                      decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        nextScreen(context, RegisterPage());
                      },
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }



  login() async{
    if(formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.loginWithUserNameandPassword(email,password).then((value) async{
        if(value == true){
          QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);
          // saving the values to our shared preferences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0]['fullName']);


          nextScreenReplace(context, HomePage());
        }
        else {
          showSnackbar(context, Colors.red  , value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}


