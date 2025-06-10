import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'main.dart';
import 'TeamDetailsPage.dart';
import 'playerdetails.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({Key? key}) : super(key: key);

  @override
  _RankingsPageState createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  bool showDriverRankings = true;
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  //Map<String, dynamic>? adConfig;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  /*Future<void> _fetchAdConfiguration() async {
    try {
      final response = await http.get(
          Uri.parse("https://securepayments.live/brd/adds.json")
      );

      if (response.statusCode == 200) {
        setState(() {
          adConfig = json.decode(response.body);
        });

        // Initialize ads after configuration is fetched
        MobileAds.instance.initialize();
        _loadAds();
      } else {
        print('Failed to load ad configuration');
      }
    } catch (e) {
      print('Error fetching ad configuration: $e');
    }
  }*/

  void _loadAds() {
    if (branking) {
      _loadBannerAd();
    }

    if (iranking) {
      _loadInterstitialAd();
    }
  }

  void _loadBannerAd() {
    final bannerAdUnit = banneradunit;
    bannerAd = BannerAd(
      adUnitId: bannerAdUnit,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load ');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    final interstitialAdUnit = interstitialadunit;
    InterstitialAd.load(
      adUnitId: interstitialAdUnit,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load ');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null; // Reset after showing
      _loadInterstitialAd(); // Load a new ad
    } else {
      print('Interstitial ad is still loading.');
    }
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rankings"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Column(
        children: [
          // Capsule Button for Rankings (unchanged)
          Container(
            height: 50,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showDriverRankings = true;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: showDriverRankings ? Colors.red : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Driver Rankings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showDriverRankings = false;
                      });
                      // Optionally show interstitial ad when switching to team rankings
                      _showInterstitialAd();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: !showDriverRankings ? Colors.red : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(25)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Team Rankings',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: showDriverRankings
                ? DriverRankingsWidget()
                : TeamRankingsWidget(),
          ),
          // Conditionally show banner ad based on configuration
          if ( brankingdetails && bannerAd != null)
            Container(
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            ),
        ],
      ),
    );
  }
}

class DriverRankingsWidget extends StatelessWidget {
  Future<List<dynamic>> fetchDriverRankings() async {
    const String url = "https://securepayments.live/brd/rankings_drivers.json"; // Updated URL
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception("Failed to load driver rankings");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchDriverRankings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error!"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No driver rankings available"));
        }

        final driverRankings = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: driverRankings.length,
          itemBuilder: (context, index) {
            final ranking = driverRankings[index];
            return RankingCard(
              position: ranking['position'],
              name: ranking['driver']['name'],
              teamName: ranking['team']['name'],
              points: ranking['points'] ?? 0,
              imageUrl: ranking['driver']['image'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DriverDetailView(item: ranking),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class TeamRankingsWidget extends StatelessWidget {
  Future<List<dynamic>> fetchTeamRankings() async {
    const String url = "https://securepayments.live/brd/rankings_teams.json"; // Updated URL
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception("Failed to load team rankings");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchTeamRankings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error! loading rankings"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No team rankings available"));
        }

        final teamRankings = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: teamRankings.length,
          itemBuilder: (context, index) {
            final ranking = teamRankings[index];
            return RankingCard(
              position: ranking['position'],
              name: ranking['team']['name'],
              points: ranking['points'] ?? 0,
              imageUrl: ranking['team']['logo'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamDetailView(item: ranking),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class RankingCard extends StatelessWidget {
  final int position;
  final String name;
  final String? teamName;
  final int points;
  final String imageUrl;
  final VoidCallback onTap;

  const RankingCard({
    required this.position,
    required this.name,
    this.teamName,
    required this.points,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red, width: 2),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 25,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        subtitle: teamName != null
            ? Text(
          "$teamName • $points points",
          style: const TextStyle(color: Colors.grey),
        )
            : Text(
          "$points points",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          "#$position",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


class DriverDetailView extends StatelessWidget {
  final Map<String, dynamic> item;

  const DriverDetailView({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final driver = item['driver'];
    final name = driver['name'] ?? 'Unknown';
    final points = item['points'] ?? 0;
    final position = item['position'] ?? 'N/A';
    final season = item['season'];
    final wins = item['wins']?? 0;
    final imageUrl = driver['image'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Details"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              radius: 60,
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Position: #$position",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Points: $points",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            // Hardcoded season and wins for this example
            Text(
              "Season: $season",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Wins: $wins",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Check if the driver ID is 94
                if (driver['id'] == 94 || driver['id'] == 101 || driver['id'] == 89) {
                  // Show a dialog if ID is 94
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("No Detail Available"),
                        content: Text("Details for this driver are not available."),
                        actions: <Widget>[
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Proceed with navigation if ID is not 94
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExtraDriverDetailsPage(driverId: driver['id'].toString()),
                    ),
                  );
                }
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                "Know More About Driver",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TeamDetailView extends StatelessWidget {
  final Map<String, dynamic> item;

  const TeamDetailView({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final team = item['team'];
    final name = team['name'] ?? 'Unknown';
    final points = item['points'] ?? 0;
    final position = item['position'] ?? 'N/A';
    final logoUrl = team['logo'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Details"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(logoUrl),
              radius: 60,
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Position: #$position",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Points: $points",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),
            // Hardcoded season for this example
            const Text(
              "Season: 2024",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to extra team details page
                // Passing team ID as an example
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeamDetailPage(teamId: team['id']),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                "Know More About Team",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

