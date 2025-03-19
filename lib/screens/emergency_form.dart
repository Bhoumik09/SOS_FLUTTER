import 'dart:io';
import 'package:camera/camera.dart';
import 'package:emergency_app/Provider/location_provider.dart';
import 'package:emergency_app/screens/processsing_screen.dart';
import 'package:emergency_app/widgets/form_field.dart';
import 'package:emergency_app/widgets/location_container.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class EmergencyForm extends StatefulWidget {
  final String type;
  const EmergencyForm({required this.type, super.key});

  @override
  State<EmergencyForm> createState() => _EmergencyFormState();
}

class _EmergencyFormState extends State<EmergencyForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  File? _capturedImage; // To store the captured image
  File? _recordedVideo; // To store the recorded video
  bool _isRecording = false; // Track video recording status
  String? _errorMessage; // To display error messages

  @override
  void initState() {
    super.initState();

    // Fetch location when the widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchLocation();
    });

    _initializeCamera(); // Initialize the camera
  }

  Future<void> _initializeCamera() async {
    try {
      // Get available cameras and initialize the first one
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.ultraHigh,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
      setState(() {
        _errorMessage = null; // Clear any existing error messages
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize the camera: $e";
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;

      setState(() {
        _capturedImage = null;
        _errorMessage = null; // Clear any existing error messages
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error capturing photo: $e";
        _initializeCamera();
      });
    }
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;

      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(image.path);
        _errorMessage = null; // Clear any existing error messages
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            "Error capturing photo:Permission Defined or camera not found";
      });
    }
  }

  Future<void> _recordVideo() async {
    try {
      if (_isRecording) {
        // Stop recording
        final videoFile = await _cameraController!.stopVideoRecording();
        setState(() {
          _recordedVideo = File(videoFile.path);
          _isRecording = false;
          _errorMessage = null; // Clear any existing error messages
        });
      } else {
        // Start recording
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _errorMessage = null; // Clear any existing error messages
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error recording video: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        title: Center(
          child: Text(
            "${widget.type.toUpperCase()} FORM",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Form(
                  child: Column(
                    children: [
                      FormFields(text: "Name", controller: _nameController),
                      const SizedBox(height: 16),
                      FormFields(
                          text: "Mobile Number",
                          controller: _mobileNumberController),
                      const SizedBox(height: 10),

                      // Display error message if any
                      if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Camera preview or message if not initialized
                      if (_cameraController != null &&
                          _cameraController!.value.isInitialized &&
                          _capturedImage == null)
                        SizedBox(
                          height: 500,
                          width: 500,
                          child: CameraPreview(_cameraController!),
                        )
                      else if (_cameraController == null)
                        const Text('Camera not initialized'),

                      const SizedBox(height: 20),

                      // Buttons for capturing photo and recording video
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                              onPressed: _capturedImage == null
                                  ? _capturePhoto
                                  : _takePhoto,
                              icon: const Icon(Icons.camera),
                              label: _capturedImage == null
                                  ? const Text('Capture Photo')
                                  : const Text('Open Camera')),
                          ElevatedButton.icon(
                            onPressed: () => {},
                            icon: Icon(
                              _isRecording ? Icons.stop : Icons.videocam,
                            ),
                            label: Text(_isRecording
                                ? 'Stop Recording'
                                : 'Record Video'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Display captured image or recorded video
                      if (_capturedImage != null)
                        Column(
                          children: [
                            const Text('Captured Image:'),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Image.file(
                                _capturedImage!,
                                height: 500,
                                width: 500,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      if (_recordedVideo != null)
                        Column(
                          children: [
                            const Text('Recorded Video:'),
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child:
                                  VideoPlayerWidget(videoFile: _recordedVideo!),
                            ),
                          ],
                        ),
                      const LocationContainer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                        ),
                        onPressed: () {
                          if (_nameController.text.isEmpty ||
                              _mobileNumberController.text.isEmpty) {
                            setState(() {
                              _errorMessage = "Please fill all fields.";
                            });
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProcessingScreen(
                                name: _nameController.text,
                                mobile: _mobileNumberController.text,
                                imagePath: _capturedImage?.path ?? "",
                                videoPath: _recordedVideo?.path ?? "",
                              ),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on),
                            SizedBox(width: 8),
                            Text("Submit"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget to play recorded video
class VideoPlayerWidget extends StatefulWidget {
  final File videoFile;

  const VideoPlayerWidget({required this.videoFile, super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoController.value.isInitialized
        ? VideoPlayer(_videoController)
        : const CircularProgressIndicator();
  }
}
