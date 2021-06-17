import 'package:flutter/material.dart';
import 'package:getstream_af/screens/profile_screen.dart';
import 'package:stream_feed/stream_feed.dart';

class BottomBarScreen extends StatefulWidget {
  final User streamUser;
  const BottomBarScreen({Key? key, required this.streamUser}) : super(key: key);

  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ProfileScreen(streamUser: widget.streamUser),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        elevation: 16.0,
        type: BottomNavigationBarType.fixed,
        iconSize: 22,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.black,
            icon: Icon(Icons.supervised_user_circle_sharp),
            label: 'People',
          ),
        ],
      ),
    );
  }
}
