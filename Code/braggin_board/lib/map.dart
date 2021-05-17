import 'dart:io';
import 'package:braggin_board/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class Mapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("photos").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError){
            print(snapshot.error);
          }
          if(!snapshot.hasData){
            print("Loading...");
          }
          if(snapshot.hasData){
            print("Snapshot Length ${snapshot.data.docs.length}");
            return Map();
          }
          return CircularProgressIndicator();
        }
    );
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  GoogleMapController mapController;
  double latitude;
  double longitude;
  String strLat;
  String strLong;


  final LatLng _center = const LatLng(39.728493, -121.837479);
  List<Marker> myMarker = [];


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateData();
  }

void _updateData()
{
  print("Update here");
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: Set.from(myMarker),
          onTap: _handleTap,
        ),
      ),
    );
  }




  _handleTap(LatLng tappedPoint) {
    setState(() {
      myMarker.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
        )

      );
    });

  }


}
