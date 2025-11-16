import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
// NO extra imports needed

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
      home: const MyHomePage(), // CHANGED: ensure not const if you later use mutable state (kept const here; still fine)
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      _toastPath = Path()
        ..moveTo(size.width * 0.55, size.height * 0.10)
        ..lineTo(size.width * 0.75, size.height * 0.25)
        ..lineTo(size.width * 0.20, size.height * 0.35)
        ..lineTo(size.width * 0.18, size.height * 0.48)
        ..lineTo(size.width * 0.55, size.height * 0.62)
        ..lineTo(size.width * 0.52, size.height * 0.69)
        ..lineTo(size.width * 0.20, size.height * 0.85);

      setState(() {});
    });

    _getScreenTimeToday();
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

    bool granted = (await UsageStats.checkUsagePermission()) ?? false;
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
                    image: AssetImage('assets/forest_path.png'),
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

Offset getPointOnFlutterPath(Path path, double t) {
  // t = 0.0 .. 1.0
  final metrics = path.computeMetrics().toList();
  if (metrics.isEmpty) return Offset.zero;

  // Take the first metric (you have a single path)
  final metric = metrics.first;
  final distance = metric.length * t;
  return metric.getTangentForOffset(distance)?.position ?? Offset.zero;
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

// Shop Page
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

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
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A3428),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partners Section
              const Text(
                'Partners',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),

              // Partner Card
              _buildPartnerCard(
                name: 'Toastie',
                description: 'Toastie is a hard-working and diligent piece of bread, always looking for the next condiment to spread.',
                backgroundColor: const Color(0xFFFFF9E6),
                accentColor: const Color(0xFFC8E6C9),
              ),

              const SizedBox(height: 30),

              // Map Section
              const Text(
                'Map',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),

              // Map Card
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/summer_path.png'),
                    fit: BoxFit.cover,
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF4A3428),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Achievements Section
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A3428),
                ),
              ),
              const SizedBox(height: 12),

              // Achievements Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildAchievementBadge(true, '1 Day Streak'),
                  _buildAchievementBadge(true, '3 Day Streak'),
                  _buildAchievementBadge(false, '7 Day Streak'),
                  _buildAchievementBadge(true, '14 Day Streak'),
                  _buildAchievementBadge(false, '30 Day Streak'),
                  _buildAchievementBadge(false, '60 Day Streak'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerCard({
    required String name,
    required String description,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Character Image
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3D0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                '🍞',
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),

          // Description
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A3428),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4A3428),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF4A3428),
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

  Widget _buildAchievementBadge(bool unlocked, String label) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: unlocked ? const Color(0xFF8B6F47) : const Color(0xFFD4CDB8),
          width: 6,
        ),
        color: unlocked ? const Color(0xFFD4A574) : const Color(0xFFF5F0E1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unlocked ? '🥞' : '🥞',
              style: TextStyle(
                fontSize: 32,
                color: unlocked ? Colors.black : Colors.black.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: unlocked ? const Color(0xFF4A3428) : const Color(0xFFB8B0A0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
