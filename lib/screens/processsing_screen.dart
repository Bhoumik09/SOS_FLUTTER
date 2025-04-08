import 'dart:convert';
import 'dart:io';

import 'package:emergency_app/Provider/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class ProcessingScreen extends StatefulWidget {
  final String name;
  final String mobile;
  final String imagePath;
  final String videoPath;

  const ProcessingScreen({
    required this.name,
    required this.mobile,
    required this.imagePath,
    required this.videoPath,
    super.key,
  });

  @override
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _statusMessage = "Processing...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uploadImage(File(widget.imagePath));
  }

  Future<void> _sendDataToServer(String imageUrl, String imageClass) async {
    try {
      final url = Uri.parse('https://sos-backend-uj48.onrender.com/send-request');
      final headers = {
        'Content-Type': 'application/json',
      };
      final deviceId =await  _getDeviceId();
      final body = {
        "name": widget.name, // ${widget.name}
        "mobile": widget.mobile, // ${widget.mobile}
        "image_url": imageUrl, // ${widget.imagePath}
        "device_id": deviceId,
        "request_type": "fire",
        "longitude": LocationProvider().currentPosition?.longitude ?? 76.84978,
        "latitude": LocationProvider().currentPosition?.latitude ?? 23.07551,
        "image_classification": imageClass.toLowerCase(), // ${widget.imagePath}
      };
      setState(() {
        _statusMessage = "Sending data...";
      });
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) { // Check for the correct success status code
        setState(() {
          _statusMessage = "✅ Success!";
        });
      } else {
        setState(() {
          _statusMessage = "❌ Failed: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = " $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<String> _getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Unique per device
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? "unknown_ios";
  }
  return "unknown_device";
}

  Future<void> _uploadImage(File imageFile) async {
  try {
    final url = Uri.parse('https://sos-backend-uj48.onrender.com/upload-file');
    final request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    ));

    // Send request and get streamed response
    final streamedResponse = await request.send();

    // Convert streamed response to regular response
    final response = await http.Response.fromStream(streamedResponse);
  print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // Assuming server sends JSON
      print(data);
      setState(() {
        _statusMessage = "✅ Uploaded: ${data['message'] ?? 'Success!'}";
       // Extract image_url
        
        // You can also use: data['image_url'] or any other field if available
      });
      final imageUrl = data['imageUrl']; // Extract image_url
      final imageClassification = data['predictionClassification']; // Extract image_classification
      print(imageUrl);
      print(imageClassification);
       setState(() {
        _statusMessage = "✅ Image uploaded!";
      });
            await _sendDataToServer(imageUrl, imageClassification); // Send data to server

    } else {
      setState(() {
        _statusMessage =
            "❌ Failed: ${response.statusCode} - ${response.reasonPhrase}\n${response.body}";
      });
    }
  } catch (e) {
    setState(() {
      _statusMessage = "❌ Error uploading image: $e";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Processing...")),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _statusMessage,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Back"),
                  ),
                ],
              ),
      ),
    );
  }
}


