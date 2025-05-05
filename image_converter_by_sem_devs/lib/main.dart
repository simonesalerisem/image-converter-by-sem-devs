/// Flutter Image Editor (One Page App)
/// Features: Drag & drop, bulk image conversion, compression, resize
/// 
/// Add dependency in pubspec.yaml:
/// webp_image: ^0.1.0 # (example, hypothetical dependency, replace with real WebP support if available)

// main.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' show encodeWebP;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageEditorPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'DM Sans'),
    );
  }
}

class ImageEditorPage extends StatefulWidget {
  const ImageEditorPage({super.key});

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  late DropzoneViewController dropController;
  List<Uint8List> images = [];
  List<String> fileNames = [];
  String format = 'jpg';
  int quality = 80;
  int? resizeWidth;
  int? resizeHeight;

  Future<void> processImages() async {
    final directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return; // User cancelled

    final outputDir = Directory(directoryPath);

    for (var i = 0; i < images.length; i++) {
      final decoded = img.decodeImage(images[i]);
      if (decoded == null) continue;

      img.Image finalImage = decoded;
      if (resizeWidth != null && resizeHeight != null) {
        finalImage = img.copyResize(decoded, width: resizeWidth!, height: resizeHeight!);
      }

      Uint8List encoded;
      String ext;
      switch (format) {
        case 'jpg':
          encoded = Uint8List.fromList(img.encodeJpg(finalImage, quality: quality));
          ext = 'jpg';
          break;
        case 'png':
          encoded = Uint8List.fromList(img.encodePng(finalImage, level: (100 - quality) ~/ 10));
          ext = 'png';
          break;
        case 'webp':
          // TODO: Integrate native WebP encoding using a proper FFI library or package
          encoded = Uint8List.fromList(img.encodeJpg(finalImage, quality: quality)); // simulation
          ext = 'webp';
          break;
        default:
          encoded = Uint8List.fromList(img.encodeJpg(finalImage, quality: quality));
          ext = 'jpg';
          break;
      }

      final filePath = p.join(outputDir.path, 'image_$i.$ext');
      await File(filePath).writeAsBytes(encoded);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Images processed and saved in selected directory!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              'Flutter Bulk Image Editor',
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2F4F8), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      if (fileNames.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          height: 150,
                          child: ListView.builder(
                            key: ValueKey(fileNames.join()),
                            itemCount: fileNames.length,
                            itemBuilder: (context, index) {
                              return StatefulBuilder(
                                builder: (context, setStateLocal) {
                                  return Dismissible(
                                    key: ValueKey(fileNames[index]),
                                    onDismissed: (_) {
                                      setState(() {
                                        images.removeAt(index);
                                        fileNames.removeAt(index);
                                      });
                                    },
                                    background: Container(color: Colors.redAccent),
                                    child: Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      child: ListTile(
                                        leading: Image.memory(images[index], width: 40, fit: BoxFit.cover),
                                        title: Text(fileNames[index]),
                                        subtitle: Text('${images[index].lengthInBytes ~/ 1024} KB'),
                                        trailing: const Icon(Icons.delete),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (kIsWeb)
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                            child: DropzoneView(
                              onCreated: (controller) => dropController = controller,
                              onDrop: (ev) async {
                                final bytes = await dropController.getFileData(ev);
                                setState(() {
                                  images.add(bytes);
                                  fileNames.add('image_${images.length}.jpg');
                                });
                              },
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                 if (images.isEmpty)
  Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.upload_file, size: 64),
        const Text("Drag & Drop images here"),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: true);
            if (result != null) {
              final validFiles = result.files.where((e) => e.bytes != null).toList();
              setState(() {
                images.addAll(validFiles.map((e) => e.bytes!).toList());
                fileNames.addAll(validFiles.map((e) => e.name).toList());
              });
            }
          },
          child: const Text("Or Select Files"),
        ),
      ],
    ),
  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Format: "),
                          DropdownButton<String>(
                            value: format,
                            items: ['jpg', 'png', 'webp']
                                .map((f) => DropdownMenuItem(value: f, child: Text(f.toUpperCase())))
                                .toList(),
                            onChanged: (val) => setState(() => format = val!),
                          ),
                          const SizedBox(width: 20),
                          const Text("Quality:"),
                          Expanded(
                            child: Slider(
                              value: quality.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              label: quality.toString(),
                              onChanged: (v) => setState(() => quality = v.toInt()),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Resize (W x H): "),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              decoration: const InputDecoration(hintText: "Width"),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => setState(() => resizeWidth = int.tryParse(v)),
                            ),
                          ),
                          const Text(" x "),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              decoration: const InputDecoration(hintText: "Height"),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => setState(() => resizeHeight = int.tryParse(v)),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: images.isEmpty ? null : processImages,
                          child: const Text("Convert & Save"),
                        ),
                      ),
                      // File list view removed; now shown above Dropzone.
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
