import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post.dart';




class Nav extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavState();
  }
}
class _NavState extends State<Nav> {
  final _auth = FirebaseAuth.instance;

  int selectedPage = 0;
  final _pageOptions = [Home(), Mapper(), Post()];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: new Image.asset('assets/logo.png'),
          actions: <Widget>[
            TextButton(
                child: Text("Logout"),
                onPressed: () {
                  _auth.signOut();
                  Navigator.pop(context);
                  //Implement logout functionality
                }),
          ],
          title: Text("BragginBoard"),
          backgroundColor: Colors.lightGreen,
        ),
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: (int index) {
            setState(() {
              selectedPage = index;
            });
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text('Home')),
            BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded), title: Text('Map')),

          ],
        ),
      ),
    );
  }
}