// lib/widgets/conversion_options_panel.dart
import 'package:flutter/material.dart';

class ConversionOptionsPanel extends StatelessWidget {
  final String format;
  final int quality;
  final bool isDisabled;
  final ValueChanged<String> onFormatChanged;
  final ValueChanged<int> onQualityChanged;
  final List<bool> selectedStates;
  final VoidCallback? onConvertSelected;
  final VoidCallback? onConvertAll;

  const ConversionOptionsPanel({
    Key? key,
    required this.format,
    required this.quality,
    required this.isDisabled,
    required this.onFormatChanged,
    required this.onQualityChanged,
    required this.selectedStates,
    required this.onConvertSelected,
    required this.onConvertAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  items: ['jpg', 'png', 'webp', 'avif']
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: isDisabled ? null : (val) => onFormatChanged(val!),
                ),
                const SizedBox(width: 20),
                const Text("Quality:"),
                Expanded(
                  child: Slider(
                    value: quality.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: Colors.blue,
                    label: quality.toString(),
                    onChanged: isDisabled ? null : (v) => onQualityChanged(v.toInt()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isDisabled ? null : onConvertAll,
                    child: const Text("Convert All"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isDisabled || !selectedStates.contains(true) ? null : onConvertSelected,
                    child: const Text("Convert Selected"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}