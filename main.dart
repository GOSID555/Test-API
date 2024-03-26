import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CP213 (2/2566): Mobile Programming',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  late File _image;
  bool _imageSelected = false;

  List<dynamic>? _recognitions;
  Future _classifyImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
    );
    setState(() {
      _recognitions = recognitions!;
      _image = image;
      _imageSelected = true;
    });
    debugPrint('The result is: $_recognitions');
  }

  @override
  void initState() {
    super.initState();
    _loadmodel();
  }

  @override
  void dispose() async {
    await Tflite.close();
    super.dispose();
  }

  Future<void> _loadmodel() async {
    String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
    debugPrint('Load model result: $res');
  }

  Future _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;
      File image = File(pickedFile.path);
      _classifyImage(image);
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amber.shade300,
        body: SafeArea(
          child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    _imageSelected
                        ? Image.file(
                            _image,
                            width: 160.0,
                            fit: BoxFit.fitHeight,
                          )
                        : const FlutterLogo(size: 160),
                    const SizedBox(height: 24),
                    _recognitions != null
                        ? Text(
                            'Result: ${_recognitions![0]['label']} /Confidence:${_recognitions![0]['confidence']}')
                        : const Text(' '),
                    const SizedBox(
                      height: 24,
                    ),
                    const Text('Cat-Dog Image Classification',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(
                      height: 48,
                    ),
                    buildButton(
                        title: 'Pick Gallery',
                        icon: Icons.image_outlined,
                        onClicked: _pickImageFromGallery),
                    const SizedBox(
                      height: 24,
                    ),
                    buildButton(
                        title: 'Pick Camera',
                        icon: Icons.camera_alt_outlined,
                        onClicked: () {}),
                    const Spacer()
                  ])),
        ));
  }

  Widget buildButton(
      {required String title,
      required IconData icon,
      required VoidCallback onClicked}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontSize: 20)),
      onPressed: onClicked,
      child: Row(children: [
        Icon(icon, size: 28),
        const SizedBox(width: 16),
        Text(title)
      ]),
    );
  }
}
