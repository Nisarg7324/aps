import 'dart:async';
import 'dart:io';

import 'package:automated_payroll_system/homescreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:image_picker/image_picker.dart';

import 'model/user.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primaryColor = const Color(0xff2a7a91);
  Color secondaryColor = const Color(0xff00ebeb);

  // Location variables
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  // Image variables
  String imageName = "";
  XFile? imagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
              ),
              onPressed: () {
                _shareLiveLocation();
              },
              child: Text(
                "Start Live Location",
                style: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.white
                ),
              ),

            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
              ),
              onPressed: () {
                _stopLiveLocation();
              },
              child: Text(
                "Stop Live Location",
                style: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.white
                ),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
              ),
              onPressed: () {
                imagePicker();
              },
              child: Text(
                "Open Camera",
                style: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.white
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xff99ffff),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2,2),
                  ),
                ]
              ),
              margin: EdgeInsets.fromLTRB(screenWidth / 20, screenHeight / 50, screenWidth / 20, screenHeight / 50),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Image picked: " + imageName,
                  style: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _uploadImage();
              },
              child: Text(
                "Upload Image",
                style: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.white
                ),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
              ),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text(
                  "BACK",
                  style: TextStyle(
                    fontSize: screenHeight / 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

  Future<void> _shareLiveLocation() async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection("Employee")
        .where("email", isEqualTo: User.username)
        .get();

    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection("Employee")
        .doc(querySnap.docs[0].id)
        .collection("Location")
        .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
        .get();

    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentLiveLocation) async {
      await FirebaseFirestore.instance
          .collection("Employee")
          .doc(querySnap.docs[0].id)
          .collection("Location")
          .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
          .set({
        "latitude": currentLiveLocation.latitude,
        "longitude": currentLiveLocation.longitude,
      }, SetOptions(merge: true));
    });

    setState(() {
      User.latitude = docSnap["latitude"];
      User.longitude = docSnap["longitude"];
    });
  }

  _stopLiveLocation() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  imagePicker() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if(image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
      });
    }
  }

  _uploadImage() async {
    QuerySnapshot querySnap = await FirebaseFirestore.instance
        .collection("Employee")
        .where("email", isEqualTo: User.username)
        .get();

    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection("Employee")
        .doc(querySnap.docs[0].id)
        .collection("Image")
        .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
        .get();

    String uploadFileName = DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
    Reference reference = FirebaseStorage.instance.ref().child("Employee").child(uploadFileName);
    UploadTask uploadTask = reference.putFile(File(imagePath!.path));
    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() + "\t" + event.totalBytes.toString());
    });

    await uploadTask.whenComplete(() async {
      var imageURL = await uploadTask.snapshot.ref.getDownloadURL(); // Getting image URL to store it in Firestore database
      // Inserting the acquired URL into the Firestore database
      if(imageURL != null) {
        FirebaseFirestore.instance.collection("Employee")
            .doc(querySnap.docs[0].id)
            .collection("Image")
            .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
            .set({
          "imageURL": imageURL,
        }).then((value) => _showConfirmation("Image Uploaded Successfully!"));

        setState(() {
          User.imgURL = imageURL;
        });
      } else {
        _showConfirmation("Something went wrong!");
      }
    });


  }

  _showConfirmation(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 3),
    ));
  }
}
