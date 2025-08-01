import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        'Login Page',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.cyan[700],
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
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          const Color.fromARGB(255, 112, 156, 156),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      child: Text(
                        'LOGIN',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),

                    SizedBox(height: 15),

                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Register()),
                        );
                      },
                      hoverColor: Colors.blue[300],
                      child: Text(
                        'New user? Create an account',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
