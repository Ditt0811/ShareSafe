// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main.dart';
import 'uploadpreviewscreen.dart';
import 'profilescreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController _controller;
  bool isRearCamera = true;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera(cameras[1]);
  }

  Future<void> _initCamera(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            // ===== TOP BAR =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
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
                ],
              ),
            ),

            // ===== CAMERA PREVIEW =====
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _controller.value.isInitialized
                      ? CameraPreview(_controller)
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== CONTROLS =====
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Switch Camera
                  IconButton(
                    icon: const Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      isRearCamera = !isRearCamera;
                      _initCamera(isRearCamera ? cameras[0] : cameras[1]);
                    },
                  ),

                  // Capture
                  GestureDetector(
                    onTap: () async {
                      final image = await _controller.takePicture();
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UploadPreviewScreen(imagePath: image.path),
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 4),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Flash
                  IconButton(
                    icon: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () async {
                      isFlashOn = !isFlashOn;
                      await _controller.setFlashMode(
                        isFlashOn ? FlashMode.torch : FlashMode.off,
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
