import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'main.dart'; // Ensure this import matches your project structure

class LivePage extends StatefulWidget {
  const LivePage({Key? key}) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> with AutomaticKeepAliveClientMixin {
  // State Variables
  bool? isLiveStreamAvailable;
  List<dynamic> streamLinks = [];
  List<dynamic> liveRaces = [];

  // Ad-related variables
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  RewardedAd? rewardedAd;

  // Enhanced error and loading states
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNetworkError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAds();
    _initializePageData();
  }

  // Comprehensive initialization method
  Future<void> _initializePageData() async {
    await _loadCachedData();
    await _fetchLiveData();
   // _loadAds();
  }

  // Load ads based on configuration
  void _loadAds() {
    if (blive == true) loadBannerAd();
    if (ilive == true) loadInterstitialAd();
    if (rewarded == true) loadRewardedAd();
  }

  // Ad loading methods with improved error handling
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialadunit,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => interstitialAd = ad,
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load ');
          interstitialAd = null;
        },
      ),
    );
  }

  void loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: banneradunit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load ');
          ad.dispose();
        },
      ),
    )..load();
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardadunit,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => rewardedAd = ad,
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load');
          rewardedAd = null;
        },
      ),
    );
  }

  // Enhanced cached data retrieval
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Retrieve cached data with null checks
      final cachedLiveStatus = prefs.getBool('cached_live_status');
      final cachedStreamLinksJson = prefs.getString('cached_stream_links');
      final cachedLiveRacesJson = prefs.getString('cached_live_races');

      setState(() {
        isLiveStreamAvailable = cachedLiveStatus;
        streamLinks = cachedStreamLinksJson != null
            ? json.decode(cachedStreamLinksJson)
            : [];
        liveRaces = cachedLiveRacesJson != null
            ? json.decode(cachedLiveRacesJson)
            : [];
      });
    } catch (e) {
      print('Error loading cached data');
    }
  }

  // Comprehensive live data fetching
  Future<void> _fetchLiveData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _isNetworkError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Fetch live stream status
      final liveStatusResponse = await _fetchWithTimeout(
        Uri.parse('https://securepayments.live/brd/is_live.json'),
        timeoutSeconds: 10,
      );

      if (liveStatusResponse.statusCode == 200) {
        final liveStatusData = json.decode(liveStatusResponse.body);
        setState(() {
          isLiveStreamAvailable = liveStatusData['isLive'] ?? false;
        });
        await prefs.setBool('cached_live_status', isLiveStreamAvailable!);

        // Fetch stream links if live
        if (isLiveStreamAvailable == true) {
          await _fetchLiveStreamLinks();
        }
      }

      // Fetch live race data
      final liveRaceResponse = await _fetchWithTimeout(
        Uri.parse('https://securepayments.live/brd/match.json'),
        timeoutSeconds: 10,
      );

      if (liveRaceResponse.statusCode == 200) {
        final liveRaceData = json.decode(liveRaceResponse.body)['response'];
        setState(() {
          liveRaces = liveRaceData.where((race) => race['status'] == 'Live').toList();
        });
        await prefs.setString('cached_live_races', json.encode(liveRaces));
      }
    } catch (e) {
      _handleFetchError(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Improved error handling
  void _handleFetchError(dynamic e) {
    print('Error fetching live data ');
    setState(() {
      _isNetworkError = true;
      _errorMessage = e is TimeoutException
          ? 'Connection timed out. Please check your network.'
          : 'Unable to fetch live data. Please try again later.';
    });
  }

  // Fetch with timeout utility
  Future<http.Response> _fetchWithTimeout(
      Uri url,
      {int timeoutSeconds = 10}
      ) async {
    try {
      return await http.get(url).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Fetch live stream links
  Future<void> _fetchLiveStreamLinks() async {
    try {
      final response = await _fetchWithTimeout(
        Uri.parse('https://securepayments.live/brd/livest.json'),
        timeoutSeconds: 10,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();

        setState(() {
          streamLinks = data['links'] ?? [];
        });

        await prefs.setString('cached_stream_links', json.encode(streamLinks));
      }
    } catch (e) {
      print('Error fetching live stream ');
    }
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Updates'),
        actions: [
          if (_isNetworkError)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _initializePageData,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _initializePageData,
        child: Column(
          children: [
            if (bannerAd != null)
              SizedBox(
                height: bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: bannerAd!),
              ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Network error state
    if (_isNetworkError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializePageData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Loading state
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Main content
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          if (isLiveStreamAvailable == true)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StreamListPage(
                      links: streamLinks,
                      rewardedAd: rewardedAd,
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 100,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'See Live Streams',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          liveRaces.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No live races currently',
              style: TextStyle(fontSize: 18),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: liveRaces.length,
            itemBuilder: (context, index) {
              final race = liveRaces[index];
              return Card(
                child: ListTile(
                  leading: race['circuit']['image'] != null
                      ? Image.network(
                    race['circuit']['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.sports_motorsports),
                  title: Text('${race['competition']['name']} - ${race['type']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Circuit: ${race['circuit']['name']}'),
                      Text(
                        'Location: ${race['competition']['location']['city']}, ${race['competition']['location']['country']}',
                      ),
                      Text(
                        'Laps: ${race['laps']['current'] ?? 'N/A'}/${race['laps']['total'] ?? 'N/A'}',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Stream List Page (Updated)
class StreamListPage extends StatefulWidget {
  final List<dynamic> links;
  final RewardedAd? rewardedAd;

  const StreamListPage({
    Key? key,
    required this.links,
    required this.rewardedAd
  }) : super(key: key);

  @override
  _StreamListPageState createState() => _StreamListPageState();
}

class _StreamListPageState extends State<StreamListPage> {
  Set<String> _clickedLinks = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Links'),
      ),
      body: widget.links.isEmpty
          ? const Center(child: Text('No streams available'))
          : ListView.builder(
        itemCount: widget.links.length,
        itemBuilder: (context, index) {
          final linkKey = widget.links[index].keys.first;
          final linkData = widget.links[index][linkKey];
          final linkUrl = linkData['url'];

          return ListTile(
            title: Text(linkData['name'] ?? 'Stream ${index + 1}'),
            trailing: const Icon(Icons.play_circle_fill),
            onTap: _clickedLinks.contains(linkUrl)
                ? null
                : () {
              setState(() {
                _clickedLinks.add(linkUrl);
              });

              if (widget.rewardedAd != null) {
                widget.rewardedAd!.show(
                  onUserEarnedReward: (ad, reward) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerPage(
                          url: linkData['url'],
                          headers: Map<String, String>.from(
                              linkData['headers'] ?? {}
                          ),
                        ),
                      ),
                    ).then((_) {
                      setState(() {
                        _clickedLinks.remove(linkUrl);
                      });
                    });
                  },
                );
              } else {
                // In StreamListPage's onTap method
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(
                      url: linkData['url'],
                      headers: Map<String, String>.from(
                          linkData['headers'] ?? {}
                      ),
                      rewardedAd: widget.rewardedAd,
                    ),
                  ),
                ).then((_) {
                  setState(() {
                    _clickedLinks.remove(linkUrl);
                  });
                });
              }
            },
          );
        },
      ),
    );
  }
}

// Video Player Page (Updated)
class VideoPlayerPage extends StatefulWidget {
  final String url;
  final Map<String, String> headers;
  final RewardedAd? rewardedAd;

  const VideoPlayerPage({
    Key? key,
    required this.url,
    required this.headers,
    this.rewardedAd
  }) : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  Timer? _timeoutTimer;
  bool _showErrorMessage = false;

  @override
  void initState() {
    super.initState();

    // Set to full screen landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _showRewardedAdBeforeVideo();
    // Show rewarded ad before initializing video
  }

  void _showRewardedAdBeforeVideo() {
    if (widget.rewardedAd != null) {
      widget.rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {

        },
      );
    } else {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    // Set timeout timer
    _timeoutTimer = Timer(const Duration(seconds: 50), () {
      if (!_isInitialized) {
        setState(() {
          _isLoading = false;
          _showErrorMessage = true;
        });
      }
    });

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: widget.headers,
    )..initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
          _showErrorMessage = false;
          _controller.play();
        });
        _timeoutTimer?.cancel();
      }
    }).catchError((error) {
      print('Video initialization error: $error');
      if (mounted) {
        setState(() {
          _isInitialized = false;
          _isLoading = false;
          _showErrorMessage = true;
        });
        _timeoutTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    // Reset to default UI and orientations
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    _timeoutTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _retryOrChangeStream() {
    // You might want to implement a method to go back to stream list or retry
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _showErrorMessage
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Stream might not be available',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            const Text(
              'Please try:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _retryOrChangeStream,
              child: const Text('Change Stream'),
            ),
          ],
        )
            : _isLoading
            ? const CircularProgressIndicator()
            : _isInitialized
            ? GestureDetector(
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        )
            : const Text(
          'Unable to load video',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}