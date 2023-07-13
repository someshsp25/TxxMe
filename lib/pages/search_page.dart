import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:txxme/helper/helper_function.dart';
import 'package:txxme/service/database_service.dart';
import 'package:txxme/widgets/widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched=false;
  String userName = "";
  var isJoined = false;
  User? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async{
    await HelperFunction.getUserNameFromSF().then((value) async{
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
    print(user!.uid);
  }


  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  String getName(String r) {
    return r.substring(r.indexOf("_")+1);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF191C20),
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Search',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.black54,
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search groups here...',
                        hintStyle: TextStyle(color: Colors.white , fontSize: 16),
                        labelText: 'Search',
                        focusColor: Colors.blue,
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white ,width: 5)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue,width: 5)),
                      ),
                      controller: searchController,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                ),
                SizedBox(width: 20,),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: IconButton(
                    onPressed: () {
                      initiateSearchMethod();
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          isLoading==true ? Center(child: CircularProgressIndicator(color: Colors.blue,),) : groupList(),
        ],
      ),
    );
  }
  initiateSearchMethod() async{
    if(searchController.text.isNotEmpty){
      setState(() {
        isLoading=true;
      });
      await DatabaseService().searchByName(searchController.text).then((snapshot){
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList(){
    return hasUserSearched ? ListView.builder(
      shrinkWrap: true,
      itemCount: searchSnapshot!.docs.length,
      itemBuilder: (context, index) {
        return groupTile(
          userName,
          searchSnapshot!.docs[index]['groupID'],
          searchSnapshot!.docs[index]['groupName'],
          searchSnapshot!.docs[index]['admin'],
        );
      },
    ) :
        Container();
  }


  joinedOrNot(String userName, String groupId, String groupname, String admin) async{
    await DatabaseService(uid: user!.uid).isUserJoined(groupname, groupId, userName).then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }



  Widget groupTile(String userName, String groupId , String groupname , String admin){
    // to check whether user already exist in that group

    joinedOrNot(userName,groupId,groupname,admin);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.blue,
        child: Text(
          groupname.substring(0,1).toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      ),
      title: Text(
        groupname,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        'Admin: ${getName(admin)}',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      trailing: InkWell(
        onTap: () async{
          await DatabaseService(uid: user!.uid).toggleGroupJoin(groupId, userName, groupname);
          if(isJoined){
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.green, "You joined the group!");

          }
          else{
            setState(() {
              isJoined = !isJoined;
            });
            showSnackbar(context, Colors.red, "You Left the group! ");


          }
        },
        child: isJoined ?
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 3),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Joined',style: TextStyle(color: Colors.white),),
        ) :
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 3),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text('Join Now',style: TextStyle(color: Colors.white),),
        ) ,
      ),
    );
  }
}
