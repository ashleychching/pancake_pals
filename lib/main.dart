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
        fontFamily: 'ZCOOLKuaiLe',
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
    "avatar": "assets/character-toast.png",
    "time": 40
  },
  {
    "name": "eggystan",
    "tag": "2211",
    "avatar": "assets/character-egg.png",
    "time": 350
  },
  {
    "name": "wafflequeen",
    "tag": "9910",
    "avatar": "assets/character-waffle.png",
    "time": 600
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

  List<Map<String, dynamic>> addedFriends = [];

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
                        alignment: const Alignment(0.23, 0),
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
                  for (int i = 0; i < addedFriends.length; i++)
                    Positioned(
                      left: getPointOnFlutterPath(_toastPath!, (DateTime.now().hour * 60 + DateTime.now().minute - addedFriends[i]['time']) / 1440.0).dx,
                      top: getPointOnFlutterPath(_toastPath!, (DateTime.now().hour * 60 + DateTime.now().minute - addedFriends[i]['time']) / 1440.0).dy,
                      child: Image.asset(
                        addedFriends[i]['avatar'],
                        width: 50, // slightly smaller than main character
                        height: 50,
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
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
          color: Colors.brown.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
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
                                onTap: () {
                                  setState(() {
                                    addedFriends.add(friend);
                                  });
                                },
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
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int currentLeaderboardIndex = 0;
  int currentStatsIndex = 0;

  void nextLeaderboard() {
    setState(() {
      currentLeaderboardIndex = (currentLeaderboardIndex + 1) % 2;
    });
  }

  void nextStats() {
    setState(() {
      currentStatsIndex = (currentStatsIndex + 1) % 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8E4D0),
        foregroundColor: const Color(0xFF4A3428),
        title: const Text(
          'Pancake-ium',
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
              onPressed: () => Navigator.pop(context),
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
              // Weekly Winner Section
              const Text(
                'Weekly Winner',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),
              _buildLeaderboardCard(),
              const SizedBox(height: 30),

              // Stats Section
              const Text(
                'Stats',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),
              _buildStatsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: currentLeaderboardIndex == 0
                ? _buildPodiumView()
                : _buildListView(),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: nextLeaderboard,
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
    );
  }
  Widget _buildPodiumView() {
    return SizedBox(
      height: 468, // Total available height (500 - 32 padding)
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Large podium image at the bottom
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/pancakeStack.png',
              height: 200,
              width: 250,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading pancake stack: $error');
                return Container(
                  height: 200,
                  width: 250,
                  color: const Color(0xFFD4A574),
                  child: const Center(
                    child: Text('Podium Image'),
                  ),
                );
              },
            ),
          ),
          // Characters positioned on the podium
          Positioned(
            bottom: 150,
            left: 40,
            child: _buildCharacterWithName(
              name: 'EGGY',
              character: 'assets/character-egg.png',
              offsetY: 0,
            ),
          ),
          Positioned(
            bottom: 180,
            child: _buildCharacterWithName(
              name: 'TOASTYTOASTIE',
              character: 'assets/character-toast.png',
              offsetY: 0,
              showCrown: true,
            ),
          ),
          Positioned(
            bottom: 120,
            right: 40,
            child: _buildCharacterWithName(
              name: 'SARAH',
              character: 'assets/character-strawberry.png',
              offsetY: 0,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCharacterWithName({
    required String name,
    required String character,
    required double offsetY,
    bool showCrown = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCrown)
          const Text(
            '👑',
            style: TextStyle(fontSize: 16),
          ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              character,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 25);
              },
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: 70,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A3428),
            ),
          ),
        ),
        SizedBox(height: offsetY),
      ],
    );
  }

  Widget _buildListView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLeaderboardItem(1, 'TOASTYTOASTIE', '14 hrs 19 min', 'assets/character-toast.png', true),
        const SizedBox(height: 23),
        _buildLeaderboardItem(2, 'EGGY', '19 hrs 35 min', 'assets/character-egg.png', false),
        const SizedBox(height: 23),
        _buildLeaderboardItem(3, 'SARAH', '35 hrs 11 min', 'assets/character-strawberry.png', false),
      ],
    );
  }

  Widget _buildLeaderboardItem(int rank, String name, String time, String character, bool isWinner) {
    return Row(
      children: [
        Text(
          '$rank',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A3428),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              character,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 30);
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A3428),
                    ),
                  ),
                  if (isWinner) const Text(' 👑', style: TextStyle(fontSize: 16)),
                ],
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4A3428),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentStatsIndex == 0 ? 'Weekly' : 'Monthly',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A3428),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: currentStatsIndex == 0
                      ? _buildWeeklyChart()
                      : _buildMonthlyChart(),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: nextStats,
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
    );
  }

  Widget _buildWeeklyChart() {
    final weekData = [
      {'day': 'M', 'hours': 3.0},
      {'day': 'T', 'hours': 2.5},
      {'day': 'W', 'hours': 1.5},
      {'day': 'T', 'hours': 5.0},
      {'day': 'F', 'hours': 2.0},
      {'day': 'S', 'hours': 5.5},
      {'day': 'S', 'hours': 6.0},
    ];

    return _buildBarChart(weekData, const Color(0xFFC8E6C9));
  }

  Widget _buildMonthlyChart() {
    final monthData = [
      {'day': 'J', 'hours': 3.0},
      {'day': 'F', 'hours': 2.5},
      {'day': 'M', 'hours': 4.0},
      {'day': 'A', 'hours': 3.5},
      {'day': 'M', 'hours': 5.0},
      {'day': 'J', 'hours': 4.5},
      {'day': 'J', 'hours': 6.0},
      {'day': 'A', 'hours': 5.0},
      {'day': 'S', 'hours': 5.5},
      {'day': 'O', 'hours': 3.5},
      {'day': 'N', 'hours': 4.0},
      {'day': 'D', 'hours': 6.5},
    ];

    return _buildBarChart(monthData, const Color(0xFFFFB74D));
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, Color barColor) {
    final maxHours = 7.0;

    return Stack(
      children: [
        // Y-axis labels and dotted lines
        Positioned.fill(
          child: Column(
            children: [
              for (int i = 7; i >= 1; i--)
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 35,
                        child: Text(
                          '$i hr',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF4A3428),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomPaint(
                          painter: DottedLinePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        // Bars on top of grid
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final hours = item['hours'] as double;
              final day = item['day'] as String;
              final heightPercent = hours / maxHours;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            height: 190 * heightPercent,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A3428),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Custom painter for dotted lines
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A3428).withOpacity(0.3)
      ..strokeWidth = 1;

    const dashWidth = 4;
    const dashSpace = 4;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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