import 'package:braggin_board/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


User loggedinUser;

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError){
            print(snapshot.error);
            return Text("Something Went Wrong");
          }
          if (snapshot.connectionState == ConnectionState.done){
            return HomeScreen(title: "Braggin Board");
          }
          return CircularProgressIndicator();
        }
    );
  }
}



class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  FixedExtentScrollController scrollController;

  @override
  void initState() {
    scrollController = FixedExtentScrollController();
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }


  //using this function you can use the credentials of the user
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }



  // ignore: non_constant_identifier_names
  Widget photo_widget(AsyncSnapshot<QuerySnapshot> snapshot, index){
    try{
      return Column(
        children: [
          Image.network(snapshot.data.docs[index]['downloadURL'], height: 250),
          ListTile(title: Text(
              snapshot.data.docs[index]['labels'][0],
              textAlign: TextAlign.center,
          ))
        ],
      );
    }
    catch(e){
      print(e);
      return ListTile(title: Text("Error: " + e.toString()));
    }
  }

  Widget getPhotos(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("photos").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error);
          }
          if(!snapshot.hasData){
            return Text("Loading...");
          }
          if(snapshot.hasData){
            print("Snapshot Length ${snapshot.data.docs.length}");
            return Expanded(
              child: Scrollbar(
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index){
                      return photo_widget(snapshot, index);
                    }
                ),
              )
            );
          }
          return CircularProgressIndicator();
        }
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          getPhotos()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, new MaterialPageRoute(
              builder: (context) => new Post())
          );
        },
        child: Icon(Icons.add),
      ),

    );
  }
}