import 'package:flutter/material.dart';
import 'package:flutter_app/live_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'HomePage.dart';
import 'Teams.dart';
import 'circuit.dart';
import 'RankingsPage.dart';


void main() {
  runApp(FormulaOneApp());
}

class FormulaOneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula One App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFBD2E40),
        scaffoldBackgroundColor: Color(0xFF142127),
        iconTheme: IconThemeData(color: Color(0xFFBD2E40)),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TeamsPage(),
    LivePage(),
    CircuitsPage(),
    RankingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: Colors.red[700]),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sports_motorsports_outlined),
            activeIcon: Icon(Icons.sports_motorsports, color: Colors.red[700]),
            label: 'Teams & Circuits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv_outlined),
            activeIcon: Icon(Icons.live_tv_rounded, color: Colors.red[700]),
            label: 'Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_composite_outlined),
            activeIcon: Icon(Icons.settings_input_composite, color: Colors.red[700]),
            label: 'PitStop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard, color: Colors.red[700]),
            label: 'Rankings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red[700],
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFF142127),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(child: Text("Driver and Race details go here", style: TextStyle(color: Colors.white))),
    );
  }
}

// Competitions Page
class CompetitionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Competitions')),
      body: Center(child: Text("Competition cards will be displayed here", style: TextStyle(color: Colors.white))),
    );
  }
}

// Teams and Circuits Page with Toggle Buttons
class TeamsCircuitsPage extends StatefulWidget {
  @override
  _TeamsCircuitsPageState createState() => _TeamsCircuitsPageState();
}

class _TeamsCircuitsPageState extends State<TeamsCircuitsPage> {
  bool showTeams = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teams & Circuits')),
      body: Column(
        children: [
          ToggleButtons(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey,
            selectedColor: Colors.red[700],
            fillColor: Colors.red[900],
            isSelected: [showTeams, !showTeams],
            onPressed: (index) {
              setState(() {
                showTeams = index == 0;
              });
            },
            children: [
              Padding(padding: EdgeInsets.all(8.0), child: Text('Teams', style: TextStyle(color: Colors.white))),
              Padding(padding: EdgeInsets.all(8.0), child: Text('Circuits', style: TextStyle(color: Colors.white))),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                showTeams ? "Team data will be displayed here" : "Circuit data will be displayed here",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Rankings Page with Toggle Buttons for Drivers and Teams
class RankingsPage extends StatefulWidget {
  @override
  _RankingsPageState createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  bool showDriverRankings = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rankings')),
      body: Column(
        children: [
          ToggleButtons(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey,
            selectedColor: Colors.red[700],
            fillColor: Colors.red[900],
            isSelected: [showDriverRankings, !showDriverRankings],
            onPressed: (index) {
              setState(() {
                showDriverRankings = index == 0;
              });
            },
            children: [
              Padding(padding: EdgeInsets.all(8.0), child: Text('Drivers', style: TextStyle(color: Colors.white))),
              Padding(padding: EdgeInsets.all(8.0), child: Text('Teams', style: TextStyle(color: Colors.white))),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                showDriverRankings ? "Driver rankings will be displayed here" : "Team rankings will be displayed here",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
