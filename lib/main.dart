import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_broo/firebase_options.dart';
import 'package:health_broo/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
  print("After Firebase Init");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 250, 249, 227),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 255, 255, 255),
        ),
        useMaterial3: true,

        appBarTheme: AppBarTheme(
          toolbarHeight: 45,
          actionsPadding: EdgeInsets.all(8),
          backgroundColor: Color.fromARGB(255, 152, 188, 201),
          elevation:
              10, // shadowColor: const Color.fromARGB(255, 173, 216, 230),
          centerTitle: true,
          surfaceTintColor: const Color.fromARGB(255, 196, 191, 173),
          //titleTextStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 20 , color: Colors.black ),
          titleTextStyle: GoogleFonts.alatsi(
            fontWeight: FontWeight.w200,
            fontSize: 20,
            color: Colors.black,
          ),
        ),

        cardTheme: CardThemeData(
          shadowColor: Colors.black,
          elevation: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(50),
        ),

        textTheme: TextTheme(
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          filled: true,
          hoverColor: Color.fromARGB(255, 193, 224, 235),
          border: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: BorderRadius.circular(5),
          ),
          hintStyle: TextStyle(height: 0.2, fontSize: 10, color: Colors.grey),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color.fromARGB(255, 152, 188, 201),
          contentTextStyle: GoogleFonts.akatab(color: Colors.black),
        ),

        buttonTheme: ButtonThemeData(
          shape: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),

      home: Register(),
    );
  }
}
