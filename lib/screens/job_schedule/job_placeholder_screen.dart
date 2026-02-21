import 'package:flutter/material.dart';

/// Placeholder screen for job topics not implemented yet.
class JobPlaceholderScreen extends StatelessWidget {
  const JobPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Text(
          '$title - Coming soon',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
