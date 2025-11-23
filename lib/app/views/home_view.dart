import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';

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
      debugPrint('Error: $e');
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
      debugPrint('Composite image saved at: $filePath');
    } catch (e) {
      Get.snackbar('Error', 'Failed to process images: $e');
      debugPrint('Error: $e');
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
      debugPrint('Error: $e');
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
      debugPrint('Error: $e');
      rethrow;
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
      appBar: AppBar(
        title: const Text('OTSP Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Add logo above the text field
            const SizedBox(
              height: 50,
            ),
            Image.asset(
              'assets/logo/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(
              height: 20,
            ),
            // TextField to enter custom number
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter roll number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number, // Allow only numbers
                maxLength: 5, // Limit input to 5 digits
                onChanged: (value) {
                  setState(() {
                    customNumber = value;
                    isButtonEnabled = value.length ==
                        5; // Enable button if 5 digits are entered
                  });
                },
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton.icon(
              onPressed: isButtonEnabled
                  ? captureImage
                  : null, // Disable button if not enabled
              icon: const Icon(Icons.camera_alt), // Camera icon
              label: const Text('Capture Image'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            if (_images.length == 2)
              const Text(
                'Two images captured!',
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
