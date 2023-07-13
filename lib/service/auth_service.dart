import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:txxme/service/database_service.dart';

import '../helper/helper_function.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login

  Future loginWithUserNameandPassword(String email, String password) async{
    try{
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user!=null){
        return true;
      }
    }
    on FirebaseAuthException catch(e) {
      print(e);
      return e.message;
    }
  }


  //register
  Future registerUserWithEmailandPassword(String fullName, String email, String password) async{
    try{
      User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;
      if(user!=null){
        // call our database service to update the user data
        await DatabaseService(uid: user.uid).savingUserData(fullName, email);

        return true;
      }
    }
    on FirebaseAuthException catch(e) {
      print(e);
      return e.message;
    }
  }





  //signout
  Future signOut() async{
    try{

      await HelperFunction.saveUserLoggedInStatus(false);
      await HelperFunction.saveUserEmailSF("");
      await HelperFunction.saveUserNameSF("");
      await firebaseAuth.signOut();
    }
    catch (e){
      return null;
    }
  }

}