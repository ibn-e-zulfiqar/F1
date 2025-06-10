import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'RaceDetailsPage.dart';
import 'main.dart';
import 'package:intl/intl.dart';

extension Sorted<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) {
    return List<T>.from(this)..sort(compare);
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> races = [];
  bool showScheduled = true;
  late Timer _timer;
   // To store the islive value
  InterstitialAd? _interstitialAd;
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;


  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    loadBannerAd();
    fetchRaces();
    _startAutoReload();
  }

  void _loadInterstitialAd() {
    if (imain) {
      InterstitialAd.load(
        adUnitId: interstitialadunit,
        // Replace with your Ad Unit ID
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _showInterstitialAd(); // Show the ad immediately when loaded
          },
          onAdFailedToLoad: (error) {
            print('Failed to load interstitial ad:');
          },
        ),
      );
    }
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  Future<void> fetchRaces() async {
    try {
      final response = await http.get(
        Uri.parse('https://securepayments.live/brd/match.json'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          // Sort races
          races = (jsonResponse['response'] as List).sorted((a, b) {
            final dateA = DateTime.parse(a['date']);
            final dateB = DateTime.parse(b['date']);
            final nowDate = DateTime.now();

            // First, separate scheduled and completed races
            final isScheduledA = a['status'] == 'Scheduled';
            final isScheduledB = b['status'] == 'Scheduled';

            if (!isScheduledA && !isScheduledB) {
              // If both are completed, sort by most recent first
              return dateB.compareTo(dateA);
            } else if (!isScheduledA) {
              // Completed races come before scheduled
              return -1;
            } else if (!isScheduledB) {
              // Completed races come before scheduled
              return 1;
            } else {
              // For scheduled races, sort by upcoming first
              return dateA.compareTo(dateB);
            }
          });
        });
      } else {
        print('Failed to load races');
      }
    } catch (e) {
      print('Error fetching races: $e');
    }
  }

  void _startAutoReload() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchRaces();
    });
  }

  void loadBannerAd() {
    if (bmain) {
      _bannerAd = BannerAd(
        adUnitId: banneradunit, // Using the second function's ad unit source
        size: AdSize.banner,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            print('Ad failed to load: ');
            ad.dispose();
          },
        ),
      )..load();
    }
  }


  @override
  void dispose() {
    _timer.cancel();
    _interstitialAd?.dispose(); // Dispose of the interstitial ad
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formula Racing '),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Capsule Button
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showScheduled = true;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: showScheduled ? Colors.red : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(25)),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.event, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Schedule',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showScheduled = false;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: !showScheduled ? Colors.red : Colors.transparent,
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(25)),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.emoji_events, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Results',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // List View
                  Expanded(
                    child: ListView.builder(
                      itemCount: races.isEmpty ? 1 : races.length,
                      itemBuilder: (context, index) {
                        // If the list is empty
                        if (races.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                showScheduled ? 'No races scheduled ' : 'No results yet',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          );
                        }

                        final race = races[index];
                        final isScheduled = race['status'] == 'Scheduled';

                        if ((showScheduled && isScheduled) || (!showScheduled && !isScheduled)) {
                          return RaceCard(
                            race: race,
                            highlight: index == 0,
                            isResult: !showScheduled,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isAdLoaded)
            Container(
              alignment: Alignment.center,
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }
}

class RaceCard extends StatelessWidget {
  final Map<String, dynamic> race;
  final bool highlight;
  final bool isResult;

  const RaceCard({
    required this.race,
    this.highlight = false,
    this.isResult = false,
  });

  String _calculateTimeRemaining(DateTime raceDate) {
    final now = DateTime.now();

    if (raceDate.isBefore(now)) return '';

    final difference = raceDate.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    return '$days days, $hours hrs, $minutes mins';
  }

  @override
  Widget build(BuildContext context) {
    final raceDate = DateTime.parse(race['date']);
    final timeRemaining = _calculateTimeRemaining(raceDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: highlight ? Colors.yellow[700] : Colors.grey[800],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(
              isResult ? Icons.emoji_events : Icons.calendar_today,
              color: highlight ? Colors.black : Colors.redAccent,
            ),
            title: Text(
              '${race['competition']['name']} - ${race['type']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: highlight ? Colors.black : Colors.white,
              ),
            ),
            subtitle: Text(
              'Location: ${race['competition']['location']['city']}, ${race['competition']['location']['country']}',
              style: TextStyle(color: highlight ? Colors.black87 : Colors.grey[300]),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: highlight ? Colors.black54 : Colors.white70),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RaceDetailsPage(race: race),
                ),
              );
            },
          ),

          // Conditionally show time remaining for scheduled races
          if (!isResult && timeRemaining.isNotEmpty) ...[
            const Divider(
              height: 1,
              color: Colors.grey,
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Starts in: $timeRemaining',
                    style: TextStyle(
                      fontSize: 14,
                      color: highlight ? Colors.black87 : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}