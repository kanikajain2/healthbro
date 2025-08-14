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
          "http://localhost:5000/api/prescriptions?email=${widget.email}",
        ),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        // normalize soap_note to always be a Map
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
    if (soapNote == null) {
      return const Text("No SOAP note available.");
    }
    if (soapNote is! Map) {
      return Text("SOAP Note: $soapNote");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("📝 Subjective: ${soapNote['subjective'] ?? 'N/A'}"),
        Text("📊 Objective: ${soapNote['objective'] ?? 'N/A'}"),
        Text("🩺 Assessment: ${soapNote['assessment'] ?? 'N/A'}"),
        Text("📅 Plan: ${soapNote['plan'] ?? 'N/A'}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prescriptions")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : prescriptions.isEmpty
              ? const Center(child: Text("No prescriptions found."))
              : ListView.builder(
                itemCount: prescriptions.length,
                itemBuilder: (context, index) {
                  final p = prescriptions[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📧 Email: ${p['email']}"),
                          Text("👨‍⚕️ Doctor: ${p['name']}"),
                          Text("🗒 Transcription: ${p['transcription']}"),
                          const SizedBox(height: 8),
                          buildSoapNote(p['soap_note']),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
