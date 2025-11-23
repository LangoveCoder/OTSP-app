import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTSP Attendance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system, // Use system theme mode
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isProcessing = false;
  TextEditingController _controller =
      TextEditingController(); // Controller for input field
  String? customNumber;
  bool isButtonEnabled = false;

  // Function to capture and save a single image
  Future<void> captureImage() async {
    try {
      if (customNumber == null || customNumber!.isEmpty) {
        Get.snackbar('Error', 'Please enter a roll number');
        return;
      }

      setState(() {
        _isProcessing = true;
      });

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        await saveImage(image);
      } else {
        Get.snackbar('Error', 'No image captured');
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e');
      print('Error: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Function to save a single image
  Future<void> saveImage(XFile image) async {
    try {
      // Load the image as a file
      File imageFile = File(image.path);

      // Get the directory for storing the image locally
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${customNumber!}.png';

      // Copy the image to the new location
      await imageFile.copy(filePath);

      // Save the image to the gallery
      await Gal.putImage(filePath);

      // Update the state to reflect the saved image and refresh the UI
      setState(() {
        _controller.clear(); // Clear the TextField
        customNumber = null; // Clear the custom number
        isButtonEnabled = false; // Disable the button
        _isProcessing = false;
      });

      Get.snackbar('Success', 'Image saved to gallery');
      print('Image saved at: $filePath');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save image: $e');
      print('Error: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ]
                : [
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
                    // App Title with modern styling
                    Text(
                      'OTSP ATTENDANCE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Balochistan Academy for College Teachers',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 40),

                    // Logo with glass morphism container
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo/logo.png',
                        width: 180,
                        height: 180,
                      ),
                    ),
                    SizedBox(height: 50),

                    // Modern Card for input
                    Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.95),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Roll Number Input with modern styling
                          TextField(
                            controller: _controller,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Color(0xFF2D3436),
                              letterSpacing: 3,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Roll Number',
                              labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : Color(0xFF636E72),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              hintText: '00000',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.5),
                                letterSpacing: 3,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Color(0xFFF5F6FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.blue.withOpacity(0.5)
                                      : Color(0xFF667eea),
                                  width: 2,
                                ),
                              ),
                              counterStyle: TextStyle(
                                color: isDark
                                    ? Colors.white.withOpacity(0.5)
                                    : Color(0xFF636E72),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            onChanged: (value) {
                              setState(() {
                                customNumber = value;
                                isButtonEnabled = value.length == 5;
                              });
                            },
                          ),
                          SizedBox(height: 30),

                          // Modern Capture Button with gradient and loading state
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: (isButtonEnabled && !_isProcessing)
                                  ? LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    )
                                  : null,
                              color: (isButtonEnabled && !_isProcessing)
                                  ? null
                                  : Colors.grey.withOpacity(0.3),
                              boxShadow: (isButtonEnabled && !_isProcessing)
                                  ? [
                                      BoxShadow(
                                        color:
                                            Color(0xFF667eea).withOpacity(0.5),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: (isButtonEnabled && !_isProcessing)
                                    ? captureImage
                                    : null,
                                child: Center(
                                  child: _isProcessing
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'PROCESSING...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt_rounded,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'CAPTURE IMAGE',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
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
