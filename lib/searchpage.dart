import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'song.dart';

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
      mainAxisSize: MainAxisSize.min,
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
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                var results = snapshot.data!;
                if (results.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Search for songs to save the lyrics.'),
                  );
                }
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
                          onPressed: () async {
                            File f = await _localFile(song.id!);
                            String json = jsonEncode(song);
                            f.writeAsString(json);
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
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              } else {
                return Center(child: Text('Search for lyrics'));
              }
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
    final response =
        await http.get(Uri.parse('https://lrclib.net/api/search?q="${text}"'));
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

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return '${directory.path + Platform.pathSeparator}lyrics';
}

Future<File> _localFile(int id) async {
  final path = await _localPath;
  var dir = Directory(path);

  try {
    var dirList = dir.list();
    await for (final FileSystemEntity f in dirList) {
      if (f is File &&
          f.path.endsWith('${Platform.pathSeparator + id.toString()}.txt')) {
        return f;
      }
    }
  } catch (e) {
    print(e.toString());
  }
  return File('$path/$id.txt');
}
