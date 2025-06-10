import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';
import 'main.dart';

class ExtraDriverDetailsPage extends StatefulWidget {
  final String driverId;

  const ExtraDriverDetailsPage({Key? key, required this.driverId}) : super(key: key);

  @override
  _ExtraDriverDetailsPageState createState() => _ExtraDriverDetailsPageState();
}

class _ExtraDriverDetailsPageState extends State<ExtraDriverDetailsPage> {
  Map<String, dynamic>? driverDetails;

  bool isLoading = true;
  String? errorMessage;

  // Ad-related variables
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _fetchDriverDetailsAndAds();
  }

  Future<void> _fetchDriverDetailsAndAds() async {
    try {
      // Fetch driver details
      final driverUrl = "https://securepayments.live/brd/driver${widget.driverId}.json";
      final driverResponse = await http.get(Uri.parse(driverUrl));

      if (driverResponse.statusCode == 200) {
        final driverData = json.decode(driverResponse.body);

        setState(() {
          driverDetails = driverData['response'][0];
          isLoading = false;
        });

        // Initialize ads based on permissions
        _initializeAds();
      } else {
        setState(() {
          errorMessage = "Failed to load driver details";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error ";
        isLoading = false;
      });
    }
  }

  void _initializeAds() {
    // Check permissions for player details page
    if (bplayerdetails) {
      _loadBannerAd();
    }

    if (iplayerdetails) {
      _loadInterstitialAd();
    }
  }

  void _loadBannerAd() {
    final bannerAdUnitId = banneradunit;
    if (bannerAdUnitId == '') return;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Banner ad failed to load ');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    final interstitialAdUnitId = interstitialadunit;
    if (interstitialAdUnitId == '') return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null; // Reload a new ad after dismissal
            },
          );

          // Show the ad immediately after loading
          _showInterstitialAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load ');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd?.show();
      _interstitialAd = null;
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  // Method to handle long names
  String _formatName(String name) {
    if (name.length > 25) {
      // Split the name and take first and last parts
      List<String> nameParts = name.split(' ');
      if (nameParts.length > 2) {
        return '${nameParts.first} ${nameParts.last}';
      }
    }
    return name;
  }

  // Updated info card to handle potential overflow
  Widget _buildInfoCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Details"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF20303F),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDriverDetailsAndAds,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text("Retry"),
            )
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Driver Image and Basic Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                          driverDetails!['image'],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatName(driverDetails!['name']),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${driverDetails!['nationality']} Driver",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Detailed Information Cards
                  _buildInfoCard(
                    "Birthdate",
                    driverDetails!['birthdate'],
                  ),
                  _buildInfoCard(
                    "Birthplace",
                    driverDetails!['birthplace'],
                  ),
                  _buildInfoCard(
                    "World Championships",
                    driverDetails!['world_championships'].toString(),
                  ),
                  _buildInfoCard(
                    "Career Points",
                    driverDetails!['career_points'],
                  ),
                  _buildInfoCard(
                    "Grands Prix Entered",
                    driverDetails!['grands_prix_entered'].toString(),
                  ),
                  _buildInfoCard(
                    "Podiums",
                    driverDetails!['podiums'].toString(),
                  ),

                  // Team History Section
                  const SizedBox(height: 20),
                  const Text(
                    "Team History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...driverDetails!['teams'].map<Widget>((teamHistory) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            teamHistory['team']['logo'],
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teamHistory['team']['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Season ${teamHistory['season']}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),

                  // Ad Banner
                  if (_isBannerAdReady && _bannerAd != null)
                    Container(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 16),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}