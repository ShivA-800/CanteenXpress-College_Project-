import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:online_food_order_app/apis/foodAPIs.dart';
import 'package:online_food_order_app/models/user.dart';
import 'package:online_food_order_app/notifiers/authNotifier.dart';
import 'package:online_food_order_app/screens/adminHome.dart';
import 'package:online_food_order_app/screens/forgotPassword.dart';
import 'package:online_food_order_app/screens/navigationBar.dart';
import 'package:online_food_order_app/screens/signup.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  final UserModel _user = UserModel();
  bool isSignedIn = false, showPassword = true;

  @override
  void initState() {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    initializeCurrentUser(authNotifier, context);
    super.initState();
  }

  void toast(String data) {
    Fluttertoast.showToast(
        msg: data,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }

  void _submitForm() {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    _formkey.currentState!.save();
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    RegExp regExp =
        RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');
    if (!regExp.hasMatch(_user.email ?? "")) {
      toast("Enter a valid Email ID");
    } else if (_user.password!.length < 8) {
      toast("Password must have atleast 8 characters");
    } else {
      print("Success");
      // login(_user, authNotifier, context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) {
          return NavigationBarPage(selectedIndex: 1);
        }),
      );
    }
  }

  Widget _buildLoginForm() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 120,
        ),
        // Email Text Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              _user.email = value;
            },
            cursorColor: const Color.fromRGBO(255, 63, 111, 1),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Email',
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
              icon: Icon(
                Icons.email,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
            ),
          ),
        ), //EMAIL TEXT FIELD
        const SizedBox(
          height: 20,
        ),
        // Password Text Field
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: TextFormField(
            obscureText: showPassword,
            validator: (value) {
              return null;
            },
            onSaved: (value) {
              _user.password = value;
            },
            keyboardType: TextInputType.visiblePassword,
            cursorColor: const Color.fromRGBO(255, 63, 111, 1),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  icon: Icon(
                    (showPassword) ? Icons.visibility_off : Icons.visibility,
                    color: const Color.fromRGBO(255, 63, 111, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  }),
              border: InputBorder.none,
              hintText: 'Password',
              hintStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
              icon: const Icon(
                Icons.lock,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        // Forgot Password Line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const ForgotPasswordPage();
                  },
                ));
              },
              child: Container(
                child: const Text(
                  'Reset here',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        //LOGIN BUTTON
        GestureDetector(
          onTap: () {
            _submitForm();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Log In",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (BuildContext context) {
                return const AdminHomePage();
              },
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Log In Admin",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(255, 63, 111, 1),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 60,
        ),
        // SignUp Line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Not a registered user?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const SignupPage();
                  },
                ));
              },
              child: Container(
                child: const Text(
                  'Sign Up here',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 138, 120, 1),
              Color.fromRGBO(255, 114, 117, 1),
              Color.fromRGBO(255, 63, 111, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.only(top: 60),
                    child: const Text(
                      'CanteeXpress',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'MuseoModerno',
                      ),
                    ),
                  ),
                ),
                const Text(
                  '',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 17,
                    color: Color.fromRGBO(252, 188, 126, 1),
                  ),
                ),
                _buildLoginForm()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
