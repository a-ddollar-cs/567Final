import 'dart:io';
import 'package:braggin_board/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';


class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  File _image;
  final picker = ImagePicker();
  List<String> _labelTexts = [];
  String text;
  Position position;
  String latitude;
  String longitude;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future detectLabels() async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
    final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);


    for (ImageLabel label in cloudLabels) {
      final String text = label.text;
      final String entityId = label.entityId;
      final double confidence = label.confidence;
      print(text);
      _labelTexts.add(text);
    }
    setState(() {

    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }


  Future<String> _uploadFile(filename) async {
    final Reference ref = FirebaseStorage.instance.ref().child('$filename.jpg');
    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg', contentLanguage: 'en');
    final UploadTask uploadTask = ref.putFile(
      _image,
      metadata,
    );

    final downloadURL = await (await uploadTask).ref.getDownloadURL();
    print(downloadURL);
    return downloadURL.toString();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _labelTexts = [];
      } else {
        print('No image selected');
      }
    });
    await detectLabels();
  }

  Widget getLabels(){
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _labelTexts.length,
        itemBuilder: (BuildContext context, int index){
          return Container(
            height: 25,
            child: Center(
              child:
              Text('Suggested Caption: ${_labelTexts[index]}'),
            ),
          );
        }
    );
  }

  Future<void> _addItem(String downloadURL, List<String> labels) async {
    await FirebaseFirestore.instance.collection('photos').add(<String, dynamic>{
      'downloadURL': downloadURL,
      'labels': labels,
    });
  }

  void _upload() async {
    if (_labelTexts != null && _image != null) {
      var uuid = Uuid();
      _labelTexts.insert(0,text);
      _labelTexts.insert(1,latitude);
      _labelTexts.insert(2,longitude);
      final String uid = uuid.v4();
      final String downloadURL = await _uploadFile(uid);
      await _addItem(downloadURL, _labelTexts);
      Navigator.pop(context);
    }
  }

  void validateAndSubmit() async {
    final snackBar = SnackBar(
      content: Text('Uploading Post...'),
    );
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState(){
    super.initState();
    _determinePosition()
        .then((location){
          setState((){
            position = location;
            latitude = position.latitude.toString();
            longitude = position.longitude.toString();
          });
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Post"),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image == null
                  ? Align(
                      alignment: Alignment.center,
                      child: Text('No image selected'))
                  : Image.file(
                      _image,
                      width: 300,
                    ),

              Container(
                margin: const EdgeInsets.all(10.0),
                height: 200.0,
                child: getLabels(),
              ),
              SizedBox(height: 20),
              TextField(
                  keyboardType: TextInputType.multiline,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    text = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter a caption',
                  )),
              SizedBox(height: 20),
              position == null ? CircularProgressIndicator():Text(
                "Position: $latitude, $longitude"
              ),
              ElevatedButton(
                  onPressed: () {
                    _upload();
                    validateAndSubmit();
                  },
                  child: Text(
                    'Submit',
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: "Take Photo",
        child: Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}
