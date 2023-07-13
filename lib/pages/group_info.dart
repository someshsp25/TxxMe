import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:txxme/pages/home_page.dart';
import 'package:txxme/service/database_service.dart';
import 'package:txxme/widgets/widgets.dart';


class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo({Key? key, required this.adminName,
    required this.groupName,
    required this.groupId})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMember();
  }

  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }

  getMember() async{
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getGroupMember(widget.groupId).then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_")+1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191C20),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text('Groups Information', style: TextStyle(fontSize: 22),),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Exit",
                        textAlign: TextAlign.center,
                      ),
                      content: Text("Are you sure you want to Exit Group?"),
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
                          DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).toggleGroupJoin(widget.groupId, getName(widget.adminName), widget.groupName).whenComplete(() {
                            nextScreenReplace(context, HomePage());
                          });
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
              icon: Icon(Icons.exit_to_app_outlined)),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.blue.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(widget.groupName.substring(0,1).toUpperCase() , style: TextStyle(fontSize: 25, color: Colors.white),),
                  ),
                  SizedBox(width: 20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Group:  ${widget.groupName}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Admin:  ${getName(widget.adminName)}",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }
  memberList(){
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          // make some checks
          if(snapshot.hasData){
            if(snapshot.data['members'] !=null){
              if(snapshot.data['members'].length!=0){
                return ListView.builder(
                  itemCount: snapshot.data['members'].length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: Text(getName(snapshot.data['members'][index]).substring(0,1).toUpperCase() ,style: TextStyle(color: Colors.white , fontSize: 25),),
                        ),
                        title: Text(getName(snapshot.data['members'][index]),style: TextStyle(color: Colors.white , fontSize: 20),),
                        subtitle: Text(getId(snapshot.data['members'][index]),style: TextStyle(color: Colors.white , fontSize: 20 ),),
                      ),
                    );
                  },
                );
              }else{
                return Center(
                  child: Text('NO MEMBER',style: TextStyle(color: Colors.white , fontSize: 30 )),
                );
              }
            }else
            {
              return Center(
                child: Text('NO MEMBER',style: TextStyle(color: Colors.white , fontSize: 30 )),
              );
            }
          }
          else{
            return Center(child: CircularProgressIndicator(color: Colors.blue,),);
          }
        },
      ),
    );
  }
}
