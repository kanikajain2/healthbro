import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_broo/dashboard.dart';
import 'package:health_broo/login.dart';

class Sympchecker extends StatefulWidget {
  const Sympchecker({super.key});

  @override
  State<Sympchecker> createState() => _SympcheckerState();
}

class _SympcheckerState extends State<Sympchecker> {
  final TextEditingController _controller = TextEditingController();

  List<String> _array = [];

  void _addToArray() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _array.add(_controller.text.trim());
        _controller.clear(); // Clear the field after adding
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
              icon: Icon(Icons.arrow_back),
            ),
            Text('SYMPTOM CHECKER'),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
      ),
      body: Center(
        child: Card(
          color: const Color.fromARGB(207, 252, 250, 230),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check Your sympton',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  'Add your Symptoms',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
                SizedBox(height: 7),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: "Enter a symptom",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: _addToArray,
                    ),
                  ),
                  onSubmitted: (value) => _addToArray(),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children:
                      _array
                          .map(
                            (item) => Chip(
                              label: Text(item),
                              deleteIcon: Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  _array.remove(item);
                                });
                              },
                            ),
                          )
                          .toList(),
                ),

                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        const Color.fromARGB(255, 221, 107, 107),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Analyse Symptom',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
