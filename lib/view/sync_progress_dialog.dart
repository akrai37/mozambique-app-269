import 'package:flutter/material.dart';

class SyncProgressDialog extends StatefulWidget {
  final double progress; // Progress value from 0.0 to 1.0

  const SyncProgressDialog({
    super.key,
    required this.progress,
  });

  @override
  State<SyncProgressDialog> createState() => _SyncProgressDialogState();
}

class _SyncProgressDialogState extends State<SyncProgressDialog> {
  double _oldProgress = 0.0; // Store the old progress value

  @override
  void didUpdateWidget(SyncProgressDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != _oldProgress) {
      setState(() {
        _oldProgress = widget.progress; // Update the old progress value
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {    
    return AlertDialog(
      title: const Text('Atualizando...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>( // Animate the progress bar
            tween: Tween<double>(begin: _oldProgress, end: widget.progress), // Use the old progress value as the start
            duration: const Duration(milliseconds: 500), // Animation duration
            builder: (context, value, _) {
              final String percent = (value * 100).toStringAsFixed(0); // Convert progress to percentage

              return Column(
                children: [
                  LinearProgressIndicator( // Show progress bar
                    value: value,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D3E50)),
                  ),
                  const SizedBox(height: 20),
                  // Text("Baixando dados do servidor..."),
                  Text(
                    "Baixando dados do servidor... $percent%",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D3E50),
                    ),
                  ),
                ],
              );
            }
          ),
        ],
      ),
    );
  }
}