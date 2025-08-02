import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:health_broo/doctorprofile.dart';

class Doctordash extends StatefulWidget {
  const Doctordash({super.key});

  @override
  State<Doctordash> createState() => _DoctordashState();
}

class _DoctordashState extends State<Doctordash> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  Map<String, dynamic>? userData;
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final uid = user.uid;
      final snapshot = await _dbRef.child(uid).get();

      if (snapshot.exists) {
        setState(() {
          userData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User data not found')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not logged in')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            InkWell(child: Text('HealthBro')),
            Text('Dashboard'),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Doctorprofile()),
                );
              },
            ),
          ],
        ),
      ),

      body:
          userData == null
              ? LinearProgressIndicator()
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, \nDR. ${userData!['name']}'.toUpperCase(),
                        style: GoogleFonts.aboreto(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'WELCOME DOCTOR! Here\'s your lastest dashboard. Stay updated with your patients.',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Patient\'s Detail :',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 50, 94, 94),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Card(
                        margin: EdgeInsets.all(20),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                spacing: 10,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 130,
                                      color: Color.fromARGB(255, 201, 231, 242),
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'image/assessment.png',
                                              height: 40,
                                              width: 35,
                                            ),
                                            SizedBox(height: 8),
                                            Text('PATIENTS LIST'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 130,
                                      color: Color.fromARGB(255, 255, 236, 179),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 20,
                                        horizontal: 20,
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'image/history.png',
                                              height: 40,
                                              width: 35,
                                            ),
                                            SizedBox(height: 8),
                                            Text('VOICE NOTE to SOAP'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Container(
                                color: Color.fromARGB(255, 220, 235, 245),
                                padding: EdgeInsets.all(30),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'EMERGENCY ALERT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text('No Alert'),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
