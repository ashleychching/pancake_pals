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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  Duration _screenTime = Duration.zero;
  bool _isLoading = true;

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
              final pos = getPointOnFlutterPath(_toastPath!, _progress.value);


              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/summer_path.png'),
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
                      'assets/toast_asset.png',
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
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ShopPage(),
                                    ),
                                  );
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Friends',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content - Empty for now
              Expanded(
                child: Center(
                  child: Text(
                    'Add Friends Content Here',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
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
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
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
      imagePath: 'assets/character-bagel.png',
      name: 'Bagel',
      description: 'Bagel is a cheerful and round friend who loves rolling around and making everyone smile.',
      backgroundColor: const Color(0xFFFFE5CC),
      accentColor: const Color(0xFFB3E5FC),
    ),
    Partner(
      imagePath: 'assets/character-croissant.png',
      name: 'Croissant',
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
      imagePath: 'assets/autumn_path.png',
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