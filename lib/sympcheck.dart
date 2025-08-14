import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class Sympchecker extends StatefulWidget {
  const Sympchecker({super.key});

  @override
  State<Sympchecker> createState() => _SympcheckerState();
}

class _SympcheckerState extends State<Sympchecker> {
  final TextEditingController _controller = TextEditingController();
  List<String> _symptomList = [];
  List<Map<String, dynamic>> _results = [];
  String? _uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _uid = user?.uid;
    });
  }

  void _addSymptom() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _symptomList.add(_controller.text.trim());
        _controller.clear();
      });
    }
  }

  void _removeResult(int index) {
    setState(() {
      _results.removeAt(index);
    });
  }

  Future<void> _fetchPrediction() async {
    final uri = Uri.parse('http://127.0.0.1:5000/api/predict');
    final inputText = _symptomList.join(', ');

    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? "guest_user";

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"input_text": inputText, "mode": "text", "uid": uid}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prediction = data['savedPrediction'];

        setState(() {
          _results.insert(0, prediction);
        });
      } else {
        print("❌ Prediction failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Symptom Checker"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check your symptoms',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter symptoms one by one and click Analyse:',
                      style: GoogleFonts.cairo(fontSize: 15),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter a symptom',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addSymptom,
                        ),
                      ),
                      onSubmitted: (_) => _addSymptom(),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children:
                          _symptomList.map((symptom) {
                            return Chip(
                              label: Text(symptom),
                              backgroundColor: const Color.fromARGB(
                                255,
                                199,
                                207,
                                235,
                              ),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  _symptomList.remove(symptom);
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed:
                            _symptomList.isEmpty ? null : _fetchPrediction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            241,
                            135,
                            135,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                        icon: const Icon(Icons.analytics),
                        label: const Text(
                          'Analyse Symptoms',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child:
                  _results.isEmpty
                      ? const Center(child: Text(" No predictions yet."))
                      : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 3,
                            color: const Color.fromARGB(255, 214, 220, 245),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              title: Text(
                                "Symptoms: ${item['symptoms'].join(', ')}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Severity: ${item['severity']}"),
                                    Text(
                                      "Suggested Doctor: ${item['doctorsuggestion']}",
                                    ),
                                    Text(
                                      "Date: ${item['createdAt'].toString().substring(0, 10)}",
                                    ),
                                    Text(
                                      "Time: ${item['createdAt'].toString().substring(11, 16)}",
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color.fromARGB(255, 101, 137, 255),
                                ),
                                onPressed: () => _removeResult(index),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
