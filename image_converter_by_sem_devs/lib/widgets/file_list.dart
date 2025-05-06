// lib/widgets/file_list.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';

class FileListView extends StatelessWidget {
  final List<Uint8List> images;
  final List<String> fileNames;
  final List<bool> selectedStates;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onToggleSelection;

  const FileListView({
    Key? key,
    required this.images,
    required this.fileNames,
    required this.selectedStates,
    required this.onRemove,
    required this.onToggleSelection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: fileNames.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: const Color.fromARGB(255, 183, 216, 243),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: selectedStates[index],
                  onChanged: (_) => onToggleSelection(index),
                ),
                Image.memory(
                  images[index],
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            title: Text(fileNames[index]),
            subtitle: Text('${images[index].lengthInBytes ~/ 1024} KB'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onRemove(index),
            ),
          ),
        );
      },
    );
  }
}
