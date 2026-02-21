import 'package:flutter/material.dart';

/// Market History, Market Shape 등 아직 리스트 미구현 주제용 플레이스홀더
class MarketPlaceholderScreen extends StatelessWidget {
  const MarketPlaceholderScreen({super.key, required this.title});

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
        child: Text('$title - 준비 중', style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
