import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Patientslist extends StatefulWidget {
  const Patientslist({super.key});

  @override
  State<Patientslist> createState() => _PatientslistState();
}

class _PatientslistState extends State<Patientslist> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child(
    'users',
  );

  List<Map<String, dynamic>> patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  void fetchPatients() {
    _dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final tempList =
            data.entries
                .where(
                  (entry) =>
                      entry.value is Map &&
                      entry.value['role']?.toString().toLowerCase() ==
                          'patient',
                ) // filter patients only
                .map(
                  (entry) => {
                    'name': entry.value['name'] ?? '',
                    'phone': entry.value['phone'] ?? '',
                    'gender': entry.value['gender'] ?? '',
                    'age': entry.value['age'] ?? '',
                  },
                )
                .toList();

        setState(() {
          patients = List<Map<String, dynamic>>.from(tempList);
          isLoading = false;
        });
      } else {
        setState(() {
          patients = [];
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PATIENT'S LIST")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : patients.isEmpty
              ? const Center(child: Text("No patients found"))
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(Icons.person, size: 40),
                        title: Text(
                          patient['name'].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 47, 135, 207),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Phone: ${patient['phone']}"),
                            Text("Gender: ${patient['gender']}"),
                            Text("Age: ${patient['age']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
