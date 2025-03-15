import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(PhotoPerfectApp());
}

class PhotoPerfectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Parfaite',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: UploadPhotoPage(),
    );
  }
}

class UploadPhotoPage extends StatefulWidget {
  @override
  _UploadPhotoPageState createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  File? _image;
  String? _bestPhotoUrl;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://127.0.0.1:8000/api/upload/'));
    request.files.add(await http.MultipartFile.fromPath('images', _image!.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    if (response.statusCode == 200) {
      setState(() {
        _bestPhotoUrl = "http://127.0.0.1:8000" + jsonResponse['image_url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Parfaite')),
      body: Column(
        children: [
          _image != null ? Image.file(_image!, height: 200) : Text("Sélectionne une image"),
          ElevatedButton(onPressed: _pickImage, child: Text("Choisir une image")),
          ElevatedButton(onPressed: _uploadImage, child: Text("Envoyer")),
          if (_bestPhotoUrl != null) Image.network(_bestPhotoUrl!, height: 200),
        ],
      ),
    );
  }
}
