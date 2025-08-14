// ignore: file_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:health_broo/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final phonenumber = TextEditingController();
  final name = TextEditingController();
  final age = TextEditingController();

  String selectedValue = "Select Gender";
  String selectedValues = "Select Role";

  Future<void> registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailcontroller.text.trim(),
            password: _passwordcontroller.text.trim(),
          );
      String uid = userCredential.user!.uid;

      await FirebaseDatabase.instance.ref().child("users/$uid").set({
        'name': name.text.trim(),
        'phone': phonenumber.text.trim(),
        'gender': selectedValue,
        'role': selectedValues,
        'email': _emailcontroller.text.trim(),
        'age': age.text.trim(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User registered successfully!')));
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'email-already-in-use') {
        message = 'Email already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak.';
      } else {
        message = 'Registration failed. Please try again.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HealthBro')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),

                      Center(
                        child: Text(
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 103, 141, 155),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: name,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                          labelText: 'Enter Your Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: age,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.calendar_month_rounded),
                          labelText: 'Enter Age',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          focusColor: Colors.grey[230],
                          dropdownColor: const Color.fromARGB(
                            255,
                            175,
                            230,
                            222,
                          ),
                          menuWidth: 210,
                          value: selectedValue,
                          icon: Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue!;
                            });
                          },
                          items:
                              <String>[
                                'Select Gender',
                                'Female',
                                'Male',
                                'Other',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          focusColor: Colors.grey[230],
                          dropdownColor: const Color.fromARGB(
                            255,
                            175,
                            230,
                            222,
                          ),
                          menuWidth: 210,
                          value: selectedValues,
                          icon: Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          underline: SizedBox(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValues = newValue!;
                            });
                          },
                          items:
                              <String>[
                                'Select Role',
                                'Doctor',
                                'Patient',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: phonenumber,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          labelText: 'Enter Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _emailcontroller,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          labelText: 'Enter Email Address',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _passwordcontroller,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_open_rounded),
                          labelText: 'Create Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.password_rounded),
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          if (name.text.trim().isEmpty ||
                              age.text.trim().isEmpty ||
                              phonenumber.text.trim().isEmpty ||
                              _emailcontroller.text.trim().isEmpty ||
                              _passwordcontroller.text.trim().isEmpty ||
                              _confirmPasswordController.text.trim().isEmpty ||
                              selectedValue == 'Select Gender' ||
                              selectedValues == 'Select Role') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all the fields'),
                              ),
                            );
                            return;
                          }

                          if (_passwordcontroller.text.trim().length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password should be more than 6 characters',
                                ),
                              ),
                            );
                            return;
                          }

                          if (_passwordcontroller.text.trim() !=
                              _confirmPasswordController.text.trim()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Passwords do not match')),
                            );
                            return;
                          }

                          registerUser();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            112,
                            156,
                            156,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      SizedBox(height: 15),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Text(
                          "LOGIN (if already have an account)",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(height: 10),
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
