import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Feature Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ShareScreen(),
    );
  }
}

class ShareScreen extends StatefulWidget {
  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  GlobalKey _globalKey = GlobalKey();
  static const platform = MethodChannel('com.example.share/share');

  // Method to capture widget as image
  Future<Uint8List> _captureWidget() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData!.buffer.asUint8List();
    } catch (e) {
      print('Error capturing widget: $e');
      throw e;
    }
  }

  // Method to save image to device using platform channel
  Future<String> _saveImage(Uint8List imageBytes) async {
    try {
      // Use platform channel to save image and get path
      final String? imagePath = await platform.invokeMethod('saveImage', {
        'imageBytes': imageBytes,
      });

      if (imagePath != null) {
        return imagePath;
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      print('Error saving image: $e');
      throw e;
    }
  }

  // Share image to specific apps
  Future<void> _shareImage() async {
    try {
      final imageBytes = await _captureWidget();
      final imagePath = await _saveImage(imageBytes);

      // Show dialog to choose sharing option
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Share Image'),
            content: Text('Choose where to share your image:'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareToTwitter(imagePath);
                },
                child: Text('Twitter'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareToWhatsApp(imagePath);
                },
                child: Text('WhatsApp'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareImageGeneral(imagePath);
                },
                child: Text('Other Apps'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showErrorDialog('Failed to share image: $e');
    }
  }

  // Share to Twitter
  Future<void> _shareToTwitter(String imagePath) async {
    try {
      await platform.invokeMethod('shareToTwitter', {
        'imagePath': imagePath,
        'text': 'Check out this awesome image!',
      });
    } catch (e) {
      _showErrorDialog('Failed to share to Twitter: $e');
    }
  }

  // Share to WhatsApp
  Future<void> _shareToWhatsApp(String imagePath) async {
    try {
      await platform.invokeMethod('shareToWhatsApp', {
        'imagePath': imagePath,
        'text': 'Check out this image!',
      });
    } catch (e) {
      _showErrorDialog('Failed to share to WhatsApp: $e');
    }
  }

  // General image sharing
  Future<void> _shareImageGeneral(String imagePath) async {
    try {
      await platform.invokeMethod('shareImage', {
        'imagePath': imagePath,
        'text': 'Check out this awesome image!',
      });
    } catch (e) {
      _showErrorDialog('Failed to share image: $e');
    }
  }

  // Share text/link
  Future<void> _shareTextLink() async {
    try {
      const String textToShare =
          'Check out this awesome app! https://example.com';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Share Link'),
            content: Text('Choose where to share the link:'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareTextToTwitter(textToShare);
                },
                child: Text('Twitter'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareTextToWhatsApp(textToShare);
                },
                child: Text('WhatsApp'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _shareTextGeneral(textToShare);
                },
                child: Text('Other Apps'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showErrorDialog('Failed to share text: $e');
    }
  }

  // Share text to Twitter
  Future<void> _shareTextToTwitter(String text) async {
    try {
      await platform.invokeMethod('shareTextToTwitter', {'text': text});
    } catch (e) {
      _showErrorDialog('Failed to share to Twitter: $e');
    }
  }

  // Share text to WhatsApp
  Future<void> _shareTextToWhatsApp(String text) async {
    try {
      await platform.invokeMethod('shareTextToWhatsApp', {'text': text});
    } catch (e) {
      _showErrorDialog('Failed to share to WhatsApp: $e');
    }
  }

  // General text sharing
  Future<void> _shareTextGeneral(String text) async {
    try {
      await platform.invokeMethod('shareText', {'text': text});
    } catch (e) {
      _showErrorDialog('Failed to share text: $e');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share Feature Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Widget to be captured as image
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 50, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Share This!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      DateTime.now().toString().split('.')[0],
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            // Share Image Button
            ElevatedButton.icon(
              onPressed: _shareImage,
              icon: Icon(Icons.image),
              label: Text('Share Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 20),

            // Share Text/Link Button
            ElevatedButton.icon(
              onPressed: _shareTextLink,
              icon: Icon(Icons.link),
              label: Text('Share Text/Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 30),

            Text(
              'Tap the buttons above to share content\nto Twitter, WhatsApp, or other apps',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
