import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:health_broo/presscription.dart';
import 'package:health_broo/sympcheck.dart';
import 'package:health_broo/userprofile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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
    final bool isMediumScreen = MediaQuery.of(context).size.width > 600;
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
                  MaterialPageRoute(builder: (context) => Userprofile()),
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
                        'Hello, \n${userData!['name']}'.toUpperCase(),
                        style: GoogleFonts.aboreto(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'WELCOME! Explore our features. Your health updated are just a tap away.',
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Our Features:',
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
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) {
                                              return Sympchecker();
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 115,
                                        color: Color.fromARGB(
                                          255,
                                          201,
                                          231,
                                          242,
                                        ),
                                        padding: EdgeInsets.all(20),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'image/assessment.png',
                                                height: 30,
                                                width: 30,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'SYMPTOM CHECKER',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      isMediumScreen ? 16 : 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) {
                                            return Presscription();
                                          },
                                        ),
                                      );
                                    },
                                    child: Expanded(
                                      child: Container(
                                        height: 115,
                                        color: Color.fromARGB(
                                          255,
                                          255,
                                          236,
                                          179,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                          horizontal: 20,
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Image.asset(
                                                'image/history.png',
                                                height: 30,
                                                width: 35,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'PRESCRIPTION',
                                                style: TextStyle(
                                                  fontSize:
                                                      isMediumScreen ? 16 : 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                spacing: 10,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 115,
                                      color: Color.fromARGB(255, 210, 236, 209),
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'image/symptom.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'HISTORY TRACKING',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    isMediumScreen ? 16 : 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 115,
                                      color: Color.fromARGB(255, 232, 222, 248),
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'image/risk-factors.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'RISK PREDICTION',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    isMediumScreen ? 16 : 13,
                                              ),
                                            ),
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
                                      Text(
                                        'In case of emergency , find nearest hospital ',
                                      ),
                                      SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                Colors.red[300],
                                              ),
                                        ),
                                        child: Text(
                                          'Find Nearest Hospital',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      TextButton(
                                        onPressed: () {},
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                Colors.blue[400],
                                              ),
                                        ),
                                        child: Text(
                                          'Contact Your Doctor',
                                          style: TextStyle(color: Colors.white),
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
                    ],
                  ),
                ),
              ),
    );
  }
}
