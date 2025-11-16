import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Time Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
List<Map<String, dynamic>> demoFriends = [
  {
    "name": "toastie",
    "tag": "4433",
    "avatar": "assets/character-toast.png"
  },
  {
    "name": "eggystan",
    "tag": "2211",
    "avatar": "assets/character-egg.png"
  },
  {
    "name": "wafflequeen",
    "tag": "9910",
    "avatar": "assets/character-waffle.png"
  },
];

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Duration _screenTime = Duration.zero;
  bool _isLoading = true;
  int currentPartnerIndex = 0;
  int currentMapIndex = 0;

  final List<Partner> partners = [
    Partner(
      imagePath: 'assets/character-toast.png',
      name: 'Toastie',
      description: 'Toastie is a hard-working and diligent piece of bread, always looking for the next condiment to spread.',
      backgroundColor: const Color(0xFFFFF9E6),
      accentColor: const Color(0xFFC8E6C9),
    ),
    Partner(
      imagePath: 'assets/character-egg.png',
      name: 'Eggy',
      description: 'Bagel is a cheerful and round friend who loves rolling around and making everyone smile.',
      backgroundColor: const Color(0xFFFFE5CC),
      accentColor: const Color(0xFFB3E5FC),
    ),
    Partner(
      imagePath: 'assets/character-strawberry.png',
      name: 'Starry',
      description: 'Croissant is elegant and flaky, always adding a touch of sophistication to any bakery.',
      backgroundColor: const Color(0xFFFFF4E0),
      accentColor: const Color(0xFFFFCCBC),
    ),
    Partner(
      imagePath: 'assets/character-waffle.png',
      name: 'Mr.Waffles',
      description: 'Croissant is elegant and flaky, always adding a touch of sophistication to any bakery.',
      backgroundColor: const Color(0xFFFFF4E0),
      accentColor: const Color(0xFFFFCCBC),
    ),
  ];

  final List<MapData> maps = [
    MapData(
      imagePath: 'assets/summer_path.png',
      name: 'Summer Path',
    ),
    MapData(
      imagePath: 'assets/winter_path.png',
      name: 'Winter Path',
    ),
    MapData(
      imagePath: 'assets/fall_path.png',
      name: 'Autumn Path',
    ),
    MapData(
      imagePath: 'assets/spring_path.png',
      name: 'Spring Path',
    ),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  late final Animation<double> _progress = Tween(begin: 0.0, end: 1.0).animate(_controller);

  Path? _toastPath;

  @override
  void initState() {
    super.initState();
    _getScreenTimeToday();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery
          .of(context)
          .size;

      _toastPath = Path()
        ..moveTo(size.width * 0.55, size.height * 0.10)
        ..lineTo(size.width * 0.75, size.height * 0.25)..lineTo(
            size.width * 0.20, size.height * 0.35)..lineTo(
            size.width * 0.18, size.height * 0.48)..lineTo(
            size.width * 0.55, size.height * 0.62)..lineTo(
            size.width * 0.52, size.height * 0.69)..lineTo(
            size.width * 0.20, size.height * 0.85);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getScreenTimeToday() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    bool granted = await UsageStats.checkUsagePermission() ?? false;
    if (!granted) {
      await UsageStats.grantUsagePermission();
      setState(() => _isLoading = false);
      return;
    }

    List<UsageInfo> usage = await UsageStats.queryUsageStats(startOfDay, now);
    int totalMillis = 0;

    for (var info in usage) {
      final obj = info.totalTimeInForeground;
      if (obj != null) {
        final str = obj.toString();
        totalMillis += int.tryParse(str) ?? 0;
      }
    }

    setState(() {
      _screenTime = Duration(milliseconds: totalMillis);
      _isLoading = false;
    });
  }

  String get formattedScreenTime {
    final hours = _screenTime.inHours;
    final minutes = _screenTime.inMinutes % 60;
    return '${hours} HR ${minutes} Min';
  }

  double get timePercent {
    final screenTime = _screenTime.inMinutes;
    DateTime now = DateTime.now();
    final dayTime = now.hour * 60 + now.minute;
    return (dayTime - screenTime) / 1440.0;
  }

  Widget buildFriendItem(String avatarPath, String name, String tag) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Color(0xFFEBF5DF), // Outer background mint
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: Color(0xFFEDB458), // Inner bar golden color
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                avatarPath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),

            // Name + tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_toastPath == null) {
            return const SizedBox();
          }

          return AnimatedBuilder(
            animation: _progress,
            builder: (context, _) {
              final size = MediaQuery
                  .of(context)
                  .size;
              final pos = getPointOnFlutterPath(_toastPath!, timePercent);


              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(maps[currentMapIndex].imagePath),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Screen Time',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      formattedScreenTime,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: pos.dx, // center-ish horizontally
                    top: pos.dy,
                    child: Image.asset(
                      partners[currentPartnerIndex].imagePath,
                      width: 66,
                      height: 66,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Add Friends Button (Left)
                          _buildNavButton(
                            icon: Icons.person_add,
                            onTap: () {
                              _showAddFriendsModal(context);
                            },
                          ),

                          // Right side buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Stats Button
                              _buildNavButton(
                                icon: Icons.bar_chart,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StatsPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 15),

                              // Shop Button
                              _buildNavButton(
                                icon: Icons.shopping_bag,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShopPage(
                                        initialPartnerIndex: currentPartnerIndex,
                                        initialMapIndex: currentMapIndex,
                                      ),
                                    ),
                                  );

                                  if (result != null && result is Map<String, int>) {
                                    setState(() {
                                      currentPartnerIndex = result['partnerIndex'] ?? currentPartnerIndex;
                                      currentMapIndex = result['mapIndex'] ?? currentMapIndex;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Offset getPointOnFlutterPath(Path path, double t) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return Offset.zero;
    final metric = metrics.first;
    final distance = metric.length * t;
    return metric.getTangentForOffset(distance)?.position ?? Offset.zero;
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  void _showAddFriendsModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 350,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF4F4BB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Title
                Text(
                  "Add Friends",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Search users...",
                    hintStyle: TextStyle(color: Colors.black54),

                    // Background color
                    filled: true,
                    fillColor: Color(0xFFBAD4AA), // your soft green 🍃

                    // Search Icon Left
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        "assets/Search.png",
                        width: 20,
                        height: 20,
                      ),
                    ),

                    // Border + rounded corners
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),


                SizedBox(height: 20),

                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: demoFriends.length,
                    itemBuilder: (context, index) {
                      final friend = demoFriends[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFEDB458), // full orange card
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.only(left: 80, right: 16, top: 16, bottom: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${friend['name']}#${friend['tag']}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Color(0xFFEBF5DF), // the light green box
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    bottomLeft: Radius.circular(14),
                                  ),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  friend['avatar'], // PNG file
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            Positioned(
                              right: 12,
                              top: 12,
                              child: GestureDetector(
                                onTap: () => print("Added ${friend['name']}"),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person_add_alt_1,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

// Partner Model
class Partner {
  final String imagePath;
  final String name;
  final String description;
  final Color backgroundColor;
  final Color accentColor;

  Partner({
    required this.imagePath,
    required this.name,
    required this.description,
    required this.backgroundColor,
    required this.accentColor,
  });
}

// Map Model
class MapData {
  final String imagePath;
  final String name;

  MapData({
    required this.imagePath,
    required this.name,
  });
}

// Stats Page (Empty for now)
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        title: const Text('Stats'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Stats Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

// Shop Page with Cycling
class ShopPage extends StatefulWidget {
  final int initialPartnerIndex;
  final int initialMapIndex;

  const ShopPage({
    super.key,
    this.initialPartnerIndex = 0,
    this.initialMapIndex = 0,
  });

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int currentPartnerIndex = 0;
  int currentMapIndex = 0;

  @override
  void initState() {
    super.initState();
    currentPartnerIndex = widget.initialPartnerIndex;
    currentMapIndex = widget.initialMapIndex;
  }

  final List<Partner> partners = [
    Partner(
      imagePath: 'assets/character-toast.png',
      name: 'Toastie',
      description: 'Toastie is a hard-working and diligent piece of bread, always looking for the next condiment to spread.',
      backgroundColor: const Color(0xFFFFF9E6),
      accentColor: const Color(0xFFC8E6C9),
    ),
    Partner(
      imagePath: 'assets/character-egg.png',
      name: 'Eggy',
      description: 'Bagel is a cheerful and round friend who loves rolling around and making everyone smile.',
      backgroundColor: const Color(0xFFFFE5CC),
      accentColor: const Color(0xFFB3E5FC),
    ),
    Partner(
      imagePath: 'assets/character-strawberry.png',
      name: 'Starry',
      description: 'Croissant is elegant and flaky, always adding a touch of sophistication to any bakery.',
      backgroundColor: const Color(0xFFFFF4E0),
      accentColor: const Color(0xFFFFCCBC),
    ),
    Partner(
      imagePath: 'assets/character-waffle.png',
      name: 'Mr.Waffles',
      description: 'Croissant is elegant and flaky, always adding a touch of sophistication to any bakery.',
      backgroundColor: const Color(0xFFFFF4E0),
      accentColor: const Color(0xFFFFCCBC),
    ),
  ];

  final List<MapData> maps = [
    MapData(
      imagePath: 'assets/summer_path.png',
      name: 'Summer Path',
    ),
    MapData(
      imagePath: 'assets/winter_path.png',
      name: 'Winter Path',
    ),
    MapData(
      imagePath: 'assets/fall_path.png',
      name: 'Autumn Path',
    ),
    MapData(
      imagePath: 'assets/spring_path.png',
      name: 'Autumn Path',
    ),
  ];

  void nextPartner() {
    setState(() {
      currentPartnerIndex = (currentPartnerIndex + 1) % partners.length;
    });
    print('Next partner: ${partners[currentPartnerIndex].name}');
  }

  void nextMap() {
    setState(() {
      currentMapIndex = (currentMapIndex + 1) % maps.length;
    });
    print('Next map: ${maps[currentMapIndex].name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8E4D0),
        foregroundColor: const Color(0xFF4A3428),
        title: const Text(
          'Bakery Shop',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A3428),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFE8E4D0),
                  size: 20,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  'partnerIndex': currentPartnerIndex,
                  'mapIndex': currentMapIndex,
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Partners',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),
              _buildPartnerCard(
                context,
                partner: partners[currentPartnerIndex],
                onNext: nextPartner,
              ),
              const SizedBox(height: 30),
              const Text(
                'Map',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),
              _buildMapCard(
                context,
                map: maps[currentMapIndex],
                onNext: nextMap,
              ),
              const SizedBox(height: 30),
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildAchievementBadge(true, 'assets/badge-earlyRiser.png'),
                  _buildAchievementBadge(true, 'assets/badge-onARoll.png'),
                  _buildAchievementBadge(false, 'assets/badge-earlyRiser.png'),
                  _buildAchievementBadge(true, 'assets/badge-onARoll.png'),
                  _buildAchievementBadge(false, 'assets/badge-earlyRiser.png'),
                  _buildAchievementBadge(false, 'assets/badge-onARoll.png'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerCard(
      BuildContext context, {
        required Partner partner,
        required VoidCallback onNext,
      }) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 140,
            decoration: BoxDecoration(
              color: partner.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Image.asset(
                partner.imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image,
                    size: 60,
                    color: Color(0xFFD4CDB8),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: partner.accentColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3428),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          partner.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4A3428),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Color(0xFF4A3428),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(
      BuildContext context, {
        required MapData map,
        required VoidCallback onNext,
      }) {
    return GestureDetector(
      onTap: onNext,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(map.imagePath),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              print('Error loading map image: ${map.imagePath}');
            },
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF4A3428),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(bool unlocked, String imagePath) {
    return ClipOval(
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        color: unlocked ? null : Colors.white.withOpacity(0.6),
        colorBlendMode: unlocked ? null : BlendMode.lighten,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? const Color(0xFFD4A574) : const Color(0xFFF5F0E1),
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events,
                size: 40,
                color: unlocked
                    ? const Color(0xFF4A3428)
                    : const Color(0xFFB8B0A0),
              ),
            ),
          );
        },
      ),
    );
  }
}