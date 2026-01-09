// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profilescreen.dart';

class UploadPreviewScreen extends StatefulWidget {
  final String imagePath;

  const UploadPreviewScreen({super.key, required this.imagePath});

  @override
  State<UploadPreviewScreen> createState() => _UploadPreviewScreenState();
}

class _UploadPreviewScreenState extends State<UploadPreviewScreen> {
  final TextEditingController descriptionController = TextEditingController();
  String location = 'Mengambil lokasi...';
  String date = DateFormat('dd MMMM yyyy').format(DateTime.now());
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      setState(() => location = 'GPS tidak aktif');
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => location = 'Izin lokasi ditolak');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;

    setState(() {
      location =
          '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
    });
  }

  Future<void> uploadData() async {
    // Ensure Firebase is initialized (in case main() initialization failed earlier)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Firebase init failed: $e')));
      return;
    }

    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi tidak boleh kosong')),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final file = File(widget.imagePath);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref().child('uploads/$fileName.jpg');

      await ref.putFile(file); // WAJIB await

      final imageUrl = await ref.getDownloadURL(); // WAJIB

      await FirebaseFirestore.instance.collection('uploads').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'imageUrl': imageUrl,
        'description': descriptionController.text,
        'location': location,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload berhasil')));

      // Delay untuk SnackBar tampil sebelum navigate
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      debugPrint('Error upload: $e');
      if (!mounted) return;
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // PROFILE ICON
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // IMAGE PREVIEW
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    File(widget.imagePath),
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // DESCRIPTION
              infoBox(
                title: 'Deskripsi Gambar :',
                child: TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Jelaskan tentang gambar...',
                    hintStyle: TextStyle(color: Colors.black45),
                  ),
                ),
              ),

              infoBox(
                title: 'Lokasi :',
                child: Text(
                  location,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),

              infoBox(
                title: 'Tanggal :',
                child: Text(
                  date,
                  style: const TextStyle(color: Colors.black87),
                ),
              ),

              const SizedBox(height: 20),

              // ACTION BUTTONS
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // CANCEL
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // CONFIRM
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.greenAccent,
                      child: isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.black,
                              ),
                              onPressed: () async {
                                await uploadData();
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoBox({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(16),
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}
