import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Placeholder();
        break;
      case 1:
        page = Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('hello'),
            Text('holle'),
            Text('hoehleo'),
          ]
        );
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: page,
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 75, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            tabBackgroundColor: Colors.grey.shade800,
            padding: EdgeInsets.all(16),
            color: Colors.white,
            activeColor: Colors.white,
            gap: 8,
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: [
              GButton(icon: Icons.folder, text: 'Saved'),
              GButton(icon: Icons.search, text: 'Search'),
            ]
          ),
        ),
      ),
    );
  }
}