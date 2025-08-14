import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class Voicenote extends StatefulWidget {
  final String loggedInDoctorEmail;
  const Voicenote({super.key, required this.loggedInDoctorEmail});

  @override
  State<Voicenote> createState() => _VoicenoteState();
}

class _VoicenoteState extends State<Voicenote> {
  String? resultText;
  bool isUploading = false;
  String patientId = "";

  Future<void> _uploadAudioFile(Uint8List fileBytes, String filename) async {
    const String uploadUrl = "http://localhost:5000/api/notes/upload";

    setState(() {
      isUploading = true;
      resultText = null;
    });

    try {
      final mimeType = lookupMimeType(filename) ?? 'audio/mpeg';
      final mimeSplit = mimeType.split('/');

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Send doctor email from login
      request.fields['doctor_email'] = widget.loggedInDoctorEmail;
      // Send patient ID from text field
      request.fields['patient_id'] = patientId;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        setState(() {
          final soapNote = data['soap_note'];
          if (soapNote != null) {
            resultText =
                "Subjective: ${soapNote['subjective']}\n"
                "Objective: ${soapNote['objective']}\n"
                "Assessment: ${soapNote['assessment']}\n"
                "Plan: ${soapNote['plan']}";
          } else {
            resultText = 'No SOAP note found.';
          }
        });
      } else {
        setState(() {
          resultText = '❌ Error: $responseBody';
        });
      }
    } catch (e) {
      setState(() {
        resultText = '❌ Exception: $e';
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'webm'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      String filename = result.files.single.name;
      Uint8List fileBytes = result.files.single.bytes!;
      await _uploadAudioFile(fileBytes, filename);
    } else {
      print('❌ File picking cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Note Analyzer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Logged in as: ${widget.loggedInDoctorEmail}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              decoration: const InputDecoration(
                labelText: "Enter Patient Email / ID",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                patientId = value;
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.mic),
                onPressed: _pickAudio,
                label: Text(
                  "Pick Audio File",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 236, 147, 147),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isUploading) const Center(child: CircularProgressIndicator()),
            if (resultText != null) ...[
              const SizedBox(height: 20),
              const Text(
                "📝 Transcription:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(resultText!, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
