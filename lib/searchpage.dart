import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Song>>? futureSearchResults;
  late TextEditingController controller;
  String text = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25.0, left: 15.0, right: 15.0),
          child: TextField(
            controller: controller,
            onSubmitted: (value) {
              setState(() {
                futureSearchResults = null;
                text = value;
                futureSearchResults = fetchSearchResults();
              });
            },
            decoration: InputDecoration(
                labelText: 'Track name, artist name, or album name...'),
          ),
        ),
        FutureBuilder<List<Song>>(
            future: futureSearchResults,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                var results = snapshot.data!;
                return Expanded(
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10),
                      child: Text('There are ${results.length} results:'),
                    ),
                    for (var song in results)
                      ListTile(
                        textColor: Colors.white,
                        leading: Icon(Icons.music_note),
                        title: song.trackName != null
                            ? Text(song.trackName!)
                            : Text('Not found'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Artist: ${song.artistName ?? 'Not found'}'),
                            Text('Album: ${song.albumName ?? 'Not found'}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            print('pressed!');
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            iconColor: Colors.white70,
                          ),
                          child: Icon(Icons.save),
                        ),
                      ),
                  ]),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }

              return const CircularProgressIndicator();
            })
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    futureSearchResults = fetchSearchResults();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<List<Song>> fetchSearchResults() async {
    final response = await http.get(
        Uri.parse('https://lrclib.net/api/search?q="${text}"'));
    if (response.statusCode == 200) {
      Iterable list = jsonDecode(response.body);
      List<Song> result = [];
      for (Map<String, dynamic> model in list) {
        bool hasNull = false;
        for (var entry in model.entries) {
          if (entry.value == null) {
            hasNull = true;
          }
        }
        if (!hasNull) {
          Song song = Song.fromJson(model);
          result.add(song);
        }
      }
      return result;
    } else {
      throw Exception(
          'Failed to load song. Status code: ${response.statusCode}');
    }
  }
}

class Song {
  final int? id;
  final String? trackName;
  final String? artistName;
  final String? albumName;
  final double? duration;
  final bool? instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  const Song({
    this.id,
    this.trackName,
    this.artistName,
    this.albumName,
    this.duration,
    this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'trackName': String trackName,
        'artistName': String artistName,
        'albumName': String albumName,
        'duration': double duration,
        'instrumental': bool instrumental,
        'plainLyrics': String plainLyrics,
        'syncedLyrics': String syncedLyrics,
      } =>
        Song(
          id: id,
          trackName: trackName,
          artistName: artistName,
          albumName: albumName,
          duration: duration,
          instrumental: instrumental,
          plainLyrics: plainLyrics,
          syncedLyrics: syncedLyrics,
        ),
      _ => throw const FormatException('Failed to construct song.'),
    };
  }
}
