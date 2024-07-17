import 'package:flutter/material.dart';
import 'song.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'lyricsscreen.dart';

class SavedPage extends StatefulWidget {
  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  late Future<List<Song>> savedSongs;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    initStateHelper();
    savedSongs = getSavedSongs();
    controller = TextEditingController();
  }

  Future initStateHelper() async {
    Directory directory = Directory(await _localPath);
    if (!(await directory.exists())) {
      directory.create();
    }
  }

  Future<List<Song>> getSavedSongs() async {
    final path = await _localPath;
    var dir = Directory(path);
    List<Song> songs = [];

    try {
      var dirList = dir.list();
      await for (final FileSystemEntity f in dirList) {
        if (f is File && f.path.endsWith('.txt')) {
          String contents;
          try {
            contents = await f.readAsString();
          } catch (e) {
            continue;
          }
          songs.add(jsonToSong(contents));
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Song>>(
        future: savedSongs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            var results = snapshot.data!;
            if (results.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('No song lyrics saved.'),
              );
            }
            return Expanded(
              child: ListView(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 10),
                  child: Text('You have ${results.length} tracks downloaded:'),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LyricsScreen(song: song),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        iconColor: Colors.white70,
                      ),
                      child: Icon(Icons.open_in_new),
                    ),
                  ),
              ]),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else {
            return Center(child: Text('Search for lyrics'));
          }
        });
  }
}

Song jsonToSong(String contents) {
  final songMap = jsonDecode(contents) as Map<String, dynamic>;
  final song = Song.fromJson(songMap);
  return song;
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return '${directory.path + Platform.pathSeparator}lyrics';
}
