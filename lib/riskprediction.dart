import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiskPredictionForm extends StatefulWidget {
  const RiskPredictionForm({super.key});

  @override
  State<RiskPredictionForm> createState() => _RiskPredictionFormState();
}

class _RiskPredictionFormState extends State<RiskPredictionForm> {
  // --- STATE AND CONTROLLERS: UNCHANGED ---
  final _formKey = GlobalKey<FormState>();

  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController historyController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController oxygenController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController severityController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController plateletsController = TextEditingController();
  final TextEditingController sugarBeforeController = TextEditingController();
  final TextEditingController sugarAfterController = TextEditingController();
  final TextEditingController haemoglobinController = TextEditingController();

  String? predictionResult;
  bool isLoading = false;

  // --- BACKEND LOGIC: UNCHANGED ---
  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final url = Uri.parse("http://10.0.2.2:5000/api/risk"); // Using 10.0.2.2 for Android emulator
    final body = {
      "symptoms": symptomsController.text,
      "past_medical_history": historyController.text,
      "blood_group": bloodGroupController.text,
      "Age": double.tryParse(ageController.text) ?? 0,
      "oxygen_level": double.tryParse(oxygenController.text) ?? 0,
      "bp": double.tryParse(bpController.text) ?? 0,
      "serverity_level": int.tryParse(severityController.text) ?? 0,
      "body_temp": double.tryParse(tempController.text) ?? 0,
      "heart_rate": double.tryParse(heartRateController.text) ?? 0,
      "platelates": double.tryParse(plateletsController.text) ?? 0,
      "sugar_before_meal": double.tryParse(sugarBeforeController.text) ?? 0,
      "sugar_after_meal": double.tryParse(sugarAfterController.text) ?? 0,
      "haemoglobin": double.tryParse(haemoglobinController.text) ?? 0,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          predictionResult = data['prediction']?.toString() ?? "No result";
        });
      } else {
        setState(() {
          predictionResult = "Error: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = "Error connecting to the server.";
      });
    }

    setState(() => isLoading = false);
  }

  // --- UI IMPROVEMENT: Reusable text field with theme styling and hint text ---
  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
    String? hintText, // Added hintText parameter
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText, // Using the provided hint text
          prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.teal, width: 2.0),
          ),
        ),
        keyboardType: inputType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- UI IMPROVEMENT: AppBar consistent with the theme ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[800]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Risk Score Prediction",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // --- UI IMPROVEMENT: Gradient background ---
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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            children: [
              _buildSectionCard(
                title: 'General Information',
                icon: Icons.person_outline,
                children: [
                  buildTextField("Symptoms", symptomsController, hintText: "Enter the current symptoms"),
                  buildTextField("Past Medical History", historyController, hintText: "Enter past medical history"),
                  buildTextField("Blood Group", bloodGroupController, hintText: "A, B, AB, O, +-"),
                  buildTextField("Age", ageController, inputType: TextInputType.number, hintText: "e.g., 35"),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionCard(
                title: 'Vital Signs & Health Metrics',
                icon: Icons.monitor_heart_outlined,
                children: [
                  buildTextField("Oxygen Level (%)", oxygenController, inputType: TextInputType.number, hintText: "Normal: 95 – 100"),
                  buildTextField("Blood Pressure (mmHg)", bpController, inputType: TextInputType.number, hintText: "e.g., 120 (for 120/80)"),
                  buildTextField("Severity Level", severityController, inputType: TextInputType.number, hintText: "0 – 1 (Mild to Severe)"),
                  buildTextField("Body Temperature (°F)", tempController, inputType: TextInputType.number, hintText: "Normal: 97°F – 102°F"),
                  buildTextField("Heart Rate (bpm)", heartRateController, inputType: TextInputType.number, hintText: "Normal: 60 – 100 bpm"),
                  buildTextField("Platelets (/µL)", plateletsController, inputType: TextInputType.number, hintText: "Normal: 1 – 5 /µL"),
                  buildTextField("Sugar Before Meal (mg/dL)", sugarBeforeController, inputType: TextInputType.number, hintText: "Normal: 70 – 99 mg/dL"),
                  buildTextField("Sugar After Meal (mg/dL)", sugarAfterController, inputType: TextInputType.number, hintText: "Normal: < 140 mg/dL"),
                  buildTextField("Haemoglobin (g/dL)", haemoglobinController, inputType: TextInputType.number, hintText: "Men: 13.8–17.2, Women: 12.1–15.1"),
                ],
              ),
              const SizedBox(height: 30),
              // --- UI IMPROVEMENT: Styled submission button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                onPressed: isLoading ? null : submitData,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        "Predict Risk Score",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
              // --- UI IMPROVEMENT: Styled result display ---
              if (predictionResult != null) ...[
                const SizedBox(height: 20),
                _buildResultDisplay(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget to group form fields into a styled card.
  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal, size: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Helper widget to display the prediction result in a styled container.
  Widget _buildResultDisplay() {
    bool isError = predictionResult!.toLowerCase().startsWith('error');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? Colors.red.shade300 : Colors.green.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? Colors.red.shade800 : Colors.green.shade800,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Prediction Result: $predictionResult",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isError ? Colors.red.shade800 : Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
