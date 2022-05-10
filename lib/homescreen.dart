import 'dart:async';

import 'package:automated_payroll_system/loginscreen.dart';
import 'package:automated_payroll_system/model/user.dart';
import 'package:automated_payroll_system/projectscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

import 'attendancescreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primaryColor = const Color(0xff2a7a91);
  Color secondaryColor = const Color(0xff00ebeb);

  String checkIn = "--/--";
  String checkOut = "--/--";

  // For checking checkIn time at the beginning of the screen
  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _getRecord() async {
    try {
      QuerySnapshot querySnap = await FirebaseFirestore.instance
          .collection("Employee")
          .where("email", isEqualTo: User.username)
          .get();

      DocumentSnapshot docSnap = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(querySnap.docs[0].id)
          .collection("Record")
          .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
          .get();

      setState(() {
        checkIn = docSnap["checkIn"];
        checkOut = docSnap["checkOut"];
      });
    } catch(e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: secondaryColor,
      body: Column(
        children: [
          Container(
            height: screenHeight / 3,
            width: screenWidth,
            color: primaryColor,
            child: Column(
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: screenHeight / 25, left: screenWidth / 20),
                  child: Text(
                    "Welcome!",
                    style: TextStyle(
                      fontSize: screenHeight / 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: screenWidth / 20, bottom: screenHeight / 30),
                  child: Text(
                    User.username,
                    style: TextStyle(
                      fontSize: screenHeight / 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                employeeInfo("Position: ", "Developer"),
                employeeInfo("Annual Salary (in INR): ", 800000),
                employeeInfo("Date: ", DateFormat("dd-MM-yyyy").format(DateTime.now())),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    return employeeInfo("Time: ", DateFormat("hh:mm:ss a").format(DateTime.now()));
                  }
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: screenHeight / 50),
            child: Text(
              "Today's Activity",
              style: TextStyle(
                fontSize: screenHeight / 40,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: screenHeight / 4,
            width: screenWidth,
            margin: EdgeInsets.all(screenWidth / 40),
            decoration: const BoxDecoration(
              color: Color(0xff99ffff),
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2,2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check-in Time",
                          style: TextStyle(
                            fontSize: screenHeight / 40,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          checkIn,
                          style: TextStyle(
                            fontSize: screenHeight / 20,
                            color: Colors.black54,
                          ),
                        )
                      ],
                    ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Check-out Time",
                        style: TextStyle(
                          fontSize: screenHeight / 40,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        checkOut,
                        style: TextStyle(
                          fontSize: screenHeight / 20,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          checkOut == "--/--" ? Container(
            margin: EdgeInsets.only(left: screenWidth / 20, right: screenWidth / 20, top: screenHeight / 50, bottom: screenHeight / 50),
            child: Builder(
                builder: (context) {
                  final GlobalKey<SlideActionState> key = GlobalKey();

                  return SlideAction(
                    text: checkIn == "--/--" ? "Slide to Check In" : "Slide to Check Out",
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight / 30,
                    ),
                    outerColor: primaryColor,
                    innerColor: secondaryColor,
                    key: key,
                    onSubmit: () async {
                      Timer(const Duration(seconds: 1), () {
                        key.currentState!.reset();
                      });

                      QuerySnapshot querySnap = await FirebaseFirestore.instance
                          .collection("Employee")
                          .where("email", isEqualTo: User.username)
                          .get();

                      DocumentSnapshot docSnap = await FirebaseFirestore.instance
                          .collection("Employee")
                          .doc(querySnap.docs[0].id)
                          .collection("Record")
                          .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
                          .get();

                      // To check whether user has already checked in or not
                      try {
                        // If already checked in and slided again, then it is for checking out
                        String checkIn = docSnap["checkIn"];

                        setState(() {
                          checkOut = DateFormat("hh:mm").format(DateTime.now());
                        });

                        await FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(querySnap.docs[0].id)
                            .collection("Record")
                            .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
                            .set({
                          "checkIn": checkIn,
                          "checkOut": DateFormat("hh:mm").format(DateTime.now()),
                        });
                      } catch(e) {
                        // If not checked in and slided, then it is for checking in
                        setState(() {
                          checkIn = DateFormat("hh:mm").format(DateTime.now());
                        });

                        await FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(querySnap.docs[0].id)
                            .collection("Record")
                            .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
                            .set({
                          "checkIn": DateFormat("hh:mm").format(DateTime.now()),
                        });
                      }
                    },
                  );
                }
            ),
          ) : Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: screenHeight / 40),
            child: Text(
              "You have already checked out!",
              style: TextStyle(
                fontSize: screenHeight / 40,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: screenWidth / 20, right: screenWidth / 20, top: screenWidth / 10, bottom: screenWidth / 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendanceScreen()));
                        },
                        child: Text(
                          "Attendance",
                          style: TextStyle(
                              fontSize: screenHeight / 40,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProjectsScreen()));
                        },
                        child: Text(
                          "Projects",
                          style: TextStyle(
                              fontSize: screenHeight / 40,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                      children: [
                        TextButton(
                        onPressed: () {
                          //set state : user.isonline = false
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: screenHeight / 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ]
                ))
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget employeeInfo (String field, var data) {
    return Container(
        margin: EdgeInsets.only(left: screenWidth / 20, top: screenHeight / 200),
        child: Row(
          children: [
            Text(
              field,
              style: TextStyle(
                fontSize: screenHeight / 40,
                color: Colors.yellowAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              data.toString(),
              style: TextStyle(
                fontSize: screenHeight / 40,
                color: Colors.white,
              ),
            )
          ],
        )
    );
  }
}
