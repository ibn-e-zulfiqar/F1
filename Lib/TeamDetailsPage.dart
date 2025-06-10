import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'main.dart';

class TeamDetailPage extends StatefulWidget {
  final int teamId; // Team ID passed from the list

  const TeamDetailPage({Key? key, required this.teamId}) : super(key: key);

  @override
  _TeamDetailPageState createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;

  String? bannerAdUnit = banneradunit;
  String? interstitialAdUnit = interstitialadunit;

  bool showBannerAd = bteamdetail;
  bool showInterstitialAd = iteamdetail;

  @override
  void initState() {
    super.initState();
    loadInterstitialAd(); // Prepare interstitial ad
    if (showBannerAd) loadBannerAd();
  }

  void loadBannerAd() {
    if (bannerAdUnit == null) return;

    bannerAd = BannerAd(
      adUnitId: bannerAdUnit!,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => print('Banner ad loaded.'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Failed to load banner ad: $error');
        },
      ),
    )..load();
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
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void displayInterstitialAd() {
    if (showInterstitialAd && interstitialAd != null) {
      interstitialAd!.show();
      interstitialAd = null; // Reset the ad
    }
  }

  Future<Map<String, dynamic>> fetchTeamDetail() async {
    final String url = "https://securepayments.live/brd/team${widget.teamId}.json";

    // Perform the HTTP GET request
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['response'][0]; // Return the first (and only) team in response
    } else {
      throw Exception("Failed to load team details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Details"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: fetchTeamDetail(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading details",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      "No data available",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final team = snapshot.data!;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (team['logo'] != null)
                          Center(
                            child: Image.network(
                              team['logo'],
                              height: 150,
                            ),
                          ),
                        const SizedBox(height: 10),
                        _buildDetailSection("General Information", [
                          _buildDetailRow("Name", team['name']),
                          _buildDetailRow("Base", team['base']),
                          _buildDetailRow("First Entry", team['first_team_entry']),
                          _buildDetailRow(
                              "World Championships", team['world_championships']),
                        ]),
                        _buildDetailSection("Achievements", [
                          _buildDetailRow("Pole Positions", team['pole_positions']),
                          _buildDetailRow("Fastest Laps", team['fastest_laps']),
                        ]),
                        _buildDetailSection("Management", [
                          _buildDetailRow("President", team['president']),
                          _buildDetailRow("Director", team['director']),
                          _buildDetailRow(
                              "Technical Manager", team['technical_manager']),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (showBannerAd && bannerAd != null)
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

  Widget _buildDetailSection(String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label with fixed width and ellipsis
              SizedBox(
                width: constraints.maxWidth * 0.4,
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Value with flexible width and wrap
              SizedBox(
                width: constraints.maxWidth * 0.6,
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }
}