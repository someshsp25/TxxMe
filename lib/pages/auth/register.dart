import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:txxme/helper/helper_function.dart';
import 'package:txxme/pages/auth/login_page.dart';
import 'package:txxme/pages/home_page.dart';
import 'package:txxme/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

final formKey = GlobalKey<FormState>();


class _RegisterPageState extends State<RegisterPage> {
  String email = "";
  String password = "";
  String fullName = "";
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
                  'Create your account now to Explore!',
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
                    labelText: "Full Name",
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      fullName = value;
                    });
                  },
                  validator: (value) {
                    if(value!.isEmpty){
                      return 'Name cannot be empty!';
                    }else{
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 15,),
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
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      register();
                    },
                  ),
                ),
                const SizedBox(height: 10,),
                Text.rich(TextSpan(
                  text: "Already have an account?  ",
                  style: const TextStyle(color: Colors.red ,  fontSize: 14,),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Login Here",
                      style: TextStyle(color: Colors.red,fontSize: 14,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        nextScreen(context, LoginPage());
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

  register() async{
    if(formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.registerUserWithEmailandPassword(fullName,email,password).then((value) async{
        if(value == true){
          // saving the shared preferences state
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(fullName);
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

