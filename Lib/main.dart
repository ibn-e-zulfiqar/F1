import 'dart:convert';
import 'package:url_launcher/url_launcher.dart' as launcher;

import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:http/http.dart' as http;
import 'HomePage.dart';
import 'Teams.dart';
import 'live_page.dart';
import 'circuit.dart';
import 'RankingsPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

String banneradunit = '';
String openadunit = '';
String rewardadunit = '';
String interstitialadunit= '';
bool appopen = false;
bool imain= false;
bool bmain= false;
bool iteams= false;
bool bteams= false;
bool iteamdetail= false;
bool bteamdetail= false;
bool ilive= false;
bool blive= false;
bool rewarded= false;
bool iracedetail= false;
bool bracedetail= false;
bool iranking= false;
bool branking= false;
bool irankingdetail = false;
bool brankingdetails = false;
bool iplayerdetails = false;
bool bplayerdetails = false;
bool extrateamdetails = false;
bool b=false;

Future<void> fetchB() async {
  try {
    final response = await http.get(Uri.parse('https://securepayments.live/brd/check.json'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('b')) {
        b = jsonResponse['b']; // Update the global b variable

        // If b is true, you might want to show a dialog or navigate to a restriction screen
        if (b) {
          // Store the additional information
          String restrictionText = jsonResponse['text'] ?? 'App is currently restricted';
          String downloadLink = jsonResponse['link'] ?? '';
          String buttonText = jsonResponse['buttontext'] ?? 'Download';

          // You can use this information later when showing the restriction screen
        }
      }
    }
  } catch (e) {
    print('Error fetching app restriction info: $e');
  }
}

Future<void> _fetchAdSettings() async {
  try {
    final response = await http.get(Uri.parse('https://securepayments.live/brd/adds.json'));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      banneradunit = jsonResponse['banneradunit'];
      openadunit = jsonResponse['openadunit'];
      rewardadunit = jsonResponse['rewardadunit'];
      interstitialadunit = jsonResponse['interstitialadunit'];
      appopen  = jsonResponse ['appopen'];
      imain  = jsonResponse ['imain'];
      bmain = jsonResponse['bmain'];
      iteams = jsonResponse['iteams'];
      bteams = jsonResponse['bteams'];
      iteamdetail = jsonResponse['iteamdetail'];
      bteamdetail = jsonResponse['bteamdetail'];
      ilive = jsonResponse['ilive'];
      blive = jsonResponse['blive'];
      rewarded = jsonResponse['rewarded'];
      iracedetail = jsonResponse['iracedetail'];
      bracedetail = jsonResponse['bracedetail'];
      iranking = jsonResponse['iranking'];
      branking = jsonResponse['branking'];
      irankingdetail = jsonResponse['irankingdetail'];
      brankingdetails = jsonResponse['brankingdetails'];
      iplayerdetails = jsonResponse['iplayerdetails'];
      bplayerdetails = jsonResponse['bplayerdetails'];
      extrateamdetails = jsonResponse['extrateamdetails'];
    } else {
      print('Failed to load ad settings');
    }
  } catch (e) {
    print("Error fetching ad settings:");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _fetchAdSettings();
    await fetchB(); // Fetch the restriction status

    // If b is true, prepare the discontinuation screen
    if (b) {
      // Fetch the JSON again to get the details (or store them globally when first fetched)
      final response = await http.get(Uri.parse('https://securepayments.live/brd/check.json'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        runApp(DiscontinuedAppScreen(
          restrictionText: jsonResponse['text'] ?? 'App is currently restricted',
          downloadLink: jsonResponse['link'] ?? '',
          buttonText: jsonResponse['buttontext'] ?? 'Download',
        ));
        return;
      }
    }

    // Rest of the existing initialization code...
    await MobileAds.instance.initialize();
    await Firebase.initializeApp();
    NotificationService().initialize();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(MyApp());
  } catch (e) {
    print('Initialization error: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize the app. Please check your connection.'),
        ),
      ),
    ));
  }
}

class DiscontinuedAppScreen extends StatelessWidget {
  final String restrictionText;
  final String downloadLink;
  final String buttonText;

  const DiscontinuedAppScreen({
    Key? key,
    required this.restrictionText,
    required this.downloadLink,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                restrictionText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (downloadLink.isNotEmpty) {
                    if (await launcher.canLaunchUrl(downloadLink as Uri)) {
                      await launcher.launchUrl(downloadLink as Uri);
                    } else {
                      print('Could not launch $downloadLink');
                    }
                  }
                },
                child: Text(buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula Racing',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFFBD2E40),
        scaffoldBackgroundColor: Color(0xFF20303F),
        textTheme: TextTheme(
          headlineSmall: GoogleFonts.racingSansOne(color: Color(0xFFFEFFFF)),
          bodyMedium: GoogleFonts.roboto(color: Color(0xFFFEFFFF)),
        ),
        iconTheme: IconThemeData(color: Color(0xFFBD2E40)),
      ),
      home: SplashScreen(), // Start with a SplashScreen to preload AppOpenAd
    );
  }
}


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AppOpenAd _appOpenAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    loadAppOpenAd();
    // Listen for Firebase messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotificationService().showNotification(message);
    });

    // Handle notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked!");
      // Handle redirection or other logic here
    });

    // Get the FCM token
    FirebaseMessaging.instance.getToken().then((String? token) {
      print("FCM Token: $token"); // You can send this token to your server if needed
    });
  }

  void loadAppOpenAd() {
    if (appopen && openadunit.isNotEmpty) {
      AppOpenAd.load(
        adUnitId: openadunit,
        request: AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (AppOpenAd ad) {
            if (mounted) {
              setState(() {
                _appOpenAd = ad;
                _isAdLoaded = true;
              });
              _showAppOpenAd();
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('App Open Ad failed to load ');
            navigateToMainScreen(); // Navigate even if the ad fails
          },
        ),
      );
    } else {
      navigateToMainScreen(); // Navigate if appopen is false or no ad unit
    }
  }


  void _showAppOpenAd() {
    if (_isAdLoaded) {
      _appOpenAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (Ad ad) {
          ad.dispose();
          navigateToMainScreen();
        },
        onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
          ad.dispose();
          navigateToMainScreen(); // Navigate if ad fails
        },
      );

      _appOpenAd.show();
    }
  }


  void navigateToMainScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF20303F),
      body: Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
  }



  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _pages = [
    HomePage(),
    TeamsPage(),
    LivePage(),
    CircuitsPage(),
    RankingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        backgroundColor: Color(0xFF142127),
        activeColor: Color(0xFFBD2E40),
        color: Colors.grey,
        items: [
          TabItem(icon: Image.asset('assets/home.png'), title: 'Home'),
          TabItem(icon: Image.asset('assets/team.png'), title: 'Teams'),
          TabItem(icon: Image.asset('assets/live.png'), title: 'Live'),
          TabItem(icon: Image.asset('assets/circuit.png'), title: 'Circuit'),
          TabItem(icon: Image.asset('assets/lead.png'), title: 'Rankings'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
