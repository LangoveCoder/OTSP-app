import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _controller = TextEditingController();
  String? rollNumber;
  bool isButtonEnabled = false;
  bool isProcessing = false;

  // Function to capture and save a single image
  Future<void> captureImage() async {
    if (rollNumber == null || rollNumber!.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a roll number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        // Get the directory for storing the image locally
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$rollNumber.jpg';

        // Copy the image to the destination
        final File imageFile = File(image.path);
        await imageFile.copy(filePath);

        // Save the image to the gallery
        await Gal.putImage(filePath);

        // Update the state to reflect the saved image and refresh the UI
        setState(() {
          _controller.clear();
          rollNumber = null;
          isButtonEnabled = false;
          isProcessing = false;
        });

        Get.snackbar(
          'Success',
          'Image saved successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        setState(() {
          isProcessing = false;
        });
        Get.snackbar(
          'Cancelled',
          'No image captured',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade400,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Logo with shadow
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            'assets/logo/logo.png',
                            width: 160,
                            height: 160,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Title
                    const Text(
                      'OTSP Attendance',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture attendance with ease',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Input Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // TextField
                          TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: 'Roll Number',
                              hintText: 'Enter 5-digit roll number',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Color(0xFF667eea),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF667eea),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFF667eea),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            onChanged: (value) {
                              setState(() {
                                rollNumber = value;
                                isButtonEnabled = value.length == 5;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          // Capture Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: (isButtonEnabled && !isProcessing)
                                  ? captureImage
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF667eea),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor:
                                    Color(0xFF667eea).withOpacity(0.5),
                              ),
                              child: isProcessing
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.camera_alt, size: 24),
                                        SizedBox(width: 12),
                                        Text(
                                          'Capture Image',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
