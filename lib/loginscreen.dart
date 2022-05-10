import 'package:automated_payroll_system/homescreen.dart';
import 'package:automated_payroll_system/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  double screenHeight = 0;
  double screenWidth = 0;

  Color primaryColor = const Color(0xff2a7a91);
  Color secondaryColor = const Color(0xff00ebeb);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Error message string
  //String? errorMessage;

  // Saving login
  late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: secondaryColor,
      body: Column(

        children: [
          isKeyboardVisible ? const SizedBox() : Container(
            height: screenHeight / 2.5,
            width: screenWidth,
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: const Center(
              child: Text("Welcome to APS", style: TextStyle(color: Colors.white, fontSize: 35),),
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: screenHeight / 15, bottom: screenHeight / 15),
              child: Text(
                "Login",
                style: TextStyle(
                    fontSize: screenWidth / 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                ),
              )
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: screenWidth / 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fields for entering e-mail and password
                fieldTitle("Employee E-mail"),
                fieldContent("Enter registered Employee E-mail", emailController, false),
                fieldTitle("Password"),
                fieldContent("Enter your password", passwordController, true),
                // login
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    String email = emailController.text.trim();
                    String password = passwordController.text.trim();

                    if(email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Enter e-mail address!"),
                      ));
                    } else if(password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Enter password!"),
                      ));
                    } else {
                      // checking if entered e-mail is in database or not
                      QuerySnapshot snap = await FirebaseFirestore.instance.collection("Employee")
                          .where("email", isEqualTo: email).get();

                      try {
                        // checking password corresponding to entered e-mail address, whether it is correct or not
                        if(password == snap.docs[0]["password"]) {
                          setState(() {
                            User.isOnline = true;
                          });
                          sharedPreferences = await SharedPreferences.getInstance(); // saving the login instance
                          // saving e-mail address when successful login (for further use) and then go to home screen
                          sharedPreferences.setString("email", email).then((_) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text("Password is incorrect!"),
                          ));
                        }
                      } catch(e) {
                        String errorMsg = "";
                        if(e.toString() == "RangeError (index): Invalid value: Valid value range is empty: 0") {
                          setState(() {
                            errorMsg = "Employee does not exist";
                          });
                        } else {
                          setState(() {
                            errorMsg = "Unknown error occurred";
                          });
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(errorMsg),
                        ));
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: screenHeight / 30),
                    height: screenHeight / 15,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: Center(
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: screenHeight / 40,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget fieldTitle (String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5, left: 5),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.black54,
            fontSize: screenWidth / 25
        ),
      ),
    );
  }

  Widget fieldContent (String hint, TextEditingController controller, bool obscure) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight / 50),
      width: screenWidth,
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
        children: [
          Container(
            width: screenWidth / 8,
            child: Icon(
              obscure ? Icons.vpn_key : Icons.mail,
              color: primaryColor,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                maxLines: 1,
                obscureText: obscure,
                validator: (value) {
                  if(value!.isEmpty) {
                    return controller == emailController ? "Please enter E-mail" : "Please Enter Password";
                  }
                },

                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 60,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
              ),
            )
          )
        ],
      ),
    );
  }

}
