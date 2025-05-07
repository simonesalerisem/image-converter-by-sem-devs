import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_converter_by_sem_devs/services/image_processor.dart';
import 'package:image_converter_by_sem_devs/widgets/conversion_options_panel.dart';
import 'package:image_converter_by_sem_devs/widgets/file_list.dart';
import 'package:image_converter_by_sem_devs/widgets/dropzone_area.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ImageEditorPage(),
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
  List<bool> selectedStates = [];
  String format = 'jpg';
  int quality = 80;
  bool isLoading = false;
  double progress = 0.0;
  String filenamePattern = "{original}_{date}_imageconverter.{ext}";
  late TextEditingController patternController;

  @override
  void initState() {
    super.initState();
    patternController = TextEditingController(text: filenamePattern);
  }

  @override
  void dispose() {
    patternController.dispose();
    super.dispose();
  }

  Future<void> processImages() async {
    setState(() => isLoading = true);

    await ImageProcessor.process(
      images: images,
      fileNames: fileNames,
      format: format,
      quality: quality,
      filenamePattern: filenamePattern,
      onProgress: (double value) {
        setState(() {
          progress = value;
        });
      },
      onComplete: () {
        setState(() {
          isLoading = false;
          progress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Images processed and saved!")),
        );
      },
    );
  }

  void toggleSelection(int index) {
    setState(() {
      selectedStates[index] = !selectedStates[index];
    });
  }

  void selectAll(bool value) {
    setState(() {
      selectedStates = List.filled(images.length, value);
    });
  }

  Future<void> processAllImages() async {
    setState(() => isLoading = true);
    await ImageProcessor.process(
      images: images,
      fileNames: fileNames,
      format: format,
      quality: quality,
      filenamePattern: filenamePattern,
      onProgress: (double value) {
        setState(() {
          progress = value;
        });
      },
      onComplete: () {
        setState(() {
          isLoading = false;
          progress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Images processed and saved!")),
        );
      },
    );
  }

  Future<void> processSelectedImages() async {
    final selectedImages = <Uint8List>[];
    final selectedNames = <String>[];
    for (int i = 0; i < selectedStates.length; i++) {
      if (selectedStates[i]) {
        selectedImages.add(images[i]);
        selectedNames.add(fileNames[i]);
      }
    }
    if (selectedImages.isEmpty) return;
    setState(() => isLoading = true);
    await ImageProcessor.process(
      images: selectedImages,
      fileNames: selectedNames,
      format: format,
      quality: quality,
      filenamePattern: filenamePattern,
      onProgress: (double value) {
        setState(() {
          progress = value;
        });
      },
      onComplete: () {
        setState(() {
          isLoading = false;
          progress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Selected images processed and saved!")),
        );
      },
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
            Image.asset('assets/logo.png', height: 48),
            const SizedBox(width: 8),
            const Text(
              'ImageFlow - The Image Converter',
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child:
                    fileNames.isNotEmpty
                        ? FileListView(
                          images: images,
                          fileNames: fileNames,
                          selectedStates: selectedStates,
                          onRemove:
                              (index) => setState(() {
                                images.removeAt(index);
                                fileNames.removeAt(index);
                                selectedStates.removeAt(index);
                              }),
                          onToggleSelection: toggleSelection,
                        )
                        : EmptyDropArea(
                          onPickFiles: () async {
                            final result = await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              withData: true,
                            );
                            if (result != null) {
                              final validFiles =
                                  result.files.where((e) => e.bytes != null).toList();
                              setState(() {
                                images.addAll(validFiles.map((e) => e.bytes!).toList());
                                fileNames.addAll(validFiles.map((e) => e.name).toList());
                                selectedStates.addAll(List.generate(validFiles.length, (_) => false));
                              });
                            }
                          },
                          onFileDropped: (droppedFiles) => setState(() {
                            for (final file in droppedFiles) {
                              images.add(file.bytes);
                              fileNames.add(file.name);
                              selectedStates.add(false);
                            }
                          }),
                        ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: patternController,
                decoration: const InputDecoration(
                  labelText: "Output filename pattern",
                  hintText: "{original}_{date}_imageconverter.{ext}",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => filenamePattern = value),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConversionOptionsPanel(
                format: format,
                quality: quality,
                isDisabled: images.isEmpty,
                onFormatChanged: (val) => setState(() => format = val),
                onQualityChanged: (val) => setState(() => quality = val),
                selectedStates: selectedStates,
                onConvertAll: images.isEmpty ? null : processAllImages,
                onConvertSelected: selectedStates.contains(true) ? processSelectedImages : null,
              ),
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  children: [
                    const TextSpan(text: "Provided to you by "),
                    TextSpan(
                      text: "SEM Devs",
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () async {
                              final url = Uri.parse('https://www.sem-devs.com');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                    ),
                    const TextSpan(
                      text: ". Copyright ©2025. All rights reserved. Version 1.1",
                    ),
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
