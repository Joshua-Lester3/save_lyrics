import 'package:flutter/material.dart';
import 'song.dart';

class LyricsScreen extends StatelessWidget {
  // In the constructor, require a Todo.
  const LyricsScreen({super.key, required this.song});

  // Declare a field that holds the Todo.
  final Song song;

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(song.trackName!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Expanded(
            flex: 1,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical, child: Text(song.plainLyrics!))),
      ),
    );
  }
}
