import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_broo/doctordash.dart';
import 'package:health_broo/login.dart';

class Doctorprofile extends StatefulWidget {
  const Doctorprofile({super.key});

  @override
  State<Doctorprofile> createState() => _DoctorprofileState();
}

class _DoctorprofileState extends State<Doctorprofile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'users',
  );
  final DatabaseReference _dbRef1 = FirebaseDatabase.instance.ref().child(
    'doctors',
  );
  bool isloading = true;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? doctorData;

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
          isloading = false;
        });
      } else {
        print("User data not found for UID: $uid");
      }
    } else {
      print("User not logged in");
    }
    if (user != null) {
      final uid = user.uid;
      final snapshot1 = await _dbRef1.child(uid).get();

      if (snapshot1.exists) {
        setState(() {
          doctorData = Map<String, dynamic>.from(snapshot1.value as Map);
          isloading = false;
        });
      } else {
        print("User data not found for UID: $uid");
      }
    } else {
      print("User not logged in");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 250, 249, 227),
        toolbarHeight: 45,
        automaticallyImplyLeading: false,
        flexibleSpace: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Doctordash()),
                );
              },
              icon: Icon(Icons.arrow_back),
            ),
            Text(
              "Doctor's Profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      ),
      body:
          isloading == true
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(5),
                            ),
                            shadowColor: const Color.fromARGB(
                              255,
                              255,
                              255,
                              255,
                            ),
                            color: Color.fromARGB(255, 227, 218, 241),
                            margin: EdgeInsetsGeometry.all(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 30,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${userData!['name']}'.toUpperCase(),
                                    style: GoogleFonts.cairo(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${doctorData!['specialization']}'
                                        .toUpperCase(),
                                    style: GoogleFonts.allan(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),
                        Text(
                          'Professional Details',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Professional(
                                icon: Icons.category,
                                field: 'SPECIALIZATION',
                                detail: '${doctorData!['specialization']}',
                              ),
                              Professional(
                                icon: Icons.badge,
                                field: 'EXPERIENCE',
                                detail: '${doctorData!['experience']} Years',
                              ),
                              Professional(
                                icon: Icons.local_hospital,
                                field: 'HOSPIAL',
                                detail: '${doctorData!['hospital']}',
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        Text(
                          'Personal Details',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PersonalInformation(
                              icon:
                                  userData!['gender'] == 'Male' ||
                                          userData!['gender'] == 'male'
                                      ? Icons.male
                                      : Icons.woman,
                              detail: '${userData!['gender']}',
                            ),
                            PersonalInformation(
                              icon: Icons.numbers_outlined,
                              detail: 'Age:${userData!['age']}',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Contact Details',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: contact(
                                icon: Icons.email,
                                detail: '${userData!['email']}',
                              ),
                            ),
                            Expanded(
                              child: contact(
                                icon: Icons.phone,
                                detail: '${userData!['phone']}',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}

class Professional extends StatelessWidget {
  final IconData icon;
  final String field;
  final String detail;

  const Professional({
    super.key,
    required this.icon,
    required this.field,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      shadowColor: Colors.white,
      color: Color.fromARGB(255, 215, 241, 214),
      elevation: 10,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Icon(icon),
                SizedBox(height: 5),
                Text(
                  field,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(detail, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PersonalInformation extends StatelessWidget {
  final IconData icon;
  final String detail;

  const PersonalInformation({
    super.key,
    required this.icon,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 232, 222, 248),
      margin: EdgeInsets.all(20),
      shadowColor: Colors.white,
      elevation: 25,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Icon(icon),
                SizedBox(height: 5),
                Text(detail, style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class contact extends StatelessWidget {
  final IconData icon;
  final String detail;
  const contact({super.key, required this.icon, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        SizedBox(height: 5),
        Text(detail, style: TextStyle(fontSize: 18)),
      ],
    );
  }
}
