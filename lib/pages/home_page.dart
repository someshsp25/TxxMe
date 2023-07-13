import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:txxme/helper/helper_function.dart';
import 'package:txxme/pages/auth/login_page.dart';
import 'package:txxme/pages/profile_page.dart';
import 'package:txxme/pages/search_page.dart';
import 'package:txxme/service/auth_service.dart';
import 'package:txxme/service/database_service.dart';
import 'package:txxme/widgets/group_tile.dart';
import 'package:txxme/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String userName = "";
  String email = "";
  Stream? groups;
  bool _isLoading=false;
  String groupName = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettingUserData();
  }

  // string manipulation
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  String getName(String res){
    return res.substring(res.indexOf("_")+1);
  }

  gettingUserData() async{
    await HelperFunction.getUserEmailFromSF().then((value) {
      if(value!=null){
        setState(() {
          email = value;
        });
      }
    });
    await HelperFunction.getUserNameFromSF().then((value) {
      if(value!=null){
        setState(() {
          userName = value;
        });
      }
    });
    // getting list of snap shot in out stream
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserGroups().then((snapshot) {
      setState(() {
        groups=snapshot;
      });
    });
  }

  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191C20),
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed:() {
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(
                Icons.search,
              ),
          ),
        ],
        elevation: 50,
        centerTitle: true,
        title: Text(
          'Groups',
          style: TextStyle(
            fontSize: 30,
            fontWeight:FontWeight.w400,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.black,
            ),
            const SizedBox(height: 15,),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30,),
            const Divider(height: 20,color: Colors.black54,),
            ListTile(
              onTap: () {},
              selectedColor: Colors.blue,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: Icon(Icons.group),
              title:  Text('Groups',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(context, ProfilePage(email: email,userName: userName,));
              },
              selectedColor: Colors.blue,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: Icon(Icons.person),
              title:  Text('Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Logout",
                        textAlign: TextAlign.center,
                      ),
                      content: Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(onPressed: () {
                          Navigator.pop(context);
                        },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                        IconButton(onPressed: () async{
                          await authService.signOut();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage(),), (route) => false);
                        },
                          icon: Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                      ],
                    );
                  },);
              },
              selectedColor: Colors.blue,
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: Icon(Icons.logout),
              title:  Text('Log-Out',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 10,
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

    );
  }
  popUpDialog(BuildContext context) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(
          'Create a Group',
          textAlign: TextAlign.left,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _isLoading==true ? Center(
              child: CircularProgressIndicator(color: Colors.blue),
      )
          : TextField(
              onChanged: (value) {
                groupName=value;
              },
              decoration: textInputDecoration.copyWith(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).pop();
          },
            icon: Icon(
              Icons.cancel,
              color: Colors.red,
              size: 45,
            ),
          ),
          IconButton(onPressed: () async{
            if(groupName!=""){
              DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createGroup(userName, FirebaseAuth.instance.currentUser!.uid, groupName).whenComplete(() => () {
              _isLoading=false;
              });
              Navigator.of(context).pop();
              showSnackbar(context, Colors.green, "Group created successfully!");
            }
            else{
              showSnackbar(context, Colors.red, "Group name cannot be empty!");
            }
          },
            icon: Icon(
              Icons.check,
              color: Colors.green,
              size: 45,
            ),
          ),
        ],
      );
    },);
  }
  groupList(){
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if(snapshot.hasData){
          if(snapshot.data['groups'] !=null){
            if(snapshot.data['groups'].length!=0){
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  return GroupTile(userName: snapshot.data['fullName'], groupId: getId(snapshot.data['groups'][index]), groupName: getName(snapshot.data['groups'][index]));
                },
              );
            }else{
              return noGroupWidget();
            }
          }else
            {
              return noGroupWidget();
            }
        }
        else{
          return Center(child: CircularProgressIndicator(color: Colors.blue,),);
        }
      },
    );
  }

  noGroupWidget(){
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              child: Icon(Icons.add_circle,color: Colors.white,size: 75,),
              onTap: () {
                popUpDialog(context);
              },
            ),
            SizedBox(height: 20),
            Text(
              textAlign: TextAlign.center,
              'You Do not have any group joined! \nYou can Create group by clicking on add button or\n You can Search for groups!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
