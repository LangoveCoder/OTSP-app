import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:gal/gal.dart'; // Updated import

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
  List<XFile> _images = []; // To store images
  TextEditingController _controller =
      TextEditingController(); // Controller for input field
  String? customNumber;
  bool isButtonEnabled = false;

  // Function to capture an image
  Future<void> captureImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          _images.add(image); // Add the captured image to the list
        });

        // If two images are captured, combine them
        if (_images.length == 2) {
          await stackImages(_images[0], _images[1]);
        }
      } else {
        Get.snackbar('Error', 'No image captured');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture image: $e');
      print('Error: $e');
    }
  }

  // Function to stack images side-by-side using dart:ui
  Future<void> stackImages(XFile image1, XFile image2) async {
    try {
      if (customNumber == null || customNumber!.isEmpty) {
        Get.snackbar('Error', 'Please enter a number');
        return;
      }

      // Load the images as files
      File file1 = File(image1.path);
      File file2 = File(image2.path);

      // Decode the images into ui.Image
      ui.Image img1 = await _loadImage(file1);
      ui.Image img2 = await _loadImage(file2);

      // Resize the images (350px width, 500px height for each)
      img1 = await _resizeImage(img1, 960, 1080);
      img2 = await _resizeImage(img2, 960, 1080);

      // Create a new image to combine both images (700px width, 500px height)
      final recorder = ui.PictureRecorder();
      final canvas =
          Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(1920, 1080)));

      // Draw both images side-by-side
      canvas.drawImage(img1, Offset(0, 0), Paint());
      canvas.drawImage(img2, Offset(960, 0), Paint());

      // End recording and convert to image
      final picture = recorder.endRecording();
      final imgByteData = await picture.toImage(1920, 1080);
      final byteData =
          await imgByteData.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Get the directory for storing the image locally
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/${customNumber!}.png'; // Use custom number only

      // Save the composite image
      final compositeFile = File(filePath)..writeAsBytesSync(bytes);

      // Save the image to the gallery
      await Gal.putImage(filePath); // Updated method call

      // Update the state to reflect the saved image and refresh the UI
      setState(() {
        _images.clear(); // Clear the images list after processing
        _controller.clear(); // Clear the TextField
        customNumber = null; // Clear the custom number
        isButtonEnabled = false; // Disable the button
      });

      Get.snackbar(
          'Success', 'Images stacked and saved to gallery at $filePath');
      print('Composite image saved at: $filePath');
    } catch (e) {
      Get.snackbar('Error', 'Failed to process images: $e');
      print('Error: $e');
    }
  }

  // Function to load an image from a file
  Future<ui.Image> _loadImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(Uint8List.fromList(bytes), (result) {
        return completer.complete(result);
      });
      return completer.future;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load image: $e');
      print('Error: $e');
      rethrow;
    }
  }

  // Function to resize the image
  Future<ui.Image> _resizeImage(ui.Image image, int width, int height) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
          recorder,
          Rect.fromPoints(
              Offset(0, 0), Offset(width.toDouble(), height.toDouble())));
      final paint = Paint();
      canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
          paint);
      final picture = recorder.endRecording();
      final imgByteData = await picture.toImage(width, height);
      return imgByteData;
    } catch (e) {
      Get.snackbar('Error', 'Failed to resize image: $e');
      print('Error: $e');
      rethrow;
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

                          // Modern Capture Button with gradient
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: isButtonEnabled
                                  ? LinearGradient(
                                      colors: [
                                        Color(0xFF667eea),
                                        Color(0xFF764ba2),
                                      ],
                                    )
                                  : null,
                              color: isButtonEnabled
                                  ? null
                                  : Colors.grey.withOpacity(0.3),
                              boxShadow: isButtonEnabled
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
                                onTap: isButtonEnabled ? captureImage : null,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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

                          // Status indicator
                          if (_images.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildImageIndicator(_images.length >= 1),
                                  SizedBox(width: 10),
                                  _buildImageIndicator(_images.length >= 2),
                                ],
                              ),
                            ),
                          if (_images.length == 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Two images captured!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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

  // Helper widget for image capture indicators
  Widget _buildImageIndicator(bool captured) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: captured
            ? Colors.green.withOpacity(0.2)
            : Colors.white.withOpacity(0.1),
        border: Border.all(
          color: captured ? Colors.green : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        captured ? Icons.check : Icons.camera_alt_outlined,
        color: captured ? Colors.green : Colors.white.withOpacity(0.5),
        size: 24,
      ),
    );
  }
}
