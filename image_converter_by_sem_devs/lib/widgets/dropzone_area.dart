// lib/widgets/dropzone_area.dart
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:typed_data';

class EmptyDropArea extends StatefulWidget {
  final VoidCallback onPickFiles;
  final void Function(List<({Uint8List bytes, String name})>) onFileDropped;

  const EmptyDropArea({
    Key? key,
    required this.onPickFiles,
    required this.onFileDropped,
  }) : super(key: key);

  @override
  State<EmptyDropArea> createState() => _EmptyDropAreaState();
}

class _EmptyDropAreaState extends State<EmptyDropArea> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) async {
        final droppedFiles = <({Uint8List bytes, String name})>[];
        for (final file in details.files) {
          if (file.path.endsWith('.png') ||
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.jpeg') ||
              file.path.endsWith('.webp') ||
              file.path.endsWith('.avif')) {
            final bytes = await file.readAsBytes();
            droppedFiles.add((bytes: bytes, name: file.name));
          }
        }
        if (droppedFiles.isNotEmpty) {
          widget.onFileDropped(droppedFiles);
        }
      },
      onDragEntered: (_) {
        setState(() => _dragging = true);
      },
      onDragExited: (_) {
        setState(() => _dragging = false);
      },
      child: Container(
        color: _dragging ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, size: 64),
              const Text("Drag & Drop images here"),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: widget.onPickFiles,
                child: const Text("Or Select Files"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
