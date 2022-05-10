import 'package:flutter/material.dart';

import 'homescreen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primaryColor = const Color(0xff2a7a91);
  Color secondaryColor = const Color(0xff00ebeb);

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
            Container(
              width: screenWidth / 2,
              margin: EdgeInsets.only(top: screenHeight / 50, bottom: screenHeight / 50),
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
              child: Text(
                "Project #1",
                style: TextStyle(
                  fontSize: screenHeight / 30,
                  color: Colors.black54
                ),
              ),
            ),
            Container(
              width: screenWidth / 2,
              margin: EdgeInsets.only(top: screenHeight / 50, bottom: screenHeight / 50),
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
              child: Text(
                "Project #2",
                style: TextStyle(
                    fontSize: screenHeight / 30,
                    color: Colors.black54
                ),
              ),
            ),
            Container(
              width: screenWidth / 2,
              margin: EdgeInsets.only(top: screenHeight / 50, bottom: screenHeight / 50),
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
              child: Text(
                "Project #3",
                style: TextStyle(
                    fontSize: screenHeight / 30,
                    color: Colors.black54
                ),
              ),
            ),
            Container(
              width: screenWidth / 2,
              margin: EdgeInsets.only(top: screenHeight / 50, bottom: screenHeight / 50),
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
              child: Text(
                "Project #4",
                style: TextStyle(
                    fontSize: screenHeight / 30,
                    color: Colors.black54
                ),
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
}
