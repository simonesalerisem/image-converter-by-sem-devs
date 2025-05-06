// lib/services/image_processor.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class ImageProcessor {
  static Future<void> process({
    required List<Uint8List> images,
    required String format,
    required int quality,
    int? resizeWidth,
    int? resizeHeight,
    required List<String> fileNames,
    required String filenamePattern,
    void Function()? onComplete,
    void Function(double progress)? onProgress,
  }) async {
    final directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return; // User cancelled

    final outputDir = Directory(directoryPath);

    for (var i = 0; i < images.length; i++) {
      final decoded = img.decodeImage(images[i]);
      if (decoded == null) continue;

      img.Image finalImage = decoded;
      if (resizeWidth != null && resizeHeight != null) {
        finalImage = img.copyResize(
          decoded,
          width: resizeWidth,
          height: resizeHeight,
        );
      }

      Uint8List encoded;
      String ext;
      switch (format) {
        case 'jpg':
          encoded = Uint8List.fromList(
            img.encodeJpg(finalImage, quality: quality),
          );
          ext = 'jpg';
          break;
        case 'png':
          encoded = Uint8List.fromList(
            img.encodePng(finalImage, level: (100 - quality) ~/ 10),
          );
          ext = 'png';
          break;
        case 'webp':
          encoded = Uint8List.fromList(
            img.encodeJpg(finalImage, quality: quality),
          ); // simulated WebP
          ext = 'webp';
          break;
        case 'avif':
          encoded = Uint8List.fromList(
            img.encodeJpg(finalImage, quality: quality),
          ); // simulated AVIF
          ext = 'avif';
          break;
        default:
          encoded = Uint8List.fromList(
            img.encodeJpg(finalImage, quality: quality),
          );
          ext = 'jpg';
          break;
      }

      final originalName = p.basenameWithoutExtension(fileNames[i]);
      final date = DateTime.now().toIso8601String().split('T').first;
      final fileName = filenamePattern
          .replaceAll("{original}", originalName)
          .replaceAll("{date}", date)
          .replaceAll("{ext}", ext);
      final filePath = p.join(outputDir.path, fileName);
      await File(filePath).writeAsBytes(encoded);

      if (onProgress != null) {
        onProgress(i / images.length);
      }
    }

    if (onComplete != null) onComplete();
  }
}