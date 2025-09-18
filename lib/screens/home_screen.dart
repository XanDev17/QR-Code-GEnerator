import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math' as Math;
import '../downloader.dart' as downloader;

enum QrCodeType { url, contact, text, number, sms, email }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _qrKey = GlobalKey();
  String qrData = "";
  QrCodeType _selectedQrType = QrCodeType.url;
  final _urlController = TextEditingController();
  final _connumber = TextEditingController();
  final _telnumber = TextEditingController();
  final _smsnumber = TextEditingController();
  final _messageController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _textController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailSubjectController = TextEditingController();
  final _emailMessageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _downloadQrCode() async {
    bool isInvalid = false;
    switch (_selectedQrType) {
      case QrCodeType.url:
        if (_urlController.text.isEmpty) {
          isInvalid = true;
        } else {
          final urlRegex = RegExp(
              r'^(https?:\/\/|ftp:\/\/|mailto:|file:\/\/)?(www\.|blog\.|shop\.|support\.|help\.|forum\.)?([a-zA-Z0-9-]+\.)+([a-zA-Z]{2,}|com|org|net|edu|gov|io|co|info|us|biz|me|tv|cc|ai|uk|ca|de|fr|jp|au|in|cn|br|ru|dev|app|xyz|mobi)\/?$');
          if (!urlRegex.hasMatch(_urlController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid link'),
                duration: Duration(milliseconds: 500),
              ),
            );
            return;
          }
        }
        break;
      case QrCodeType.contact:
        if (_contactNameController.text.isEmpty || _connumber.text.isEmpty) {
          isInvalid = true;
        } else {
          final phoneError = _validatePhoneNumber(_connumber.text);
          if (phoneError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(phoneError),
                duration: const Duration(milliseconds: 500),
              ),
            );
            return;
          }
        }
        break;
      case QrCodeType.text:
        if (_textController.text.isEmpty) {
          isInvalid = true;
        }
        break;
      case QrCodeType.number:
        if (_telnumber.text.isEmpty) {
          isInvalid = true;
        } else {
          final phoneError = _validatePhoneNumber(_telnumber.text);
          if (phoneError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(phoneError),
                duration: const Duration(milliseconds: 500),
              ),
            );
            return;
          }
        }
        break;
      case QrCodeType.sms:
        if (_smsnumber.text.isEmpty || _messageController.text.isEmpty) {
          isInvalid = true;
        } else {
          final phoneError = _validatePhoneNumber(_smsnumber.text);
          if (phoneError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(phoneError),
                duration: const Duration(milliseconds: 1500),
              ),
            );
            return;
          }
        }
        break;
      case QrCodeType.email:
        if (_emailController.text.isEmpty) {
          isInvalid = true;
        } else {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(_emailController.text)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email'),
                duration: Duration(milliseconds: 1500),
              ),
            );
            return;
          }
        }
        break;
    }

    if (isInvalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled'),
          duration: Duration(milliseconds: 500),
        ),
      );
      return;
    }

    RenderRepaintBoundary boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    if (!kIsWeb) {
      final result = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: "qr_code_\${DateTime.now().millisecondsSinceEpoch}.jpg",
        );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code saved to gallery')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save QR code')),
        );
      }
    } else {
      downloader.downloadQrCode(pngBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR code downloaded')),
      );
    }
  }

  String? _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 10) {
      return 'Number must be 10 digits';
    }
    if (!phoneNumber.startsWith('0')) {
      return 'Telephone Number must start with 0';
    }
    return null;
  }

  void _createQrCode() {
    setState(() {
      switch (_selectedQrType) {
        case QrCodeType.url:
          qrData = _urlController.text;
          if (!qrData.startsWith('http://') && !qrData.startsWith('https://')) {
            qrData = 'https://' + qrData;
          }
          if (qrData.isEmpty) qrData = " ";
          break;
        case QrCodeType.contact:
          qrData = "BEGIN:VCARD\nVERSION:3.0\nFN:${_contactNameController.text}\nTEL;TYPE=CELL:${_connumber.text}\nEND:VCARD";
          break;
        case QrCodeType.sms:
          qrData = "smsto:${_smsnumber.text}:${_messageController.text}";
          break;
        case QrCodeType.text:
          qrData = _textController.text;
          if (qrData.isEmpty) qrData = " ";
          break;
        case QrCodeType.number:
          qrData = "tel:${_telnumber.text}";
          break;
        case QrCodeType.email:
          qrData = "mailto:${_emailController.text}?subject=${Uri.encodeComponent(_emailSubjectController.text)}&body=${Uri.encodeComponent(_emailMessageController.text)}";
          break;
      }
    });
  }

  Widget _buildQrFormFields(double scaleFactor) {
    switch (_selectedQrType) {
      case QrCodeType.url:
        return TextFormField(
          controller: _urlController,
          decoration: InputDecoration(
            
            labelText: "Enter URL",
            hintText: "eg.., www.facebook.com",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scaleFactor),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _urlController.clear();
                setState(() {
                  qrData = "";
                });
              },
            ),
          ),
          onChanged: (value) {
            _createQrCode();
          },
        );
      case QrCodeType.contact:
        return Column(
          children: [
            TextFormField(
              controller: _connumber,
              decoration: InputDecoration(
                labelText: "Enter Telephone Number",
                hintText: "Enter telephone number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _connumber.clear();
                    _createQrCode();
                  },
                ),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                _createQrCode();
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            SizedBox(height: 20 * scaleFactor),
            TextFormField(
              controller: _contactNameController,
              decoration: InputDecoration(
                labelText: "Enter Name",
                hintText: "Enter contact name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _contactNameController.clear();
                    _createQrCode();
                  },
                ),
              ),
              onChanged: (value) {
                _createQrCode();
              },
            ),
            SizedBox(height: 20 * scaleFactor),
          ],
        );
      case QrCodeType.text:
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: "Enter Text",
            hintText: "Enter any text",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scaleFactor),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _textController.clear();
                _createQrCode();
              },
            ),
          ),
          maxLines: 3,
          onChanged: (value) => _createQrCode(),
        );
      case QrCodeType.number:
        return TextFormField(
          controller: _telnumber,
          decoration: InputDecoration(
            labelText: "Enter Telephone Number",
            hintText: "Enter telephone number",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10 * scaleFactor),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _telnumber.clear();
                _createQrCode();
              },
            ),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            _createQrCode();
          },
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        );
      case QrCodeType.sms:
        return Column(
          children: [
            TextFormField(
              controller: _smsnumber,
              decoration: InputDecoration(
                labelText: "Enter Telephone Number",
                hintText: "Enter telephone number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _smsnumber.clear();
                    _createQrCode();
                  },
                ),
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                _createQrCode();
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            SizedBox(height: 20 * scaleFactor),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Enter Message",
                hintText: "Enter message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _messageController.clear();
                    _createQrCode();
                  },
                ),
              ),
              maxLines: 3,
              onChanged: (value) => _createQrCode(),
            ),
          ],
        );
      case QrCodeType.email:
        return Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Enter Email",
                hintText: "Enter email address",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _emailController.clear();
                    _createQrCode();
                  },
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _createQrCode();
              },
            ),
            SizedBox(height: 20 * scaleFactor),
            TextFormField(
              controller: _emailSubjectController,
              decoration: InputDecoration(
                labelText: "Enter Subject",
                hintText: "Enter email subject",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _emailSubjectController.clear();
                    _createQrCode();
                  },
                ),
              ),
              onChanged: (value) {
                _createQrCode();
              },
            ),
            SizedBox(height: 20 * scaleFactor),
            TextFormField(
              controller: _emailMessageController,
              decoration: InputDecoration(
                labelText: "Enter Message",
                hintText: "Enter email message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _emailMessageController.clear();
                    _createQrCode();
                  },
                ),
              ),
              maxLines: 3,
              onChanged: (value) => _createQrCode(),
            ),
          ],
        );
    }
  }

  void _clearControllers() {
    _urlController.clear();
    _connumber.clear();
    _telnumber.clear();
    _smsnumber.clear();
    _messageController.clear();
    _contactNameController.clear();
    _textController.clear();
    _emailController.clear();
    _emailSubjectController.clear();
    _emailMessageController.clear();
    setState(() {
      qrData = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = Math.min(screenWidth, screenHeight) / 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Generator", style: TextStyle(color: Colors.white,
        )),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.grey, Colors.indigo],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0 * scaleFactor),
              child: SizedBox(
                width: screenWidth * 0.9,
                child: Card(
                  color: Colors.grey[200],
                  elevation: 8,
                  shadowColor: Colors.blue.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15 * scaleFactor),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.0 * scaleFactor),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'QR Code Preview',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 29 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 10 * scaleFactor),
                          const Center(child: Text("Your QR codes will appear here")),
                          SizedBox(height: 25 * scaleFactor),
                          Center(
                            child: RepaintBoundary(
                              key: _qrKey,
                              child: QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 400 * scaleFactor,
                                backgroundColor: Colors.white,
                                gapless: false,
                              ),
                            ),
                          ),
                          SizedBox(height: 10 * scaleFactor),
                          SizedBox(height: 10 * scaleFactor),
                          Text(
                            'Create QR Code',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 29 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 2 * scaleFactor),
                          Text(
                            'in this formats, '
                                'click to select your preference',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20 * scaleFactor,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 10 * scaleFactor),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedQrType = QrCodeType.url;
                                          _clearControllers();
                                          _formKey.currentState?.reset();
                                        });
                                      },
                                      child: Column(children: [
                                        Icon(Icons.link, color: _selectedQrType == QrCodeType.url ? Colors.deepPurple : Colors.grey),
                                        Text("URL", style: TextStyle(color: _selectedQrType == QrCodeType.url ? Colors.deepPurple : Colors.grey))
                                      ])),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedQrType = QrCodeType.contact;
                                          _clearControllers();
                                          _formKey.currentState?.validate();
                                        });
                                      },
                                      child: Column(children: [
                                        Icon(Icons.contacts, color: _selectedQrType == QrCodeType.contact ? Colors.deepPurple : Colors.grey),
                                        Text("Contact", style: TextStyle(color: _selectedQrType == QrCodeType.contact ? Colors.deepPurple : Colors.grey))
                                      ])),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedQrType = QrCodeType.text;
                                          _clearControllers();
                                          _formKey.currentState?.reset();
                                        });
                                      },
                                      child: Column(children: [
                                        Icon(Icons.text_fields, color: _selectedQrType == QrCodeType.text ? Colors.deepPurple : Colors.grey),
                                        Text("Text", style: TextStyle(color: _selectedQrType == QrCodeType.text ? Colors.deepPurple : Colors.grey))
                                      ])),
                                ],
                              ),
                              SizedBox(height: 20 * scaleFactor),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedQrType = QrCodeType.number;
                                          _clearControllers();
                                          _formKey.currentState?.reset();
                                        });
                                      },
                                      child: Column(children: [
                                        Icon(Icons.phone, color: _selectedQrType == QrCodeType.number ? Colors.deepPurple : Colors.grey),
                                        Text("Number", style: TextStyle(color: _selectedQrType == QrCodeType.number ? Colors.deepPurple : Colors.grey))
                                      ])),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedQrType = QrCodeType.sms;
                                          _clearControllers();
                                          _formKey.currentState?.reset();
                                        });
                                      },
                                      child: Column(children: [
                                        Icon(Icons.sms, color: _selectedQrType == QrCodeType.sms ? Colors.deepPurple : Colors.grey),
                                        Text("SMS", style: TextStyle(color: _selectedQrType == QrCodeType.sms ? Colors.deepPurple : Colors.grey))
                                      ])),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedQrType = QrCodeType.email;
                                          _clearControllers();
                                          _formKey.currentState?.reset();
                                        });
                                      },
                                      child: Column(children: [
                                        Icon(Icons.email, color: _selectedQrType == QrCodeType.email ? Colors.deepPurple : Colors.grey),
                                        Text("Email", style: TextStyle(color: _selectedQrType == QrCodeType.email ? Colors.deepPurple : Colors.grey))
                                      ])),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20 * scaleFactor),
                          _buildQrFormFields(scaleFactor),
                          SizedBox(height: 20 * scaleFactor),
                          ElevatedButton(
                            onPressed: _downloadQrCode,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              padding:
                                  EdgeInsets.symmetric(vertical: 15 * scaleFactor),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10 * scaleFactor),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 10),
                                Text('Download QR Code'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
