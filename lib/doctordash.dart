import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:health_broo/doctorprofile.dart';
import 'package:health_broo/login.dart';
import 'package:health_broo/patientslist.dart';
import 'package:health_broo/voicenote.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  late IO.Socket socket;
  List<Map<String, dynamic>> alerts = [];

  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    loadUserData().then((_) {
      if (userData != null) {
        fetchExistingAlerts();
        connectToSocket();
      }
    });
  }

  void fetchExistingAlerts() async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://127.0.0.1:5000/api/emergency/alerts/${userData!['email']}",
        ),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (!mounted) return; // Prevent setState after dispose
        setState(() {
          alerts = List<Map<String, dynamic>>.from(data['alerts']);
        });
      } else {
        print("⚠ No existing alerts found");
      }
    } catch (e) {
      print("❌ Error fetching alerts: $e");
    }
  }

  void connectToSocket() {
    socket = IO.io('http://127.0.0.1:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('✅ Connected to socket server');
      socket.emit('joinRoom', userData!['email']);
    });

    socket.on('emergencyAlert', (data) {
      print("🚨 Emergency Alert: $data");

      if (!mounted) return;
      setState(() {
        alerts.insert(0, Map<String, dynamic>.from(data));
      });
    });

    socket.onDisconnect((_) => print('❌ Disconnected from socket'));
  }

  @override
  void dispose() {
    if (socket.connected) {
      socket.dispose(); // Proper cleanup
    }
    super.dispose();
  }

  Future<void> loadUserData() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      final uid = user.uid;
      final snapshot = await _dbRef.child(uid).get();

      if (snapshot.exists) {
        if (!mounted) return;
        setState(() {
          userData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User data not found')));
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
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
                  child: Stack(
                    children: [
                      Column(
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
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => Patientslist(),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 130,
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
                                                    height: 40,
                                                    width: 35,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'PATIENTS LIST',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => Voicenote(
                                                      loggedInDoctorEmail:
                                                          userData!['email'],
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: 130,
                                            color: Color.fromARGB(
                                              255,
                                              255,
                                              236,
                                              179,
                                            ),
                                            padding: EdgeInsets.all(20),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    'image/history.png',
                                                    height: 40,
                                                    width: 35,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'VOICE NOTE to SOAP',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                  Container(
                                    color: Color.fromARGB(255, 232, 222, 248),
                                    padding: const EdgeInsets.all(30),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Text(
                                            'EMERGENCY ALERT',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          if (alerts.isEmpty)
                                            const Text(
                                              'No Alert',
                                              textAlign: TextAlign.center,
                                            ),
                                          if (alerts.isNotEmpty)
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: alerts.length,
                                              itemBuilder: (context, index) {
                                                final alert = alerts[index];
                                                final thisId =
                                                    (alert['_id'] ??
                                                            alert['id'])
                                                        ?.toString() ??
                                                    '';
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                      255,
                                                      232,
                                                      222,
                                                      248,
                                                    ),
                                                    border: Border.all(),
                                                  ),
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                      ),
                                                  child: ListTile(
                                                    title: Text(
                                                      'Patient ID: ${alert['patientId']}',
                                                      style: GoogleFonts.cairo(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    subtitle: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Received on: ${alert['createdAt'].toString().substring(0, 10)}.',
                                                        ),
                                                        Text(
                                                          'Time at: ${alert['createdAt'].toString().substring(12, 16)}',
                                                        ),
                                                      ],
                                                    ),
                                                    trailing: IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.blue,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          alerts.removeWhere((
                                                            a,
                                                          ) {
                                                            final aId =
                                                                (a['_id'] ??
                                                                        a['id'])
                                                                    ?.toString() ??
                                                                '';
                                                            return aId ==
                                                                thisId;
                                                          });
                                                        });
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Alert removed from dashboard',
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
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
                      Positioned(
                        bottom: 15,
                        right: 20,
                        child: ActionChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "Logout",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red[400],
                          onPressed: () {
                            // Your logout logic
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Login()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
