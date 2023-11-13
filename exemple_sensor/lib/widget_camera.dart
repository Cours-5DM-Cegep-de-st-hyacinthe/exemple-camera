

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class WidgetCamera extends StatefulWidget {

  @override
  State<WidgetCamera> createState() => _WidgetCameraState();
}

class _WidgetCameraState extends State<WidgetCamera> {
  bool _isLoading = true;
  late CameraDescription _camera;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    WidgetsFlutterBinding.ensureInitialized();

    _initCamera();
  }

  _initCamera() async {
    final cameras = await availableCameras();

    _camera = cameras.first;

    _controller = CameraController(_camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();

    setState(() {
      _isLoading = false;
    });
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Caméra"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
        ? const CircularProgressIndicator()
        : Column(children: [
          FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
            })
        ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            if(!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => DisplayPictureScreen(
                  imagePath: image.path
              ))
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt)
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Caméra"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Image.file(File(imagePath))
    );
  }
}