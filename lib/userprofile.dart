import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health_broo/dashboard.dart';
import 'package:health_broo/login.dart';

class Userprofile extends StatefulWidget {
  const Userprofile({super.key});

  @override
  State<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
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
        toolbarHeight: 100,
        automaticallyImplyLeading: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  },
                  icon: Icon(Icons.arrow_back),
                ),
                Text(
                  "Patient's Profile",
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
        ),
      ),

      body:
          userData == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '${userData!['name']}'.toUpperCase(),

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'Personal Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PersonalInformation(
                              icon:
                                  userData!['gender'] == 'Female'
                                      ? Icons.woman
                                      : Icons.male,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
