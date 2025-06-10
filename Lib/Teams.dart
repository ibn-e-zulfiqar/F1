import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'main.dart';

import 'TeamDetailsPage.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;

  String? bannerAdUnit=banneradunit;
  String? interstitialAdUnit=interstitialadunit;


  @override
  void initState() {
    super.initState();
    if (bteams) loadBannerAd();
    if (iteams) loadInterstitialAd();
  }

  void loadInterstitialAd() {
    if (interstitialAdUnit == null) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnit!,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          displayInterstitialAd();
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void loadBannerAd() {
    if (bannerAdUnit == null) return;

    bannerAd = BannerAd(
      adUnitId: bannerAdUnit!,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded.');
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Failed to load banner ad: $error');
        },
      ),
    )..load();
  }

  void displayInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null;
      loadInterstitialAd();
    } else {
      print('Interstitial ad is still loading.');
    }
  }

  Future<List<dynamic>> fetchTeams() async {
    const String url = "https://securepayments.live/brd/teams.json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['response'];
    } else {
      throw Exception("Failed to load teams data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teams"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: fetchTeams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Error ",
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No teams data available",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final teams = snapshot.data!;
                return ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return TeamCard(
                      team: team,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TeamDetailPage(teamId: team['id']),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (bteams && bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: bannerAd!.size.width.toDouble(),
              height: bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: bannerAd!),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    interstitialAd?.dispose();
    bannerAd?.dispose();
    interstitialAd = null;
    bannerAd = null;
    super.dispose();
  }
}


class TeamCard extends StatelessWidget {
  final Map<String, dynamic> team;
  final VoidCallback onTap;

  const TeamCard({required this.team, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.redAccent, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Team Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  team['logo'] ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey,
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Team Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team['name'],
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (team['base'] != null)
                      Text(
                        "Base: ${team['base']}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    if (team['world_championships'] != null)
                      Text(
                        "Titles: ${team['world_championships']}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    if (team['chassis'] != null)
                      Text(
                        "Chassis: ${team['chassis']}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
