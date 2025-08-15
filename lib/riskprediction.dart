import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RiskPredictionForm extends StatefulWidget {
  const RiskPredictionForm({super.key});

  @override
  State<RiskPredictionForm> createState() => _RiskPredictionFormState();
}

class _RiskPredictionFormState extends State<RiskPredictionForm> {
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

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final url = Uri.parse("http://127.0.0.1:5000/api/risk");
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
          predictionResult = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = "Error: $e";
      });
    }

    setState(() => isLoading = false);
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: inputType,
        validator:
            (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Risk Score Prediction")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField("Symptoms", symptomsController),
              buildTextField("Past History", historyController),
              buildTextField("Blood Group", bloodGroupController),
              buildTextField(
                "Age",
                ageController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Oxygen Level",
                oxygenController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "BP",
                bpController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Severity Level (0 or 1)",
                severityController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Body Temp",
                tempController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Heart Rate",
                heartRateController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Platelates",
                plateletsController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Sugar Before Meal",
                sugarBeforeController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Sugar After Meal",
                sugarAfterController,
                inputType: TextInputType.number,
              ),
              buildTextField(
                "Haemoglobin",
                haemoglobinController,
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : submitData,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Predict Risk"),
              ),
              if (predictionResult != null) ...[
                const SizedBox(height: 20),
                Text(
                  "Prediction Result: $predictionResult",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
