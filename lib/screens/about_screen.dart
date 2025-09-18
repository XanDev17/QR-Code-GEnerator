import 'package:flutter/material.dart';
import 'dart:math' as Math;

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = Math.min(screenWidth, screenHeight) / 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0 * scaleFactor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(height: 20 * scaleFactor),
            Icon(
              Icons.qr_code,
              size: 80 * scaleFactor,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 16 * scaleFactor),
            Text(
              'QR Code Generator',
              style: TextStyle(
                fontSize: 25 * scaleFactor,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 20 * scaleFactor,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5 * scaleFactor),
            Card(
              color:Colors.white70 ,
              child: Padding(
                padding: EdgeInsets.all(16.0 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features:',
                      style: TextStyle(
                        fontSize: 22 * scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2 * scaleFactor),
                    ListTile(
                      leading: Icon(Icons.link, color: Colors.deepPurple, size: 30 * scaleFactor),
                      title: Text('URL Generation', style: TextStyle(fontSize: 30 * scaleFactor)),
                      subtitle: Text('Generate QR codes for any website URL', style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 20 * scaleFactor)),
                    ),
                    ListTile(
                      leading: Icon(Icons.contact_mail, color: Colors.deepPurple, size: 30 * scaleFactor),
                      title: Text('Contact Information', style: TextStyle(fontSize: 30 * scaleFactor)),
                      subtitle: Text('Create QR codes for contact details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor)),
                    ),
                    ListTile(
                      leading: Icon(Icons.text_fields, color: Colors.deepPurple, size: 30 * scaleFactor),
                      title: Text('Plain Text', style: TextStyle(fontSize: 30 * scaleFactor)),
                      subtitle: Text('Encode any text into a QR code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor)),
                    ),
                     ListTile(
                      leading: Icon(Icons.numbers, color: Colors.deepPurple, size: 30 * scaleFactor),
                      title: Text('Number', style: TextStyle(fontSize: 30 * scaleFactor)),
                      subtitle: Text('Generate QR codes for Numberd', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor)),
                    ),
                    ListTile(
                      leading: Icon(Icons.sms, color: Colors.deepPurple, size: 30 * scaleFactor),
                      title: Text('SMS Message', style: TextStyle(fontSize: 30 * scaleFactor)),
                      subtitle: Text('Generate QR codes for SMS messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor)),
                    ),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.deepPurple, size: 30 * scaleFactor),
                      title: Text('Email', style: TextStyle(fontSize: 30 * scaleFactor)),
                      subtitle: Text('Generate QR codes for Email sending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20 * scaleFactor)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16 * scaleFactor),
            Card( color: Colors.white70,
              child: Padding(
                padding: EdgeInsets.all(16.0 * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About the App:',
                      style: TextStyle(
                        fontSize: 22 * scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8 * scaleFactor),
                    Text(
                      'QR Code Generator is a powerful tool that helps you generate QR codes for various purposes. '
                          'Whether you need to share website links, contact details and email composing, '
                          'QR Code Generator has got you covered.',
                      style: TextStyle(fontSize: 20 * scaleFactor),
                    ),
                    SizedBox(height: 8 * scaleFactor),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
