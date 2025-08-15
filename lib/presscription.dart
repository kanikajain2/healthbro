import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrescriptionPage extends StatefulWidget {
  final String email;
  const PrescriptionPage({super.key, required this.email});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  List prescriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrescriptions();
  }

  Future<void> fetchPrescriptions() async {
    try {
      final res = await http.get(
        Uri.parse(
          "http://127.0.0.1:5000/api/prescriptions?email=${widget.email}",
        ),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        for (var p in data) {
          if (p['soap_note'] is String) {
            try {
              p['soap_note'] = jsonDecode(p['soap_note']);
            } catch (_) {
              p['soap_note'] = null;
            }
          }
        }
        setState(() {
          prescriptions = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        debugPrint("❌ Error fetching prescriptions: ${res.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Exception: $e");
    }
  }

  Widget buildSoapNote(dynamic soapNote) {
    if (soapNote == null || soapNote is! Map || soapNote.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget buildSoapDetail(String title, String? value) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: '$title: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              TextSpan(text: value ?? 'N/A'),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Doctor's SOAP Note",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const Divider(height: 15),
          buildSoapDetail("📝 Subjective", soapNote['subjective']),
          buildSoapDetail("📊 Objective", soapNote['objective']),
          buildSoapDetail("🩺 Assessment", soapNote['assessment']),
          buildSoapDetail("📅 Plan", soapNote['plan']),
        ],
      ),
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("My Prescriptions"),
        centerTitle: true,
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
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : prescriptions.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_information_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No Prescriptions Found",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your medical records will appear here.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                : _buildPrescriptionList(),
      ),
    );
  }

  Widget _buildPrescriptionList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final p = prescriptions[index];
        return Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Doctor: ${p['name'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Patient: ${p['email'] ?? 'N/A'}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                const Text(
                  "Transcription",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p['transcription'] ?? 'No transcription available.',
                  style: TextStyle(color: Colors.grey[800], height: 1.5),
                ),
                const SizedBox(height: 16),
                buildSoapNote(p['soap_note']),
              ],
            ),
          ),
        );
      },
    );
  }
}
