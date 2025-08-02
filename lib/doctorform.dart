import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:health_broo/doctordash.dart';

class Doctorform extends StatefulWidget {
  const Doctorform({super.key});

  @override
  State<Doctorform> createState() => _DoctorformState();
}

class _DoctorformState extends State<Doctorform> {
  var specialization = TextEditingController();
  var experience = TextEditingController();
  var hospital = TextEditingController();
  var education = TextEditingController();
  var about = TextEditingController();

  Map<String, dynamic>? doctorData;
  void submitDoctorDetails() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
      "doctors",
    );

    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;

      doctorData = {
        'email': user.email,
        'specialization': specialization.text.trim(),
        'experience': experience.text.trim(),
        'hospital': hospital.text.trim(),
        'education': education.text.trim(),
        'about': about.text.trim(),
      };

      await _dbRef
          .child(uid)
          .set(doctorData)
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Doctor details submitted successfully!")),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Doctordash()),
            );
          })
          .catchError((error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Error: $error")));
          });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Professional Details')),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, \nKanika Jain'.toUpperCase(),
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
                  SizedBox(height: 10),
                  TextField(
                    controller: specialization,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.medical_services_outlined),
                      labelText: 'Enter Your Specialization',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: experience,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.timelapse),
                      labelText: 'Years of Experience',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: hospital,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.healing),
                      labelText: 'Clinic name / Hospital name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: education,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.cast_for_education),
                      labelText: 'Education',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: about,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_box_outlined),
                      labelText: 'About yourself',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        submitDoctorDetails();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          const Color.fromARGB(223, 98, 125, 150),
                        ),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                      ),
                      child: Text(
                        'Submit Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
