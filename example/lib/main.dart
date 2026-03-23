import 'package:flutter/material.dart';
import 'package:the_logger_viewer_widget/the_logger_viewer_widget.dart';

void main() {
  runApp(const ExampleApp());
}

/// Example app demonstrating the_logger_viewer_widget.
///
/// In a real app, call `await TheLogger.i().init()` before using the viewer.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Log Viewer Example',
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Viewer Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Open as a full-screen page
            ElevatedButton(
              onPressed: () => TheLoggerViewerWidget.show(context),
              child: const Text('Open Log Viewer'),
            ),
            const SizedBox(height: 16),
            // Open with custom options
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TheLoggerViewerPage(
                    maxRecords: 1000,
                    colorScheme: {
                      'SEVERE': Colors.redAccent,
                      'INFO': Colors.teal,
                    },
                  ),
                ),
              ),
              child: const Text('Open with Custom Colors'),
            ),
          ],
        ),
      ),
    );
  }
}
