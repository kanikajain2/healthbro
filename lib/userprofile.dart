import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_broo/dashboard.dart';
import 'package:health_broo/login.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = _auth.currentUser;

      if (user != null) {
        final snapshot = await _dbRef.child(user.uid).get();

        if (snapshot.exists && snapshot.value != null) {
          setState(() {
            _userData = Map<String, dynamic>.from(snapshot.value as Map);
          });
        } else {
          print("User data not found for UID: ${user.uid}");
        }
      } else {
        print("User not logged in");
      }
    } catch (e) {
      print("An error occurred while loading user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Login()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[800]),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
        ),
        title: const Text(
          "Patient's Profile",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[800]),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade50,
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _userData == null
                ? const Center(
                  child: Text(
                    'Could not load user data.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal.shade200,
              child: Text(
                _userData!['name']?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _userData!['name'].toUpperCase() ?? 'N/A',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _userData!['email'] ?? 'No email provided',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 15),

        _buildInfoCard(
          title: 'Personal Details',
          details: [
            _buildDetailRow(
              icon:
                  _userData!['gender'] == 'Female' ? Icons.female : Icons.male,
              label: 'Gender',
              value: _userData!['gender'] ?? 'N/A',
            ),
            _buildDetailRow(
              icon: Icons.cake,
              label: 'Age',
              value: _userData!['age']?.toString() ?? 'N/A',
            ),
          ],
        ),
        const SizedBox(height: 10),

        _buildInfoCard(
          title: 'Contact Information',
          details: [
            _buildDetailRow(
              icon: Icons.phone_android,
              label: 'Phone',
              value: _userData!['phone'] ?? 'N/A',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> details,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(height: 20, thickness: 1),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500]),
          const SizedBox(width: 16),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
