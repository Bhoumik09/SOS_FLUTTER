import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    _sendDataToServer();
  }

  Future<void> _sendDataToServer() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.148.83:5000/send-request'), // Use 127.0.0.1 for iOS
      );

      request.fields['name'] = widget.name;
      request.fields['mobile'] = widget.mobile;

      if (widget.imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          widget.imagePath,
        ));
      }

      if (widget.videoPath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'video',
          widget.videoPath,
        ));
      }

      var response = await request.send();
      var responseBody =await response.stream.bytesToString(); // Convert to text
      print("Response Status: ${response.statusCode}");
      print("Response Body: $responseBody");
      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = "✅ Success!";
        });
      } else {
        setState(() {
          _statusMessage = "❌ Failed. Try again.";
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Error: $e";
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
