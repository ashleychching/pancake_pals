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

// Shop Page (Empty for now)
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        foregroundColor: Colors.white,
        title: const Text('Shop'),
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Shop Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
