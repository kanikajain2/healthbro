import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_broo/dashboard.dart';
import 'package:health_broo/doctordash.dart';
import 'package:health_broo/doctorform.dart';
import 'package:health_broo/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  Map<String, dynamic>? userData;
  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();
  bool isloading = false;
  Future<void> logIn() async {
    setState(() {
      isloading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailcontroller.text.trim(),
            password: passwordcontroller.text.trim(),
          );

      final User? user = userCredential.user;

      if (user != null) {
        final uid = user.uid;

        final userSnapshot = await _dbRef.child(uid).get();
        if (userSnapshot.exists) {
          final userMap = Map<String, dynamic>.from(userSnapshot.value as Map);
          final role = userMap['role'];

          if (role == 'Doctor') {
            final doctorRef = FirebaseDatabase.instance
                .ref()
                .child('doctors')
                .child(uid);
            final doctorSnapshot = await doctorRef.get();

            if (doctorSnapshot.exists) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Doctordash()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Doctorform()),
              );
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: ${e.message}")));
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HealthBro')),

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: Image.asset("image/front.png", height: 250)),

                SizedBox(height: 10),

                Center(
                  child: Text(
                    'WELCOME BACK !!',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(255, 255, 31, 154),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: emailcontroller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined),
                    labelText: 'Enter registered Email Address',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 10),

                TextField(
                  controller: passwordcontroller,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock_clock_outlined),
                    labelText: 'Enter password',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                ),

                SizedBox(height: 15),

                ElevatedButton(
                  onPressed: () {
                    logIn();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Ink(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 209, 106, 157),
                          Color.fromARGB(255, 212, 145, 190),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      alignment: Alignment.center,
                      child: Text(
                        'LOGIN',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => Register()),
                    );
                  },
                  child: Text(
                    'New user? Create an account',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 49, 49, 49),
                    ),
                  ),
                ),

                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
