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
      debugShowCheckedModeBanner: false,
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
  List<File> _selectedImages = [];
  List<String> _bestPhotoUrls = [];
  bool _isLoading = false;

  // 📌 Sélectionner plusieurs images
  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  // 📌 Envoyer les images à l'API
  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isLoading = true;
      _bestPhotoUrls = [];
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/api/upload/'),
    );

    for (var image in _selectedImages) {
      request.files.add(await http.MultipartFile.fromPath('images', image.path));
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseData);

    if (response.statusCode == 200) {
      setState(() {
        _bestPhotoUrls = List<String>.from(jsonResponse['best_images']);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 📌 Texte de bienvenue
              Text(
                "✨ Bienvenue ! ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              SizedBox(height: 20),

              Text(
                  "Je t'aide à trouver tes photos parfaites ✨",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              SizedBox(height: 20),

              // 📌 Sélectionner plusieurs images
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6)],
                  ),
                  child: _selectedImages.isNotEmpty
                      ? ListView(
                          scrollDirection: Axis.horizontal,
                          children: _selectedImages.map((image) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(image, height: 120, width: 120, fit: BoxFit.cover),
                              ),
                            );
                          }).toList(),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50, color: Colors.teal),
                              SizedBox(height: 8),
                              Text("Sélectionner des images", style: TextStyle(color: Colors.teal, fontSize: 16)),
                            ],
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),

              // 📌 Boutons d'action
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: Icon(Icons.image),
                    label: Text("Choisir Photos"),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _uploadImages,
                    icon: Icon(Icons.upload),
                    label: Text("Analyser"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 📌 Animation de chargement
              if (_isLoading) CircularProgressIndicator(),

              // 📌 Affichage des 3 meilleures photos
              if (_bestPhotoUrls.isNotEmpty) ...[
                SizedBox(height: 20),
                Text("🌟 Vos 3 meilleures photos 🌟", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _bestPhotoUrls.map((url) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "http://127.0.0.1:8000$url",
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
