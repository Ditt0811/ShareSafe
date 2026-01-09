import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homescreen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add defensive startup logic so a failing Firebase init or camera
  // lookup doesn't leave the app stuck on the native splash.
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    // Log and continue — user can see this in `flutter run` output.
    // We purposely don't rethrow so the UI can still come up for debugging.
    debugPrint('Firebase.initializeApp() failed: $e');
    debugPrint('$st');
  }

  try {
    cameras = await availableCameras();
  } catch (e, st) {
    debugPrint('availableCameras() failed: $e');
    debugPrint('$st');
    cameras = <CameraDescription>[]; // fallback empty list
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Share Safe',
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const OpeningScreen(),
    );
  }
}

/* ================= OPENING SCREEN ================= */

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  @override
  void initState() {
    super.initState();

    // Delay 3 detik sebelum ke Login Screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(child: Image.asset('assets/Logo.png', width: 220)),
    );
  }
}

/* ================= LOGIN SCREEN ================= */

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Logo.png', width: 180),
            const SizedBox(height: 40),

            // Username
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.person, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Password
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white38),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Login Button
            SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

            const SizedBox(height: 20),

            // Google Button
            socialButton(
              text: 'Continue with Google',
              icon: Icons.g_mobiledata,
            ),

            const SizedBox(height: 12),

            // Facebook Button
            socialButton(text: 'Continue with Facebook', icon: Icons.facebook),
          ],
        ),
      ),
    );
  }

  Widget socialButton({required String text, required IconData icon}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
