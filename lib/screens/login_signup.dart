import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrition_app/screens/dashboard.dart';
import 'package:nutrition_app/screens/delivery_person_dashboard.dart';
import 'package:nutrition_app/screens/loading.dart';
import 'package:nutrition_app/screens/nutricarrier/dashboard.dart';
import 'package:nutrition_app/screens/nutrichef/dashboard.dart';
import 'package:nutrition_app/screens/restartaurant_dashboard.dart';
import 'package:nutrition_app/widgets/auth_checker.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firebaseAuth = FirebaseAuth.instance;

class LoginSignup extends StatefulWidget {
  const LoginSignup({super.key, required this.role});

  final role;

  @override
  State<LoginSignup> createState() => _LoginSignupState();
}

class _LoginSignupState extends State<LoginSignup> {
  late Color primaryColor;
  late IconData roleIcon;
  late String title;

  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredUserName = '';
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLogin = false;
  bool _togglePassword = true;

  String? imagePath = '';

  @override
  void initState() {
    super.initState();
    if (widget.role == 'NutriMate') {
      title = 'NutriMate';
      roleIcon = Icons.person;
      imagePath = 'assets/foods/mate.png';
      primaryColor = Colors.lightGreen;
    } else if (widget.role == 'NutriChef') {
      imagePath = 'assets/foods/chef.png';
      title = 'NutriChef';
      roleIcon = Icons.restaurant;
      imagePath = 'assets/foods/chef.png';
      primaryColor = Colors.orange;
    } else if (widget.role == 'NutriCarrier') {
      title = 'NutriCarrier';
      roleIcon = Icons.delivery_dining;
      imagePath = 'assets/foods/carrier.png';
      primaryColor = Colors.blue;
    } else {
      title = 'Welcome!';
      roleIcon = Icons.person;
      primaryColor = Colors.grey;
    }
  }

  Future<void> authenticateFirebase(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isLogin && _enteredUserName.trim().isNotEmpty) {
        final _authResponse =
            await _firebaseAuth.createUserWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_authResponse.user!.uid)
            .set({
          'name': _enteredUserName,
          'email': _enteredEmail,
          'role': title,
          'password': _enteredPassword,
          'uid': _authResponse.user!.uid,
        });
        Navigator.of(context).pop();
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => AuthChecker()),
        // );
      } else {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword)
            .then((_) {
          validateUserRoleAndNavigate(
              context, widget.role); // Pass the expected role to compare
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> signInWithGoogleAndSaveToFirestore(
      BuildContext context, String expectedRole) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await GoogleSignIn().signOut();
      // Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        print("Google sign-in was cancelled");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        final uid = user.uid;
        final name = user.displayName ?? "No Name";
        final email = user.email ?? "No Email";

        final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
        final snapshot = await userDoc.get();

        if (!snapshot.exists) {
          print("User does not exist. Writing new user data...");
          await userDoc.update({
            'uid': uid,
            'name': name,
            'email': email,
            'role': expectedRole,
            'isSubmitted': false,
          });
          print("Firestore write successful for new user.");
        } else {
          print("User already exists in Firestore: ${snapshot.data()}");
        }

        // Now validate role
        final data = (await userDoc.get()).data();
        if (data != null && data['role'] != expectedRole) {
          await FirebaseAuth.instance.signOut();
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'You are trying to log in through the wrong portal. Please use the correct role login.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        // Navigate to authenticated screen
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => AuthChecker()),
        // );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error in Google sign-in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong during login.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getLoadingMessage(String role) {
    switch (role) {
      case 'NutriMate':
        return "Fetching your details for healthy living...";
      case 'NutriChef':
        return "Preparing dashboard for healthy meal prep...";
      case 'NutriCarrier':
        return "Packing up your wellness drops...";
      default:
        return "Fetching your details...";
    }
  }

  void _submitData(BuildContext context) async {
    final _isValid = _formKey.currentState!.validate();

    if (!_isValid) {
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isLoading = true;
      });

      await authenticateFirebase(context);
      //   Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => AuthChecker()),
      // );
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString() ?? 'Invalid Authentication'),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> validateUserRoleAndNavigate(
      BuildContext context, String expectedRole) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();

    if (data != null && data['role'] != expectedRole) {
      await FirebaseAuth.instance.signOut();
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'You are trying to log in through the wrong portal. Please use the correct role login.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      Navigator.of(context).pop();
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //       builder: (_) => AuthChecker(),
      //     ));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      // backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('NutriNudge'),
        backgroundColor: isDarkMode
            ? null // Use default dark theme color
            : primaryColor.withAlpha(120),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Stack(children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Static section (non-scrollable)
                    Text(
                      _isLogin ? 'Log in' : 'Create an account',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge!
                          .copyWith(
                              color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Welcome back $title! Please enter your details.'
                          : 'Welcome $title! Please enter your details.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset(
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            imagePath!,
                          ),
                          //    Container(
                          //   height: 200,
                          //   width: double.infinity,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(width: 2),
                          //   ),
                          // ),
                          SizedBox(height: 40),
                          if (!_isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Name',
                                prefixIcon: Icon(Icons.person),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: primaryColor.withAlpha(
                                        180), // your desired focus color
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                floatingLabelStyle: TextStyle(
                                  color:
                                      primaryColor, // label color when focused
                                  fontWeight: FontWeight.w600,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 3) {
                                  return 'Please Enter a valid Username.';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredUserName = newValue!;
                              },
                            ),
                          if (!_isLogin) SizedBox(height: 20),
                          TextFormField(
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryColor.withAlpha(
                                      180), // your desired focus color
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: primaryColor, // label color when focused
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.trim().contains('@')) {
                                return 'Please Enter a valid Email Id..';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            autocorrect: false,
                            enableSuggestions: false,
                            obscureText: _togglePassword,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: primaryColor.withAlpha(
                                      180), // your desired focus color
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: primaryColor, // label color when focused
                                fontWeight: FontWeight.w600,
                              ),
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _togglePassword = !_togglePassword;
                                    });
                                  },
                                  icon: _togglePassword
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility)),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  value.trim().length < 6) {
                                return 'Password must atleast 6 characters.';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _submitData(context);
                                  },
                                  child: Text(
                                    _isLogin ? 'Log In' : 'Sign Up',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        primaryColor.withAlpha(180),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text("Or Log in with",
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filled(
                                onPressed: () {
                                  signInWithGoogleAndSaveToFirestore(
                                      context, title);
                                },
                                icon: Icon(FontAwesomeIcons.google),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    primaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isLogin
                                  ? 'Don\'t have an account?'
                                  : 'Already have an account?'),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                  _isLogin ? 'Sign up' : 'Login',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  height: double.maxFinite,
                  width: double.infinity,
                  color: primaryColor.withAlpha(5), // translucent overlay
                  child: Center(
                    child: ModernLoadingScreen(
                        message: getLoadingMessage(widget.role)),
                    // child: CircularProgressIndicator(
                    //   color: Colors.lightGreen[500],
                    // ),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
