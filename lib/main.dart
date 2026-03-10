import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

List<CameraDescription> appCameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    appCameras = await availableCameras();
  } catch (_) {
    appCameras = [];
  }
  runApp(const LiturApp());
}

class LiturApp extends StatelessWidget {
  const LiturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: AppState(),
      child: MaterialApp(
        title: 'Litur',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050505),
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF050505),
            primary: Colors.white,
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ).copyWith(
            bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.bold),
            bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.bold),
            displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold),
            displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold),
            displaySmall: GoogleFonts.inter(fontWeight: FontWeight.bold),
            headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.bold),
            headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.bold),
            headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.bold),
            titleLarge: GoogleFonts.inter(fontWeight: FontWeight.bold),
            titleMedium: GoogleFonts.inter(fontWeight: FontWeight.bold),
            titleSmall: GoogleFonts.inter(fontWeight: FontWeight.bold),
            labelLarge: GoogleFonts.inter(fontWeight: FontWeight.bold),
            labelMedium: GoogleFonts.inter(fontWeight: FontWeight.bold),
            labelSmall: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class AppColors {
  static const Color black = Color(0xFF0a0a0a);
  static const Color offBlack = Color(0xFF111111);
  static const Color dark = Color(0xFF1c1c1c);
  static const Color mid = Color(0xFF2e2e2e);
  static const Color border = Color(0xFF2a2a2a);
  static const Color borderLight = Color(0xFF3a3a3a);
  static const Color white = Color(0xFFf5f5f0);
  static const Color offWhite = Color(0xFFe8e8e2);
  static const Color muted = Color(0xFF666);
  static const Color muted2 = Color(0xFF444);
  static const Color highlight = Color(0x0FFFFFFF);
  static const Color highlight2 = Color(0x1FFFFFFF);
}

class AppState extends ChangeNotifier {
  final List<PaletteData> palettes =
      initialPalettes
          .map((p) => PaletteData(name: p.name, colors: List.of(p.colors)))
          .toList();
  final Set<String> favorites = {};
  final Map<String, String> customNames = {};
  final Map<String, bool> settings = {
    'showNames': true,
    'autoDetectNames': true,
    'haptics': false,
    'icloudSync': true,
  };
  DateTime? lastSyncTime;
  String? _selectedPaletteName;

  bool isFavorite(ColorData color) => favorites.contains(color.hex);

  void toggleFavorite(ColorData color) {
    if (isFavorite(color)) {
      favorites.remove(color.hex);
    } else {
      favorites.add(color.hex);
    }
    notifyListeners();
  }

  String displayName(ColorData color) => customNames[color.hex] ?? color.name;

  void renameColor(ColorData color, String name) {
    if (name.trim().isEmpty) return;
    customNames[color.hex] = name.trim();
    notifyListeners();
  }

  void addPalette(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final uniqueName = _uniquePaletteName(trimmed);
    palettes.insert(0, PaletteData(name: uniqueName, colors: []));
    _selectedPaletteName ??= uniqueName;
    notifyListeners();
  }

  void deletePalette(PaletteData palette) {
    palettes.removeWhere((p) => p.name == palette.name);
    if (_selectedPaletteName == palette.name) {
      _selectedPaletteName = palettes.isEmpty ? null : palettes.first.name;
    }
    notifyListeners();
  }

  void addColorToPalette(String paletteName, ColorData color) {
    final index = palettes.indexWhere((p) => p.name == paletteName);
    if (index == -1) return;
    final palette = palettes[index];
    if (palette.colors.any((c) => c.hex == color.hex)) return;
    final updated = PaletteData(
      name: palette.name,
      colors: [...palette.colors, color],
    );
    palettes[index] = updated;
    notifyListeners();
  }

  String get selectedPaletteName {
    if (_selectedPaletteName == null || _selectedPaletteName!.isEmpty) {
      _selectedPaletteName = palettes.isEmpty ? '' : palettes.first.name;
    }
    return _selectedPaletteName ?? '';
  }

  void setSelectedPaletteName(String name) {
    _selectedPaletteName = name;
    notifyListeners();
  }

  void toggleSetting(String key) {
    if (!settings.containsKey(key)) return;
    settings[key] = !(settings[key] ?? false);
    notifyListeners();
  }

  void syncNow() {
    lastSyncTime = DateTime.now();
    notifyListeners();
  }

  String get syncStatus {
    final time = lastSyncTime;
    if (time == null) return 'Not synced';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} days ago';
  }

  String _uniquePaletteName(String base) {
    var candidate = base;
    var counter = 2;
    while (palettes.any((p) => p.name == candidate)) {
      candidate = '$base $counter';
      counter += 1;
    }
    return candidate;
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    return scope!.notifier!;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x40000000), blurRadius: 30),
                    ],
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Litur',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Color Library',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.camera_alt_outlined,
      title: 'Pick Colors',
      description: 'Capture colors from your camera or pick from images',
    ),
    OnboardingPage(
      icon: Icons.palette_outlined,
      title: 'Create Palettes',
      description: 'Save and organize your favorite colors into palettes',
    ),
    OnboardingPage(
      icon: Icons.grid_view_rounded,
      title: 'Browse Library',
      description: 'Access your color library anytime, anywhere',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PhoneShell(),
          transitionsBuilder:
              (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const PhoneShell(),
                          transitionsBuilder:
                              (_, animation, __, child) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.dark,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            page.icon,
                            size: 48,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _currentPage == index ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? AppColors.white
                              : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ColorData {
  final String hex;
  final String name;
  final int r, g, b;

  ColorData({
    required this.hex,
    required this.name,
    required this.r,
    required this.g,
    required this.b,
  });

  Color get color => Color(int.parse(hex.replaceFirst('#', '0xFF')));

  String get rgb => 'rgb($r, $g, $b)';

  String get hsb {
    final rNorm = r / 255;
    final gNorm = g / 255;
    final bNorm = b / 255;
    final max = [rNorm, gNorm, bNorm].reduce((a, b) => a > b ? a : b);
    final min = [rNorm, gNorm, bNorm].reduce((a, b) => a < b ? a : b);
    final diff = max - min;
    double h = 0;
    if (diff != 0) {
      if (max == rNorm) {
        h = 60 * (((gNorm - bNorm) / diff) % 6);
      } else if (max == gNorm) {
        h = 60 * (((bNorm - rNorm) / diff) + 2);
      } else {
        h = 60 * (((rNorm - gNorm) / diff) + 4);
      }
      if (h < 0) h += 360;
    }
    final s = max == 0 ? 0.0 : (diff / max) * 100;
    final v = max * 100;
    return '${h.round()}°, ${s.round()}%, ${v.round()}%';
  }

  String get cmyk {
    final rNorm = r / 255;
    final gNorm = g / 255;
    final bNorm = b / 255;
    final k = 1 - [rNorm, gNorm, bNorm].reduce((a, b) => a > b ? a : b);
    if (k == 1) return '0, 0, 0, 100';
    final c = (1 - rNorm - k) / (1 - k) * 100;
    final m = (1 - gNorm - k) / (1 - k) * 100;
    final y = (1 - bNorm - k) / (1 - k) * 100;
    return '${c.round()}, ${m.round()}, ${y.round()}, ${(k * 100).round()}';
  }
}

class PaletteData {
  final String name;
  final List<ColorData> colors;
  PaletteData({required this.name, required this.colors});
}

final List<ColorData> colorLibrary = [
  ColorData(hex: '#0F0F0F', name: 'Jet Black', r: 15, g: 15, b: 15),
  ColorData(hex: '#1A1A1A', name: 'Carbon', r: 26, g: 26, b: 26),
  ColorData(hex: '#2E2E2E', name: 'Graphite', r: 46, g: 46, b: 46),
  ColorData(hex: '#505518', name: 'Forest Shadow', r: 80, g: 85, b: 24),
  ColorData(hex: '#5386C0', name: 'Steel Blue', r: 83, g: 134, b: 192),
  ColorData(hex: '#FBCE50', name: 'Sunflower', r: 251, g: 206, b: 80),
  ColorData(hex: '#C0392B', name: 'Crimson', r: 192, g: 57, b: 43),
  ColorData(hex: '#2ECC71', name: 'Emerald', r: 46, g: 204, b: 113),
  ColorData(hex: '#E1FEE0', name: 'Mint Frost', r: 225, g: 254, b: 224),
  ColorData(hex: '#8E44AD', name: 'Amethyst', r: 142, g: 68, b: 173),
  ColorData(hex: '#E67E22', name: 'Tangerine', r: 230, g: 126, b: 34),
  ColorData(hex: '#E9DEC6', name: 'Desert Sand', r: 233, g: 222, b: 198),
  // New Colors
  ColorData(hex: '#D35400', name: 'Pumpkin', r: 211, g: 84, b: 0),
  ColorData(hex: '#C0392B', name: 'Pomegranate', r: 192, g: 57, b: 43),
  ColorData(hex: '#BDC3C7', name: 'Silver', r: 189, g: 195, b: 199),
  ColorData(hex: '#7F8C8D', name: 'Asbestos', r: 127, g: 140, b: 141),
  ColorData(hex: '#2C3E50', name: 'Midnight Blue', r: 44, g: 62, b: 80),
  ColorData(hex: '#F1C40F', name: 'Flat Yellow', r: 241, g: 196, b: 15),
  ColorData(hex: '#16A085', name: 'Green Sea', r: 22, g: 160, b: 133),
  ColorData(hex: '#27AE60', name: 'Nephritis', r: 39, g: 174, b: 96),
  ColorData(hex: '#2980B9', name: 'Belize Hole', r: 41, g: 128, b: 185),
  ColorData(hex: '#34495E', name: 'Wet Asphalt', r: 52, g: 73, b: 94),
  ColorData(hex: '#9B59B6', name: 'Amethyst Light', r: 155, g: 89, b: 182),
  ColorData(hex: '#3498DB', name: 'Peter River', r: 52, g: 152, b: 219),
  ColorData(hex: '#E74C3C', name: 'Alizarin', r: 231, g: 76, b: 60),
  ColorData(hex: '#95A5A6', name: 'Concrete', r: 149, g: 165, b: 166),
  ColorData(hex: '#ECF0F1', name: 'Clouds', r: 236, g: 240, b: 241),
  ColorData(hex: '#FF6F61', name: 'Living Coral', r: 255, g: 111, b: 97),
  ColorData(hex: '#6B5B95', name: 'Ultra Violet', r: 107, g: 91, b: 149),
  ColorData(hex: '#88B04B', name: 'Greenery', r: 136, g: 176, b: 75),
  ColorData(hex: '#F7CAC9', name: 'Rose Quartz', r: 247, g: 202, b: 201),
  ColorData(hex: '#92A8D1', name: 'Serenity', r: 146, g: 168, b: 209),
  ColorData(hex: '#955251', name: 'Marsala', r: 149, g: 82, b: 81),
  ColorData(hex: '#B163A3', name: 'Radiant Orchid', r: 177, g: 99, b: 163),
  ColorData(hex: '#55B4B0', name: 'Turquoise Blue', r: 85, g: 180, b: 176),
  ColorData(hex: '#EFC050', name: 'Mimosa', r: 239, g: 192, b: 80),
  ColorData(hex: '#45B8AC', name: 'Blue Turquoise', r: 69, g: 184, b: 172),
  ColorData(hex: '#D65076', name: 'True Red', r: 214, g: 80, b: 118),
  ColorData(hex: '#DD4124', name: 'Chili Pepper', r: 221, g: 65, b: 36),
  ColorData(hex: '#009B77', name: 'Emerald Green', r: 0, g: 155, b: 119),
  ColorData(hex: '#B87333', name: 'Copper', r: 184, g: 115, b: 51),
  ColorData(hex: '#FFD700', name: 'Gold Rush', r: 255, g: 215, b: 0),
  ColorData(hex: '#C0C0C0', name: 'Platinum', r: 192, g: 192, b: 192),
  ColorData(hex: '#E5E4E2', name: 'Almond', r: 229, g: 228, b: 226),
  ColorData(hex: '#5D8AA8', name: 'Air Force Blue', r: 93, g: 138, b: 168),
  ColorData(hex: '#F0F8FF', name: 'Alice Blue', r: 240, g: 248, b: 255),
  ColorData(hex: '#E32636', name: 'Alizarin Crimson', r: 227, g: 38, b: 54),
  ColorData(hex: '#FFBF00', name: 'Amber', r: 255, g: 191, b: 0),
  ColorData(hex: '#9966CC', name: 'Amethyst Dark', r: 153, g: 102, b: 204),
  ColorData(hex: '#A4C639', name: 'Android Green', r: 164, g: 198, b: 57),
  ColorData(hex: '#F2F3F4', name: 'Anti-Flash White', r: 242, g: 243, b: 244),
  ColorData(hex: '#CD9575', name: 'Antique Brass', r: 205, g: 149, b: 117),
  ColorData(hex: '#665D1E', name: 'Antique Bronze', r: 102, g: 93, b: 30),
  ColorData(hex: '#915C83', name: 'Antique Fuchsia', r: 145, g: 92, b: 131),
  ColorData(hex: '#841B2D', name: 'Antique Ruby', r: 132, g: 27, b: 45),
  ColorData(hex: '#FAEBD7', name: 'Antique White', r: 250, g: 235, b: 215),
  ColorData(hex: '#008000', name: 'Office Green', r: 0, g: 128, b: 0),
  ColorData(hex: '#8DB600', name: 'Apple Green', r: 141, g: 182, b: 0),
  ColorData(hex: '#FBCEB1', name: 'Apricot', r: 251, g: 206, b: 177),
  ColorData(hex: '#00FFFF', name: 'Aqua', r: 0, g: 255, b: 255),
  ColorData(hex: '#7FFFD4', name: 'Aquamarine', r: 127, g: 255, b: 212),
  ColorData(hex: '#D0FF14', name: 'Arctic Lime', r: 208, g: 255, b: 20),
  ColorData(hex: '#4B5320', name: 'Army Green', r: 75, g: 83, b: 32),
  ColorData(hex: '#3B444B', name: 'Arsenic', r: 59, g: 68, b: 75),
  ColorData(hex: '#87A96B', name: 'Asparagus', r: 135, g: 169, b: 107),
  ColorData(hex: '#F0FFFF', name: 'Azure', r: 240, g: 255, b: 255),
  ColorData(hex: '#89CFF0', name: 'Baby Blue', r: 137, g: 207, b: 240),
  ColorData(hex: '#F4C2C2', name: 'Baby Pink', r: 244, g: 194, b: 194),
  ColorData(hex: '#21ABCD', name: 'Ball Blue', r: 33, g: 171, b: 205),
  ColorData(hex: '#FAE7B5', name: 'Banana Mania', r: 250, g: 231, b: 181),
  ColorData(hex: '#FFE135', name: 'Banana Yellow', r: 255, g: 225, b: 53),
  ColorData(hex: '#7C0A02', name: 'Barn Red', r: 124, g: 10, b: 2),
  ColorData(hex: '#848482', name: 'Battleship Grey', r: 132, g: 132, b: 130),
  ColorData(hex: '#98777B', name: 'Bazaar', r: 152, g: 119, b: 123),
  ColorData(hex: '#BCD4E6', name: 'Beau Blue', r: 188, g: 212, b: 230),
  ColorData(hex: '#9F8170', name: 'Beaver', r: 159, g: 129, b: 112),
  ColorData(hex: '#F5F5DC', name: 'Beige', r: 245, g: 245, b: 220),
  ColorData(hex: '#3D0608', name: 'Black Bean', r: 61, g: 6, b: 8),
  ColorData(hex: '#660000', name: 'Blood Red', r: 102, g: 0, b: 0),
  ColorData(hex: '#0000FF', name: 'Blue', r: 0, g: 0, b: 255),
  ColorData(hex: '#6082B6', name: 'Glaucous Blue', r: 96, g: 130, b: 182),
  ColorData(hex: '#0047AB', name: 'Cobalt Blue', r: 0, g: 71, b: 171),
  ColorData(hex: '#002366', name: 'Royal Blue', r: 0, g: 35, b: 102),
  ColorData(hex: '#191970', name: 'Midnight Blue', r: 25, g: 25, b: 112),
  ColorData(hex: '#4169E1', name: 'Royal Blue Web', r: 65, g: 105, b: 225),
  ColorData(hex: '#8A2BE2', name: 'Blue Violet', r: 138, g: 43, b: 226),
  ColorData(hex: '#DE5D83', name: 'Blush', r: 222, g: 93, b: 131),
  ColorData(hex: '#79443B', name: 'Bole', r: 121, g: 68, b: 59),
  ColorData(hex: '#006A4E', name: 'Bottle Green', r: 0, g: 106, b: 78),
  ColorData(hex: '#B57EDC', name: 'Lavender', r: 181, g: 126, b: 220),
  ColorData(hex: '#CB4154', name: 'Brick Red', r: 203, g: 65, b: 84),
  ColorData(hex: '#1DACD6', name: 'Bright Cerulean', r: 29, g: 172, b: 214),
  ColorData(hex: '#66FF00', name: 'Bright Green', r: 102, g: 255, b: 0),
  ColorData(hex: '#BF94E4', name: 'Bright Lavender', r: 191, g: 148, b: 228),
  ColorData(hex: '#C32148', name: 'Bright Maroon', r: 195, g: 33, b: 72),
  ColorData(hex: '#FF007F', name: 'Bright Pink', r: 255, g: 0, b: 127),
  ColorData(hex: '#08E8DE', name: 'Bright Turquoise', r: 8, g: 232, b: 222),
  ColorData(hex: '#D1001C', name: 'Bright Ube', r: 209, g: 0, b: 28),
  ColorData(hex: '#FF55A3', name: 'Brilliant Rose', r: 255, g: 85, b: 163),
  ColorData(hex: '#FB607F', name: 'Brink Pink', r: 251, g: 96, b: 127),
  ColorData(hex: '#0070FF', name: 'Brandeis Blue', r: 0, g: 112, b: 255),
  ColorData(hex: '#B22222', name: 'Firebrick', r: 178, g: 34, b: 34),
  ColorData(hex: '#DAA520', name: 'Goldenrod', r: 218, g: 165, b: 32),
  ColorData(hex: '#008080', name: 'Teal', r: 0, g: 128, b: 128),
  ColorData(hex: '#FFDAB9', name: 'Peach Puff', r: 255, g: 218, b: 185),
  ColorData(hex: '#E6E6FA', name: 'Lavender Web', r: 230, g: 230, b: 250),
  ColorData(hex: '#FFF0F5', name: 'Lavender Blush', r: 255, g: 240, b: 245),
  ColorData(hex: '#F0E68C', name: 'Khaki', r: 240, g: 230, b: 140),
  ColorData(hex: '#BDB76B', name: 'Dark Khaki', r: 189, g: 183, b: 107),
  ColorData(hex: '#556B2F', name: 'Dark Olive Green', r: 85, g: 107, b: 47),
  ColorData(hex: '#8B4513', name: 'Saddle Brown', r: 139, g: 69, b: 19),
  ColorData(hex: '#A0522D', name: 'Sienna', r: 160, g: 82, b: 45),
  ColorData(hex: '#BC8F8F', name: 'Rosy Brown', r: 188, g: 143, b: 143),
  ColorData(hex: '#CD5C5C', name: 'Indian Red', r: 205, g: 92, b: 92),
  ColorData(hex: '#F08080', name: 'Light Coral', r: 240, g: 128, b: 128),
  ColorData(hex: '#FA8072', name: 'Salmon', r: 250, g: 128, b: 114),
  ColorData(hex: '#FFA07A', name: 'Light Salmon', r: 255, g: 160, b: 122),
  ColorData(hex: '#FF7F50', name: 'Coral', r: 255, g: 127, b: 80),
  ColorData(hex: '#FF6347', name: 'Tomato', r: 255, g: 99, b: 71),
  ColorData(hex: '#FF4500', name: 'Orange Red', r: 255, g: 69, b: 0),
  ColorData(hex: '#FF8C00', name: 'Dark Orange', r: 255, g: 140, b: 0),
  ColorData(hex: '#FFA500', name: 'Orange', r: 255, g: 165, b: 0),
  ColorData(hex: '#FFD700', name: 'Gold', r: 255, g: 215, b: 0),
  ColorData(hex: '#FFFF00', name: 'Yellow', r: 255, g: 255, b: 0),
  ColorData(hex: '#FFFFE0', name: 'Light Yellow', r: 255, g: 255, b: 224),
  ColorData(hex: '#FFFACD', name: 'Lemon Chiffon', r: 255, g: 250, b: 205),
  ColorData(hex: '#FAFAD2', name: 'Light Goldenrod Yellow', r: 250, g: 250, b: 210),
  ColorData(hex: '#FFEFD5', name: 'Papaya Whip', r: 255, g: 239, b: 213),
  ColorData(hex: '#FFE4B5', name: 'Moccasin', r: 255, g: 228, b: 181),
  ColorData(hex: '#FFDAB9', name: 'Peach Puff', r: 255, g: 218, b: 185),
  ColorData(hex: '#EEE8AA', name: 'Pale Goldenrod', r: 238, g: 232, b: 170),
  ColorData(hex: '#F0E68C', name: 'Khaki', r: 240, g: 230, b: 140),
  ColorData(hex: '#BDB76B', name: 'Dark Khaki', r: 189, g: 183, b: 107),
  ColorData(hex: '#ADFF2F', name: 'Green Yellow', r: 173, g: 255, b: 47),
  ColorData(hex: '#7FFF00', name: 'Chartreuse', r: 127, g: 255, b: 0),
  ColorData(hex: '#7CFC00', name: 'Lawn Green', r: 124, g: 252, b: 0),
  ColorData(hex: '#00FF00', name: 'Lime', r: 0, g: 255, b: 0),
  ColorData(hex: '#32CD32', name: 'Lime Green', r: 50, g: 205, b: 50),
  ColorData(hex: '#98FB98', name: 'Pale Green', r: 152, g: 251, b: 152),
  ColorData(hex: '#90EE90', name: 'Light Green', r: 144, g: 238, b: 144),
  ColorData(hex: '#00FA9A', name: 'Medium Spring Green', r: 0, g: 250, b: 154),
  ColorData(hex: '#00FF7F', name: 'Spring Green', r: 0, g: 255, b: 127),
  ColorData(hex: '#3CB371', name: 'Medium Sea Green', r: 60, g: 179, b: 113),
  ColorData(hex: '#2E8B57', name: 'Sea Green', r: 46, g: 139, b: 87),
  ColorData(hex: '#228B22', name: 'Forest Green', r: 34, g: 139, b: 34),
  ColorData(hex: '#008000', name: 'Green', r: 0, g: 128, b: 0),
  ColorData(hex: '#006400', name: 'Dark Green', r: 0, g: 100, b: 0),
  ColorData(hex: '#9ACD32', name: 'Yellow Green', r: 154, g: 205, b: 50),
  ColorData(hex: '#6B8E23', name: 'Olive Drab', r: 107, g: 142, b: 35),
  ColorData(hex: '#808000', name: 'Olive', r: 128, g: 128, b: 0),
  ColorData(hex: '#556B2F', name: 'Dark Olive Green', r: 85, g: 107, b: 47),
  ColorData(hex: '#66CDAA', name: 'Medium Aquamarine', r: 102, g: 205, b: 170),
  ColorData(hex: '#8FBC8F', name: 'Dark Sea Green', r: 143, g: 188, b: 143),
  ColorData(hex: '#20B2AA', name: 'Light Sea Green', r: 32, g: 178, b: 170),
  ColorData(hex: '#008B8B', name: 'Dark Cyan', r: 0, g: 139, b: 139),
  ColorData(hex: '#008080', name: 'Teal', r: 0, g: 128, b: 128),
  ColorData(hex: '#00FFFF', name: 'Cyan', r: 0, g: 255, b: 255),
  ColorData(hex: '#E0FFFF', name: 'Light Cyan', r: 224, g: 255, b: 255),
  ColorData(hex: '#AFEEEE', name: 'Pale Turquoise', r: 175, g: 238, b: 238),
  ColorData(hex: '#7FFFD4', name: 'Aquamarine', r: 127, g: 255, b: 212),
  ColorData(hex: '#40E0D0', name: 'Turquoise', r: 64, g: 224, b: 208),
  ColorData(hex: '#48D1CC', name: 'Medium Turquoise', r: 72, g: 209, b: 204),
  ColorData(hex: '#00CED1', name: 'Dark Turquoise', r: 0, g: 206, b: 209),
  ColorData(hex: '#5F9EA0', name: 'Cadet Blue', r: 95, g: 158, b: 160),
  ColorData(hex: '#4682B4', name: 'Steel Blue', r: 70, g: 130, b: 180),
  ColorData(hex: '#B0C4DE', name: 'Light Steel Blue', r: 176, g: 196, b: 222),
  ColorData(hex: '#B0E0E6', name: 'Powder Blue', r: 176, g: 224, b: 230),
  ColorData(hex: '#ADD8E6', name: 'Light Blue', r: 173, g: 216, b: 230),
  ColorData(hex: '#87CEEB', name: 'Sky Blue', r: 135, g: 206, b: 235),
  ColorData(hex: '#87CEFA', name: 'Light Sky Blue', r: 135, g: 206, b: 250),
  ColorData(hex: '#00BFFF', name: 'Deep Sky Blue', r: 0, g: 191, b: 255),
  ColorData(hex: '#1E90FF', name: 'Dodger Blue', r: 30, g: 144, b: 255),
  ColorData(hex: '#6495ED', name: 'Cornflower Blue', r: 100, g: 149, b: 237),
  ColorData(hex: '#7B68EE', name: 'Medium Slate Blue', r: 123, g: 104, b: 238),
  ColorData(hex: '#4169E1', name: 'Royal Blue', r: 65, g: 105, b: 225),
  ColorData(hex: '#0000FF', name: 'Blue', r: 0, g: 0, b: 255),
  ColorData(hex: '#0000CD', name: 'Medium Blue', r: 0, g: 0, b: 205),
  ColorData(hex: '#00008B', name: 'Dark Blue', r: 0, g: 0, b: 139),
  ColorData(hex: '#000080', name: 'Navy', r: 0, g: 0, b: 128),
  ColorData(hex: '#191970', name: 'Midnight Blue', r: 25, g: 25, b: 112),
  ColorData(hex: '#E6E6FA', name: 'Lavender', r: 230, g: 230, b: 250),
  ColorData(hex: '#D8BFD8', name: 'Thistle', r: 216, g: 191, b: 216),
  ColorData(hex: '#DDA0DD', name: 'Plum', r: 221, g: 160, b: 221),
  ColorData(hex: '#EE82EE', name: 'Violet', r: 238, g: 130, b: 238),
  ColorData(hex: '#DA70D6', name: 'Orchid', r: 218, g: 112, b: 214),
  ColorData(hex: '#FF00FF', name: 'Fuchsia', r: 255, g: 0, b: 255),
  ColorData(hex: '#FF00FF', name: 'Magenta', r: 255, g: 0, b: 255),
  ColorData(hex: '#BA55D3', name: 'Medium Orchid', r: 186, g: 85, b: 211),
  ColorData(hex: '#9932CC', name: 'Dark Orchid', r: 153, g: 50, b: 204),
  ColorData(hex: '#9400D3', name: 'Dark Violet', r: 148, g: 0, b: 211),
  ColorData(hex: '#8A2BE2', name: 'Blue Violet', r: 138, g: 43, b: 226),
  ColorData(hex: '#8B008B', name: 'Dark Magenta', r: 139, g: 0, b: 139),
  ColorData(hex: '#800080', name: 'Purple', r: 128, g: 0, b: 128),
  ColorData(hex: '#4B0082', name: 'Indigo', r: 75, g: 0, b: 130),
  ColorData(hex: '#483D8B', name: 'Dark Slate Blue', r: 72, g: 61, b: 139),
  ColorData(hex: '#6A5ACD', name: 'Slate Blue', r: 106, g: 90, b: 205),
  ColorData(hex: '#9370DB', name: 'Medium Purple', r: 147, g: 112, b: 219),
  ColorData(hex: '#BC8F8F', name: 'Rosy Brown', r: 188, g: 143, b: 143),
  ColorData(hex: '#F5F5F5', name: 'White Smoke', r: 245, g: 245, b: 245),
  ColorData(hex: '#DCDCDC', name: 'Gainsboro', r: 220, g: 220, b: 220),
  ColorData(hex: '#D3D3D3', name: 'Light Grey', r: 211, g: 211, b: 211),
  ColorData(hex: '#C0C0C0', name: 'Silver', r: 192, g: 192, b: 192),
  ColorData(hex: '#A9A9A9', name: 'Dark Grey', r: 169, g: 169, b: 169),
  ColorData(hex: '#808080', name: 'Grey', r: 128, g: 128, b: 128),
  ColorData(hex: '#696969', name: 'Dim Grey', r: 105, g: 105, b: 105),
  ColorData(hex: '#778899', name: 'Light Slate Grey', r: 119, g: 136, b: 153),
  ColorData(hex: '#708090', name: 'Slate Grey', r: 112, g: 128, b: 144),
  ColorData(hex: '#2F4F4F', name: 'Dark Slate Grey', r: 47, g: 79, b: 79),
  ColorData(hex: '#000000', name: 'Black', r: 0, g: 0, b: 0),
];

final List<PaletteData> initialPalettes = [
  PaletteData(
    name: 'Zimmer',
    colors: [
      ColorData(hex: '#C0392B', name: 'Crimson', r: 192, g: 57, b: 43),
      ColorData(hex: '#2ECC71', name: 'Emerald', r: 46, g: 204, b: 113),
      ColorData(hex: '#1ABC9C', name: 'Turquoise', r: 26, g: 188, b: 156),
      ColorData(hex: '#F39C12', name: 'Orange', r: 243, g: 156, b: 18),
      ColorData(hex: '#E91E8C', name: 'Pink', r: 233, g: 30, b: 140),
    ],
  ),
  PaletteData(
    name: 'Supernova',
    colors: [
      ColorData(hex: '#FBCE50', name: 'Sunflower', r: 251, g: 206, b: 80),
      ColorData(hex: '#FBAF1A', name: 'Gold', r: 251, g: 175, b: 26),
      ColorData(hex: '#E67E22', name: 'Tangerine', r: 230, g: 126, b: 34),
      ColorData(hex: '#C0392B', name: 'Crimson', r: 192, g: 57, b: 43),
      ColorData(hex: '#8E44AD', name: 'Amethyst', r: 142, g: 68, b: 173),
      ColorData(hex: '#505518', name: 'Forest Shadow', r: 80, g: 85, b: 24),
    ],
  ),
  PaletteData(
    name: 'Mono Studio',
    colors: [
      ColorData(hex: '#0a0a0a', name: 'Void Black', r: 10, g: 10, b: 10),
      ColorData(hex: '#1c1c1c', name: 'Graphite Black', r: 28, g: 28, b: 28),
      ColorData(hex: '#2e2e2e', name: 'Graphite', r: 46, g: 46, b: 46),
      ColorData(hex: '#888888', name: 'Gray', r: 136, g: 136, b: 136),
      ColorData(hex: '#f5f5f0', name: 'White', r: 245, g: 245, b: 240),
    ],
  ),
  PaletteData(
    name: 'Ocean Calm',
    colors: [
      ColorData(hex: '#E1FEE0', name: 'Mint Frost', r: 225, g: 254, b: 224),
      ColorData(hex: '#1ABC9C', name: 'Turquoise', r: 26, g: 188, b: 156),
      ColorData(hex: '#5386C0', name: 'Steel Blue', r: 83, g: 134, b: 192),
      ColorData(hex: '#34495E', name: 'Dark Blue', r: 52, g: 73, b: 94),
    ],
  ),
  PaletteData(
    name: 'Desert Dusk',
    colors: [
      ColorData(hex: '#E9DEC6', name: 'Desert Sand', r: 233, g: 222, b: 198),
      ColorData(hex: '#FBAF1A', name: 'Gold', r: 251, g: 175, b: 26),
      ColorData(hex: '#E67E22', name: 'Tangerine', r: 230, g: 126, b: 34),
      ColorData(hex: '#C0392B', name: 'Crimson', r: 192, g: 57, b: 43),
    ],
  ),
  PaletteData(
    name: 'Nordic Winter',
    colors: [
      ColorData(hex: '#2E3440', name: 'Polar Night', r: 46, g: 52, b: 64),
      ColorData(hex: '#4C566A', name: 'Stormy Gray', r: 76, g: 86, b: 106),
      ColorData(hex: '#88C0D0', name: 'Frost Blue', r: 136, g: 192, b: 208),
      ColorData(hex: '#E5E9F0', name: 'Snow White', r: 229, g: 233, b: 240),
    ],
  ),
  PaletteData(
    name: 'Cyberpunk',
    colors: [
      ColorData(hex: '#FDEE00', name: 'Cyber Yellow', r: 253, g: 238, b: 0),
      ColorData(hex: '#FF003C', name: 'Neon Red', r: 255, g: 0, b: 60),
      ColorData(hex: '#00E5FF', name: 'Cyan Spark', r: 0, g: 229, b: 255),
      ColorData(hex: '#1A1A1A', name: 'Deep Onyx', r: 26, g: 26, b: 26),
    ],
  ),
  PaletteData(
    name: 'Forest Moss',
    colors: [
      ColorData(hex: '#2D3A27', name: 'Deep Forest', r: 45, g: 58, b: 39),
      ColorData(hex: '#4B5D44', name: 'Moss Green', r: 75, g: 93, b: 68),
      ColorData(hex: '#A4AC86', name: 'Sage', r: 164, g: 172, b: 134),
      ColorData(hex: '#C2C5AA', name: 'Parchment', r: 194, g: 197, b: 170),
    ],
  ),
  PaletteData(
    name: 'Retro Sunset',
    colors: [
      ColorData(hex: '#FF5F6D', name: 'Flamingo', r: 255, g: 95, b: 109),
      ColorData(hex: '#FFC371', name: 'Peach', r: 255, g: 195, b: 113),
      ColorData(hex: '#403B4A', name: 'Twilight', r: 64, g: 59, b: 74),
      ColorData(hex: '#E7E9BB', name: 'Pale Sun', r: 231, g: 233, b: 187),
    ],
  ),
  PaletteData(
    name: 'Midnight Ocean',
    colors: [
      ColorData(hex: '#0F2027', name: 'Deep Sea', r: 15, g: 32, b: 39),
      ColorData(hex: '#203A43', name: 'Abyss', r: 32, g: 58, b: 67),
      ColorData(hex: '#2C5364', name: 'Wave', r: 44, g: 83, b: 100),
      ColorData(hex: '#00D2FF', name: 'Surface', r: 0, g: 210, b: 255),
    ],
  ),
  PaletteData(
    name: 'Sakura Bloom',
    colors: [
      ColorData(hex: '#FFE5E5', name: 'Petal', r: 255, g: 229, b: 229),
      ColorData(hex: '#FFB7B2', name: 'Blossom', r: 255, g: 183, b: 178),
      ColorData(hex: '#FF9AA2', name: 'Sakura', r: 255, g: 154, b: 162),
      ColorData(hex: '#E2B0FF', name: 'Lilac', r: 226, g: 176, b: 255),
    ],
  ),
  PaletteData(
    name: 'Autumn Leaves',
    colors: [
      ColorData(hex: '#5D4037', name: 'Bark', r: 93, g: 64, b: 55),
      ColorData(hex: '#D84315', name: 'Rust', r: 216, g: 67, b: 21),
      ColorData(hex: '#FF8F00', name: 'Amber', r: 255, g: 143, b: 0),
      ColorData(hex: '#FFB300', name: 'Gold Leaf', r: 255, g: 179, b: 0),
    ],
  ),
  PaletteData(
    name: 'Lavender Fields',
    colors: [
      ColorData(hex: '#E1BEE7', name: 'Lavender', r: 225, g: 190, b: 231),
      ColorData(hex: '#9575CD', name: 'Purple', r: 149, g: 117, b: 205),
      ColorData(hex: '#673AB7', name: 'Deep Purple', r: 103, g: 58, b: 183),
      ColorData(hex: '#4CAF50', name: 'Stem', r: 76, g: 175, b: 80),
    ],
  ),
  PaletteData(
    name: 'Solar Flare',
    colors: [
      ColorData(hex: '#FFF9C4', name: 'Beam', r: 255, g: 249, b: 196),
      ColorData(hex: '#FFF176', name: 'Sunshine', r: 255, g: 241, b: 118),
      ColorData(hex: '#FFD54F', name: 'Corona', r: 255, g: 213, b: 79),
      ColorData(hex: '#F4511E', name: 'Flare', r: 244, g: 81, b: 30),
    ],
  ),
  PaletteData(
    name: 'Emerald City',
    colors: [
      ColorData(hex: '#E8F5E9', name: 'Glass', r: 232, g: 245, b: 233),
      ColorData(hex: '#4CAF50', name: 'Leaf', r: 76, g: 175, b: 80),
      ColorData(hex: '#2E7D32', name: 'Forest', r: 46, g: 125, b: 50),
      ColorData(hex: '#1B5E20', name: 'Deep Emerald', r: 27, g: 94, b: 32),
    ],
  ),
  PaletteData(
    name: 'Coffee Shop',
    colors: [
      ColorData(hex: '#3E2723', name: 'Espresso', r: 62, g: 39, b: 35),
      ColorData(hex: '#5D4037', name: 'Mocha', r: 93, g: 64, b: 55),
      ColorData(hex: '#A1887F', name: 'Latte', r: 161, g: 136, b: 127),
      ColorData(hex: '#D7CCC8', name: 'Cream', r: 215, g: 204, b: 200),
    ],
  ),
  PaletteData(
    name: 'Candy Shop',
    colors: [
      ColorData(hex: '#F06292', name: 'Bubblegum', r: 240, g: 98, b: 146),
      ColorData(hex: '#BA68C8', name: 'Grape', r: 186, g: 104, b: 200),
      ColorData(hex: '#4FC3F7', name: 'Blueberry', r: 79, g: 195, b: 247),
      ColorData(hex: '#AED581', name: 'Lime', r: 174, g: 213, b: 129),
    ],
  ),
  PaletteData(
    name: 'Slate & Stone',
    colors: [
      ColorData(hex: '#263238', name: 'Obsidian', r: 38, g: 50, b: 56),
      ColorData(hex: '#455A64', name: 'Slate', r: 69, g: 90, b: 100),
      ColorData(hex: '#78909C', name: 'Stone', r: 120, g: 144, b: 156),
      ColorData(hex: '#B0BEC5', name: 'Mist', r: 176, g: 190, b: 197),
    ],
  ),
  PaletteData(
    name: 'Tropical Paradise',
    colors: [
      ColorData(hex: '#00BCD4', name: 'Cyan Sea', r: 0, g: 188, b: 212),
      ColorData(hex: '#CDDC39', name: 'Lime Leaf', r: 205, g: 220, b: 57),
      ColorData(hex: '#FFC107', name: 'Sunlight', r: 255, g: 193, b: 7),
      ColorData(hex: '#FF5722', name: 'Hibiscus', r: 255, g: 87, b: 34),
    ],
  ),
  PaletteData(
    name: 'Moonlight Shadow',
    colors: [
      ColorData(hex: '#1A237E', name: 'Midnight', r: 26, g: 35, b: 126),
      ColorData(hex: '#3F51B5', name: 'Indigo', r: 63, g: 81, b: 181),
      ColorData(hex: '#7986CB', name: 'Moonlight', r: 121, g: 134, b: 203),
      ColorData(hex: '#C5CAE9', name: 'Silver', r: 197, g: 202, b: 233),
    ],
  ),
];

void showToast(BuildContext context, String message, {String? copyText}) {
  if (copyText != null) {
    Clipboard.setData(ClipboardData(text: copyText));
  }
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder:
        (context) =>
            _ToastWidget(message: message, onDismiss: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ToastWidget({required this.message, required this.onDismiss});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 108,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 250),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Color(0x80000000), blurRadius: 30),
              ],
            ),
            child: Text(
              widget.message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PhoneShell extends StatefulWidget {
  const PhoneShell({super.key});

  @override
  State<PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends State<PhoneShell> {
  int _currentIndex = 0;
  ColorData? _selectedColor;
  String _selectedFilter = 'All';
  bool _showDetail = false;
  static const double _tabBarHeight = 86;
  final List<String> _filters = [
    'All',
    'Recent',
    'Favorites',
    'Light',
    'Dark',
    'Warm',
    'Cool',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _showDetail = false;
    });
  }

  void _openDetail(ColorData color) {
    setState(() {
      _selectedColor = color;
      _showDetail = true;
    });
  }

  void _closeDetail() {
    setState(() {
      _showDetail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isCameraTab = !_showDetail && _currentIndex == 2;
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          Column(
            children: [
              if (!isCameraTab) ...[
                SizedBox(height: MediaQuery.of(context).padding.top + 6),
                _buildStatusBar(),
              ],
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        _showDetail || isCameraTab
                            ? 0
                            : _tabBarHeight + bottomInset,
                  ),
                  child:
                      _showDetail && _selectedColor != null
                          ? ColorDetailScreen(
                            color: _selectedColor!,
                            onBack: _closeDetail,
                          )
                          : IndexedStack(
                            index: _currentIndex,
                            children: [
                              ColorsScreen(
                                filters: _filters,
                                selectedFilter: _selectedFilter,
                                onFilterChanged:
                                    (f) => setState(() => _selectedFilter = f),
                                onColorTap: _openDetail,
                                onCameraTap: () => _onTabTapped(2),
                              ),
                              const ExploreScreen(),
                              PickerScreen(onBack: () => _onTabTapped(0)),
                              const PalettesScreen(),
                              const SettingsScreen(),
                            ],
                          ),
                ),
              ),
            ],
          ),
          if (!_showDetail && !isCameraTab) _buildTabBar(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return const SizedBox(height: 10);
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isActive ? AppColors.highlight : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.white),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCamTab() {
    return GestureDetector(
      onTap: () => _onTabTapped(2),
      child: Container(
        width: 54,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33ffffff),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 24),
      ),
    );
  }

  Widget _buildTabBar() {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: _tabBarHeight + bottomInset,
        padding: EdgeInsets.only(bottom: bottomInset + 8),
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(top: BorderSide(color: Color(0xFF1a1a1a), width: 1.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabItem(0, 'Library', Icons.grid_view_rounded),
            const SizedBox(width: 40),
            _buildCamTab(),
            const SizedBox(width: 40),
            _buildTabItem(3, 'Palettes', Icons.palette_outlined),
          ],
        ),
      ),
    );
  }
}

class ColorsScreen extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(ColorData) onColorTap;
  final VoidCallback onCameraTap;

  const ColorsScreen({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onColorTap,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final filteredColors =
        colorLibrary.where((color) {
          switch (selectedFilter) {
            case 'Favorites':
              return state.isFavorite(color);
            case 'Light':
              return (color.r + color.g + color.b) / 3 > 160;
            case 'Dark':
              return (color.r + color.g + color.b) / 3 < 80;
            case 'Warm':
              return color.r > color.b;
            case 'Cool':
              return color.b >= color.r;
            default:
              return true;
          }
        }).toList();
    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Colors',
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Row(
                    children: [
                      _IconBtn(Icons.search, () => _showSearchSheet(context)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StatCard('${colorLibrary.length}', ''),
                  const SizedBox(width: 8),
                  _StatCard('${AppStateScope.of(context).palettes.length}', ''),
                  const SizedBox(width: 8),
                  _StatCard(
                    '${AppStateScope.of(context).favorites.length}',
                    '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isActive = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => onFilterChanged(filter),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            filter,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight:
                                  isActive ? FontWeight.w800 : FontWeight.w500,
                              color: isActive ? AppColors.white : Colors.white54,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 20,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: GridView.builder(
                  key: ValueKey(selectedFilter),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: filteredColors.length,
                  itemBuilder: (context, index) {
                    final color = filteredColors[index];
                    return _ColorCard(
                      color: color,
                      onTap: () => onColorTap(color),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final results =
                colorLibrary
                    .where(
                      (c) =>
                          c.name.toLowerCase().contains(query.toLowerCase()) ||
                          c.hex.toLowerCase().contains(query.toLowerCase()),
                    )
                    .toList();
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: const BoxDecoration(
                color: AppColors.offBlack,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Search Colors',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setModalState(() => query = value),
                    style: GoogleFonts.inter(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search by name or hex',
                      hintStyle: GoogleFonts.inter(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: AppColors.dark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final color = results[index];
                        return ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            onColorTap(color);
                          },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.color,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                          ),
                          title: Text(
                            color.name,
                            style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            color.hex,
                            style: GoogleFonts.inter(
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: AppColors.dark,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 15, color: AppColors.white),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String num;
  final String label;
  const _StatCard(this.num, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            num,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorCard extends StatelessWidget {
  final ColorData color;
  final VoidCallback onTap;
  const _ColorCard({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.color,
          borderRadius: BorderRadius.circular(22),
          border:
              color.hex == '#0F0F0F'
                  ? Border.all(color: AppColors.border, width: 2)
                  : null,
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 14,
              left: 14,
              child: Text(
                color.hex,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color:
                      (color.r + color.g + color.b) / 3 > 128
                          ? Colors.black54
                          : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.offBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sort & Filter',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sort By',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.muted2,
            ),
          ),
          const SizedBox(height: 8),
          _SortOption('Date Added', selected: true),
          _SortOption('Name A–Z'),
          _SortOption('Hue'),
          _SortOption('Brightness'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MainButton('Apply', () => Navigator.pop(context)),
              ),
              const SizedBox(width: 8),
              _GhostButton('Cancel', () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool selected;
  const _SortOption(this.label, {this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: selected ? AppColors.highlight2 : Colors.transparent,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const Spacer(),
          if (selected) Icon(Icons.check, color: AppColors.white, size: 16),
        ],
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MainButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryResultScreen extends StatefulWidget {
  final Uint8List imageBytes;
  const GalleryResultScreen({super.key, required this.imageBytes});

  @override
  State<GalleryResultScreen> createState() => _GalleryResultScreenState();
}

class _GalleryResultScreenState extends State<GalleryResultScreen> {
  List<ColorData> _palette = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractPalette();
  }

  Future<void> _extractPalette() async {
    final decoded = await compute(img.decodeImage, widget.imageBytes);
    if (decoded == null) return;

    // Extract a 3x3 grid of samples for variety
    final List<ColorData> colors = [];
    final stepX = decoded.width ~/ 4;
    final stepY = decoded.height ~/ 4;

    for (int y = 1; y <= 3; y++) {
      for (int x = 1; x <= 3; x++) {
        final px = decoded.getPixel(x * stepX, y * stepY);
        final r = px.r.toInt();
        final g = px.g.toInt();
        final b = px.b.toInt();
        final hex =
            '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
                .toUpperCase();

        // Find nearest name using the same logic as camera
        var bestName = 'Sampled';
        var bestDistance = double.infinity;
        for (final libColor in colorLibrary) {
          final dr = r - libColor.r;
          final dg = g - libColor.g;
          final db = b - libColor.b;
          final distance = (dr * dr + dg * dg + db * db).toDouble();
          if (distance < bestDistance) {
            bestDistance = distance;
            bestName = libColor.name;
          }
        }

        colors.add(ColorData(hex: hex, name: bestName, r: r, g: g, b: b));
      }
    }

    if (mounted) {
      setState(() {
        _palette = colors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Image Palette',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            'EXTRACTED COLORS',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: _palette.length,
                            itemBuilder: (context, index) {
                              final color = _palette[index];
                              return GestureDetector(
                                onTap:
                                    () => showToast(
                                      context,
                                      'Copied ${color.hex}',
                                      copyText: color.hex,
                                    ),
                                child: Container(
                                  width: 140,
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.dark,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: color.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        color.hex,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        color.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Discover Colors',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              _IconBtn(Icons.search, () => _showExploreSearch(context)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _ColorOfDay(),
              const SizedBox(height: 20),
              _SectionHeader(
                'Trending Palettes',
                'See All →',
                onTap: () => showToast(context, 'Trending palettes'),
              ),
              const SizedBox(height: 10),
              _TrendingRow(),
              const SizedBox(height: 20),
              _SectionHeader(
                'Recent Colors',
                'See All →',
                onTap: () => showToast(context, 'Recent colors'),
              ),
              const SizedBox(height: 10),
              _RecentColors(),
              const SizedBox(height: 12),
              _WatchBanner(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColorOfDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final color = colorLibrary.first;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [Color(0xFF0a0a0a), Color(0xFF2e2e2e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Text(
                    'Obsidian Night',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#1C1C1C',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color of the Day',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '#1C1C1C',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _IconBtn(
                      state.isFavorite(color)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      () {
                        state.toggleFavorite(color);
                        showToast(
                          context,
                          state.isFavorite(color) ? 'Saved!' : 'Removed',
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    _IconBtn(Icons.share, () {
                      Share.share('Check out this color: ${color.name} (${color.hex})');
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showExploreSearch(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      String query = '';
      return StatefulBuilder(
        builder: (context, setModalState) {
          final results =
              colorLibrary
                  .where(
                    (c) =>
                        c.name.toLowerCase().contains(query.toLowerCase()) ||
                        c.hex.toLowerCase().contains(query.toLowerCase()),
                  )
                  .toList();
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.offBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Explore Search',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => setModalState(() => query = value),
                  style: GoogleFonts.inter(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search palettes or colors',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.dark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final color = results[index];
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          showToast(context, '${color.name} opened');
                        },
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                        ),
                        title: Text(
                          color.name,
                          style: GoogleFonts.inter(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          color.hex,
                          style: GoogleFonts.inter(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SectionHeader extends StatelessWidget {
  final String title, action;
  final VoidCallback? onTap;
  const _SectionHeader(this.title, this.action, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _TrendCard('Monochrome', '2.1k', [
            const Color(0xFF111),
            const Color(0xFF333),
            const Color(0xFF666),
            const Color(0xFFccc),
          ], onTap: () => showToast(context, 'Monochrome opened')),
          _TrendCard(
            'Sunset Fade',
            '1.8k',
            [
              const Color(0xFFC0392B),
              const Color(0xFFE67E22),
              const Color(0xFFFBCE50),
            ],
            onTap: () => showToast(context, 'Sunset Fade opened'),
          ),
          _TrendCard('Deep Ocean', '1.4k', [
            const Color(0xFF0d2240),
            const Color(0xFF5386C0),
            const Color(0xFFc2d8f0),
          ], onTap: () => showToast(context, 'Deep Ocean opened')),
          _TrendCard('Botanical', '980', [
            const Color(0xFF505518),
            const Color(0xFF2ECC71),
            const Color(0xFFE1FEE0),
          ], onTap: () => showToast(context, 'Botanical opened')),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String name, count;
  final List<Color> colors;
  final VoidCallback? onTap;
  const _TrendCard(this.name, this.count, this.colors, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children:
                    colors
                        .map((c) => Expanded(child: Container(color: c)))
                        .toList(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.dark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    '$count saves',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentColors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          colorLibrary
              .take(7)
              .map(
                (c) => Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _WatchBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showToast(context, 'Watch app details'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Text('⌚', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apple Watch App',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Access your colors on your wrist',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class PickerScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const PickerScreen({super.key, this.onBack});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen>
    with WidgetsBindingObserver {
  static const Duration _detectionInterval = Duration(milliseconds: 60);
  static const int _detectionRadius = 4;
  static const int _detectionStep = 4;

  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final ImagePicker _imagePicker = ImagePicker();
  bool _flashEnabled = false;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  ColorData? _detectedColor;
  int _controllerEpoch = 0;
  int _activeControllerEpoch = 0;
  double? _smoothedR;
  double? _smoothedG;
  double? _smoothedB;
  Offset _samplePoint = const Offset(0.5, 0.5);
  DateTime _lastSample = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _snapBackTimer;
  bool _isProcessingFrame = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    if (appCameras.isEmpty) return;
    final description = appCameras.first;
    final formatGroup =
        defaultTargetPlatform == TargetPlatform.iOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420;
    final preset = ResolutionPreset.medium;
    final controller = CameraController(
      description,
      preset,
      imageFormatGroup: formatGroup,
      enableAudio: false,
    );
    _controllerEpoch += 1;
    final epoch = _controllerEpoch;
    _controller = controller;
    _initializeControllerFuture = controller.initialize().then((_) async {
      if (!mounted || epoch != _controllerEpoch) return;
      _minZoom = await controller.getMinZoomLevel();
      _maxZoom = await controller.getMaxZoomLevel();
      await _setZoomLevel(1.0);
      if (!controller.value.isStreamingImages) {
        await controller.startImageStream(_onCameraImage);
      }
      await _stabilizeCameraControls(controller);
      _activeControllerEpoch = epoch;
      if (!mounted) return;
      setState(() {});
    });
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _disposeCamera() async {
    _snapBackTimer?.cancel();
    final controller = _controller;
    _controller = null;
    _activeControllerEpoch = 0;
    if (controller?.value.isStreamingImages ?? false) {
      await controller?.stopImageStream();
    }
    await controller?.dispose();
  }

  Future<void> _stabilizeCameraControls(CameraController controller) async {
    try {
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setFocusMode(FocusMode.auto);
    } catch (error) {
      debugPrint('Camera control stabilization skipped: $error');
    }
  }

  Future<void> _setZoomLevel(double value) async {
    final target = value.clamp(_minZoom, _maxZoom);
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.setZoomLevel(target);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _flashEnabled = !_flashEnabled;
    try {
      await _controller!.setFlashMode(
        _flashEnabled ? FlashMode.torch : FlashMode.off,
      );
    } catch (_) {
      _flashEnabled = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      if (!mounted) return;

      final bytes = await picked.readAsBytes();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GalleryResultScreen(imageBytes: bytes),
        ),
      );
    } catch (e) {
      showToast(context, 'Permission denied or error: $e');
    }
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_isProcessingFrame || !mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastSample) < _detectionInterval) return;
    _lastSample = now;
    _isProcessingFrame = true;
    try {
      final color = _sampleCameraColor(image);
      if (color != null && mounted) {
        setState(() => _detectedColor = color);
      }
    } catch (e) {
      debugPrint('Error sampling color: $e');
    } finally {
      _isProcessingFrame = false;
    }
  }

  ColorData? _sampleCameraColor(CameraImage image) {
    if (image.planes.isEmpty) return null;
    final framePoint = _framePointFromPreview(image);
    final centerX = framePoint.dx.clamp(0.0, image.width - 1.0).toInt();
    final centerY = framePoint.dy.clamp(0.0, image.height - 1.0).toInt();
    final radius = _detectionRadius;
    final step = _detectionStep;
    var totalR = 0;
    var totalG = 0;
    var totalB = 0;
    var count = 0;

    for (var y = centerY - radius; y <= centerY + radius; y += step) {
      if (y < 0 || y >= image.height) continue;
      for (var x = centerX - radius; x <= centerX + radius; x += step) {
        if (x < 0 || x >= image.width) continue;
        final rgb =
            image.planes.length == 1
                ? _rgbFromBgra(image, x, y)
                : _rgbFromYuv(image, x, y);
        totalR += rgb.$1;
        totalG += rgb.$2;
        totalB += rgb.$3;
        count += 1;
      }
    }

    if (count == 0) return null;
    final rawR = totalR / count;
    final rawG = totalG / count;
    final rawB = totalB / count;

    // Increased smoothing (85% previous, 15% new) for color stability
    _smoothedR = _smoothedR == null ? rawR : _smoothedR! * 0.85 + rawR * 0.15;
    _smoothedG = _smoothedG == null ? rawG : _smoothedG! * 0.85 + rawG * 0.15;
    _smoothedB = _smoothedB == null ? rawB : _smoothedB! * 0.85 + rawB * 0.15;

    return _colorFromRgb(
      _smoothedR!.round(),
      _smoothedG!.round(),
      _smoothedB!.round(),
    );
  }

  int _clampInt(int value) => value.clamp(0, 255).toInt();

  (int, int, int) _rgbFromBgra(CameraImage image, int x, int y) {
    final plane = image.planes[0];
    final bytesPerPixel = plane.bytesPerPixel ?? 4;
    final index = y * plane.bytesPerRow + x * bytesPerPixel;
    if (index + 2 >= plane.bytes.length) {
      return (0, 0, 0);
    }
    final b = plane.bytes[index];
    final g = plane.bytes[index + 1];
    final r = plane.bytes[index + 2];
    return (r, g, b);
  }

  Offset _framePointFromPreview(CameraImage image) {
    final camera = _controller?.description;
    if (camera == null) return Offset(image.width / 2, image.height / 2);

    final lensDirection = camera.lensDirection;
    final sensorOrientation = camera.sensorOrientation;
    var x = _samplePoint.dx;
    var y = _samplePoint.dy;

    // Correct for front camera if needed
    if (lensDirection == CameraLensDirection.front) {
      x = 1 - x;
    }

    // Android/iOS typical mapping:
    // Sensor frame is usually in landscape orientation (e.g. 1920x1080)
    // 90/270 represents the physical sensor orientation relative to the device.
    switch (sensorOrientation) {
      case 90:
        return Offset(y * image.width, (1 - x) * image.height);
      case 270:
        return Offset((1 - y) * image.width, x * image.height);
      case 180:
        return Offset((1 - x) * image.width, (1 - y) * image.height);
      case 0:
      default:
        return Offset(x * image.width, y * image.height);
    }
  }

  (int, int, int) _rgbFromYuv(CameraImage image, int x, int y) {
    final planeY = image.planes[0];
    final planeU = image.planes[1];
    final planeV = image.planes[2];
    final yIndex = y * planeY.bytesPerRow + x;
    final uvRow = (y / 2).floor();
    final uvCol = (x / 2).floor();
    final uvPixelStride = planeU.bytesPerPixel ?? 1;
    final uvIndex = uvRow * planeU.bytesPerRow + uvCol * uvPixelStride;
    final yp = planeY.bytes[yIndex];
    final up = planeU.bytes[uvIndex];
    final vp = planeV.bytes[uvIndex];
    final r = _clampInt((yp + 1.402 * (vp - 128)).round());
    final g = _clampInt(
      (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round(),
    );
    final b = _clampInt((yp + 1.772 * (up - 128)).round());
    return (r, g, b);
  }

  ColorData _colorFromRgb(int r, int g, int b) {
    final hex =
        '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'
            .toUpperCase();
    final name = _nearestColorName(r, g, b);
    return ColorData(hex: hex, name: name, r: r, g: g, b: b);
  }

  String _nearestColorName(int r, int g, int b) {
    var bestName = 'Captured';
    var bestDistance = double.infinity;
    for (final color in colorLibrary) {
      final dr = r - color.r;
      final dg = g - color.g;
      final db = b - color.b;
      final distance = (dr * dr + dg * dg + db * db).toDouble();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestName = color.name;
      }
    }
    return bestName;
  }

  @override
  Widget build(BuildContext context) {
    final color = _detectedColor ?? colorLibrary.first;
    final topInset = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final previewRect = _previewRectForSize(constraints.biggest);
              return GestureDetector(
                onTapDown:
                    (details) =>
                        _handlePreviewTap(details.localPosition, previewRect),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        tween: Tween(begin: 0.95, end: 1.0),
                        builder: (context, scale, child) {
                          return Opacity(
                            opacity: ((scale - 0.95) / 0.05).clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: scale,
                              child: _buildCameraPreview(previewRect),
                            ),
                          );
                        },
                      ),
                    ),
                    _buildReticle(color, previewRect),
                    _buildLiveColorBadge(color, previewRect, topInset),
                    Positioned(
                      top: topInset + 8,
                      left: 16,
                      child: _buildMiniAction(
                        icon: Icons.close_rounded,
                        onTap: widget.onBack ?? () {},
                      ),
                    ),
                    Positioned(
                      top: topInset + 8,
                      left: 0,
                      right: 0,
                      child: Center(child: _buildTopPill()),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: bottomInset + 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniAction(
                              icon: Icons.image_outlined,
                              onTap: _pickFromGallery,
                            ),
                            _buildShutterButton(),
                            _buildMiniAction(
                              icon:
                                  _flashEnabled
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                              onTap: _toggleFlash,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handlePreviewTap(Offset localPosition, Rect previewRect) {
    if (!previewRect.contains(localPosition)) return;
    final previewPoint = Offset(
      ((localPosition.dx - previewRect.left) / previewRect.width).clamp(
        0.0,
        1.0,
      ),
      ((localPosition.dy - previewRect.top) / previewRect.height).clamp(
        0.0,
        1.0,
      ),
    );
    setState(() => _samplePoint = previewPoint);
    _snapBackTimer?.cancel();
    _snapBackTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _samplePoint = const Offset(0.5, 0.5));
    });
  }

  Rect _previewRectForSize(Size viewportSize) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Offset.zero & viewportSize;
    }

    // Camera aspect ratio is often reported as width/height in landscape (e.g., 4/3)
    // For a portrait preview, we need the inverse (e.g., 3/4)
    final cameraAspect = _controller!.value.aspectRatio;
    final portraitAspect = 1 / cameraAspect;
    final viewportAspect = viewportSize.width / viewportSize.height;

    late double contentWidth;
    late double contentHeight;

    if (portraitAspect > viewportAspect) {
      // Camera is wider than viewport (relative to height)
      contentHeight = viewportSize.height;
      contentWidth = contentHeight * portraitAspect;
    } else {
      // Camera is taller than viewport (relative to width)
      contentWidth = viewportSize.width;
      contentHeight = contentWidth / portraitAspect;
    }

    return Rect.fromCenter(
      center: viewportSize.center(Offset.zero),
      width: contentWidth,
      height: contentHeight,
    );
  }

  Widget _buildCameraPreview(Rect previewRect) {
    if (_controller == null) {
      return _buildCameraFallback('Camera unavailable');
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (_activeControllerEpoch == 0 ||
            _controller == null ||
            !_controller!.value.isInitialized ||
            _activeControllerEpoch != _controllerEpoch) {
          return _buildCameraFallback('Camera unavailable');
        }
        if (snapshot.hasError) {
          return _buildCameraFallback('Camera permission denied');
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.white),
          );
        }

        final preview = _controller!;
        return ClipRect(
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: previewRect,
                child: CameraPreview(preview),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraFallback(String message) {
    return Container(
      color: const Color(0xFF0A0A0A),
      alignment: Alignment.center,
      child: Text(
        message,
        style: GoogleFonts.inter(
          color: AppColors.offWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTopPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            'Litur',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReticle(ColorData color, Rect previewRect) {
    return Positioned(
      left: previewRect.left + (_samplePoint.dx * previewRect.width) - 24,
      top: previewRect.top + (_samplePoint.dy * previewRect.height) - 24,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center ring showing the color
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.color.withValues(alpha: 0.8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            // Precision dot
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveColorBadge(
    ColorData color,
    Rect previewRect,
    double topInset,
  ) {
    const badgeWidth = 120.0;
    const badgeHeight = 36.0;
    final screenSize = MediaQuery.of(context).size;
    final anchorX = previewRect.left + (_samplePoint.dx * previewRect.width);
    final anchorY = previewRect.top + (_samplePoint.dy * previewRect.height);
    final left = (anchorX + 32).clamp(16.0, screenSize.width - badgeWidth - 16);
    final top = (anchorY + 20).clamp(topInset + 80, screenSize.height - 240);
    return Positioned(
      left: left,
      top: top,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: badgeHeight,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: color.color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  color.hex,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap:
                      () => showToast(
                        context,
                        'Copied ${color.hex}',
                        copyText: color.hex,
                      ),
                  child: const Icon(
                    Icons.copy,
                    size: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: _saveCurrentColor,
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.5),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.95),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, size: 22, color: AppColors.white),
          ),
        ),
      ),
    );
  }

  void _saveCurrentColor() {
    final color = _detectedColor;
    if (color == null) {
      showToast(context, 'Color not ready');
      return;
    }
    final state = AppStateScope.of(context);
    if (!state.isFavorite(color)) {
      state.toggleFavorite(color);
    }
    showToast(context, '${color.hex} saved', copyText: color.hex);
  }
}

class _AnimatedBlob extends StatefulWidget {
  final double width, height;
  final Color color;
  final int delay;
  const _AnimatedBlob(this.width, this.height, this.color, this.delay);

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale, _translate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _translate = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(seconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(_translate.value, -_translate.value),
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.5),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

class PalettesScreen extends StatefulWidget {
  const PalettesScreen({super.key});

  @override
  State<PalettesScreen> createState() => _PalettesScreenState();
}

class _PalettesScreenState extends State<PalettesScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final palettes = state.palettes;
    return Column(
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Palettes',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Collections',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _IconBtn(
                    Icons.search,
                    () => showToast(context, 'Search palettes'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children:
                ['All', 'Custom', 'Generated', 'Shared']
                    .map(
                      (f) => GestureDetector(
                        onTap: () => setState(() => _selectedFilter = f),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                f,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight:
                                      f == _selectedFilter
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                  color:
                                      f == _selectedFilter
                                          ? AppColors.white
                                          : Colors.white54,
                                ),
                              ),
                            ),
                            if (f == _selectedFilter)
                              Container(
                                margin: const EdgeInsets.only(right: 16),
                                width: 20,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: ListView.builder(
              key: ValueKey(_selectedFilter),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: palettes.length,
              itemBuilder: (context, index) {
                final palette = palettes[index];
                return _PaletteCard(
                  palette: palette,
                  onCopy: () => showToast(context, '${palette.name} copied!'),
                  onShare: () {
                    final content = 'Palette: ${palette.name}\n${palette.colors.map((c) => c.hex).join(', ')}';
                    Share.share(content);
                  },
                  onDelete: () {
                    state.deletePalette(palette);
                    showToast(context, '${palette.name} deleted');
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showNewPaletteDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.offBlack,
            title: Text(
              'New Palette',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: TextField(
              controller: controller,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Palette name',
                hintStyle: GoogleFonts.inter(color: AppColors.muted),
                filled: true,
                fillColor: AppColors.dark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: AppColors.muted),
                ),
              ),
              TextButton(
                onPressed: () {
                  state.addPalette(controller.text);
                  Navigator.pop(context);
                  showToast(context, 'Palette created');
                },
                child: Text(
                  'Create',
                  style: GoogleFonts.inter(color: AppColors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final PaletteData palette;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  const _PaletteCard({
    required this.palette,
    required this.onCopy,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children:
                  palette.colors.isEmpty
                      ? [
                        Expanded(
                          child: Container(
                            color: AppColors.mid,
                            child: Center(
                              child: Text(
                                'Empty',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]
                      : palette.colors
                          .map(
                            (c) => Expanded(child: Container(color: c.color)),
                          )
                          .toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  palette.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${palette.colors.length} colors',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.muted,
                  ),
                ),
                const Spacer(),
                _IconBtn(Icons.copy, onCopy),
                const SizedBox(width: 4),
                _IconBtn(Icons.share, onShare),
                const SizedBox(width: 4),
                _IconBtn(Icons.delete_outline, onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Column(
      children: [
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Preferences',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _ProfileCard(),
              _SettingsSection('Appearance', [
                _SettingsRow(
                  Icons.palette_outlined,
                  'Theme',
                  'Dark',
                  onTap: () => showToast(context, 'Theme settings'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.grid_view,
                  'Grid Layout',
                  '3 col',
                  onTap: () => showToast(context, 'Grid settings'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.visibility,
                  'Show Names',
                  '',
                  toggle: true,
                  toggleValue: state.settings['showNames'] ?? true,
                  onToggle: (value) => state.toggleSetting('showNames'),
                ),
              ]),
              _SettingsSection('Color Codes', [
                _SettingsRow(
                  Icons.text_fields,
                  'Copy Format',
                  'HEX',
                  onTap: () => showToast(context, 'Copy format set to HEX'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.auto_awesome,
                  'Auto-detect Names',
                  '',
                  toggle: true,
                  toggleValue: state.settings['autoDetectNames'] ?? true,
                  onToggle: (value) => state.toggleSetting('autoDetectNames'),
                ),
                _SettingsRow(
                  Icons.vibration,
                  'Haptic Feedback',
                  '',
                  toggle: true,
                  toggleValue: state.settings['haptics'] ?? false,
                  onToggle: (value) => state.toggleSetting('haptics'),
                ),
              ]),
              _SettingsSection('Sync & Backup', [
                _SettingsRow(
                  Icons.cloud,
                  'iCloud Sync',
                  '',
                  toggle: true,
                  toggleValue: state.settings['icloudSync'] ?? true,
                  onToggle: (value) => state.toggleSetting('icloudSync'),
                ),
                _SettingsRow(
                  Icons.sync,
                  'Sync Now',
                  state.syncStatus,
                  onTap: () {
                    state.syncNow();
                    showToast(context, 'Synced');
                  },
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.download,
                  'Export Backup',
                  '',
                  onTap: () => showToast(context, 'Backup exported'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.upload,
                  'Import Colors',
                  '',
                  onTap: () => showToast(context, 'Import started'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
              ]),
              _SettingsSection('About', [
                _SettingsRow(
                  Icons.language,
                  'Developer Website',
                  '',
                  onTap: () => showToast(context, 'Opening website'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.security,
                  'Privacy Policy',
                  '',
                  onTap: () => showToast(context, 'Opening privacy policy'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.mail_outline,
                  'Send Feedback',
                  '',
                  onTap: () => showToast(context, 'Feedback form opened'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.star,
                  'Rate Litur',
                  '',
                  onTap: () => showToast(context, 'Thanks for the rating!'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(
                  Icons.delete_outline,
                  'Clear All Colors',
                  '',
                  danger: true,
                  onTap: () => showToast(context, 'All colors cleared'),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                ),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.mid,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Center(
              child: Text(
                'L',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Litur Pro',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  '${colorLibrary.length} colors · ${state.palettes.length} palettes',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.mid,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'v20.0',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppColors.muted2,
            height: 2,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.dark,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool toggle;
  final bool danger;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  const _SettingsRow(
    this.icon,
    this.label,
    this.value, {
    this.trailing,
    this.toggle = false,
    this.danger = false,
    this.toggleValue,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = toggleValue ?? false;
    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (!toggle) {
              showToast(context, '$label tapped');
            }
          },
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 15,
                color: danger ? Colors.redAccent : AppColors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: danger ? Colors.redAccent : AppColors.white,
                ),
              ),
            ),
            if (toggle)
              GestureDetector(
                onTap: () => onToggle?.call(!enabled),
                child: Container(
                  width: 42,
                  height: 24,
                  decoration: BoxDecoration(
                    color: enabled ? AppColors.offWhite : const Color(0xFF333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment:
                        enabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: enabled ? Colors.black : const Color(0xFF888),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              )
            else if (value != null && value!.isNotEmpty)
              Text(
                value!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                ),
              )
            else
              trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class ColorDetailScreen extends StatelessWidget {
  final ColorData color;
  final VoidCallback onBack;
  const ColorDetailScreen({
    super.key,
    required this.color,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return Column(
      children: [
        Container(
          height: 200,
          color: color.color,
          child: Stack(
            children: [
              Positioned(
                top: 14,
                left: 14,
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Row(
                  children: [
                    _CircleBtn(
                      state.isFavorite(color)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      onTap: () {
                        state.toggleFavorite(color);
                        showToast(
                          context,
                          state.isFavorite(color)
                              ? 'Added to favorites'
                              : 'Removed from favorites',
                        );
                      },
                    ),
                    _CircleBtn(
                      Icons.edit,
                      onTap: () => _showRenameDialog(context, state),
                    ),
                    _CircleBtn(
                      Icons.share,
                      onTap: () => Share.share(
                        'Color: ${state.displayName(color)} (${color.hex})',
                      ),
                    ),
                    _CircleBtn(
                      Icons.delete,
                      danger: true,
                      onTap: () => showToast(context, 'Color removed'),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 14,
                left: 14,
                child: Text(
                  state.displayName(color),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle('Color Codes — tap to copy'),
              _CodeGrid(color: color),
              const SizedBox(height: 16),
              _SectionTitle('Edit Color'),
              _SliderRow('R', color.r),
              _SliderRow('G', color.g),
              _SliderRow('B', color.b),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MainButton(
                      'Apply Changes',
                      () => showToast(context, 'Changes applied'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GhostButton('Reset', () => showToast(context, 'Reset')),
                ],
              ),
              const SizedBox(height: 16),
              _SectionTitle('Color Combinations'),
              _CombinationsRow(color: color),
              const SizedBox(height: 16),
              _SectionTitle('Contrast Checker'),
              _ContrastCard('vs. White', '3.2:1', false),
              _ContrastCard('vs. Black', '6.5:1', true),
              _ContrastCard('vs. Off-white', '3.0:1', false),
              const SizedBox(height: 16),
              _SectionTitle('Generated Palette'),
              _PaletteRow(color: color),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MainButton(
                      'Share Palette',
                      () {
                        final colorValue = color.color;
                        String toHex(Color c) => '#${c.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
                        
                        final palette = [
                          toHex(Color.lerp(colorValue, Colors.black, 0.5)!),
                          toHex(Color.lerp(colorValue, Colors.black, 0.3)!),
                          toHex(colorValue),
                          toHex(Color.lerp(colorValue, Colors.white, 0.5)!),
                          toHex(Color.lerp(colorValue, Colors.white, 0.7)!),
                        ];

                        final content = 'Generated Palette for ${state.displayName(color)} (${color.hex}):\n'
                            '${palette.join(', ')}';
                        Share.share(content);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GhostButton(
                    'Save',
                    () => showToast(context, 'Palette saved'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionTitle('Add to Palette'),
              _PaletteTags(
                selected: state.selectedPaletteName,
                onSelect: state.setSelectedPaletteName,
              ),
              const SizedBox(height: 12),
              _MainButton('Confirm', () {
                if (state.selectedPaletteName.isEmpty) {
                  showToast(context, 'Create a palette first');
                  return;
                }
                state.addColorToPalette(state.selectedPaletteName, color);
                showToast(context, 'Added to ${state.selectedPaletteName}');
              }),
            ],
          ),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, AppState state) {
    final controller = TextEditingController(text: state.displayName(color));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.offBlack,
          title: Text(
            'Rename Color',
            style: GoogleFonts.inter(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'New name',
              hintStyle: GoogleFonts.inter(color: AppColors.muted),
              filled: true,
              fillColor: AppColors.dark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.muted),
              ),
            ),
            TextButton(
              onPressed: () {
                state.renameColor(color, controller.text);
                Navigator.pop(context);
                showToast(context, 'Color renamed');
              },
              child: Text(
                'Save',
                style: GoogleFonts.inter(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool danger;
  final VoidCallback? onTap;
  const _CircleBtn(this.icon, {this.danger = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(left: 6),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(
          icon,
          color: danger ? Colors.redAccent : Colors.white,
          size: 15,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _CodeGrid extends StatelessWidget {
  final ColorData color;
  const _CodeGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.5,
      children: [
        _CodeBlock('HEX', color.hex),
        _CodeBlock('RGB', '${color.r}, ${color.g}, ${color.b}'),
        _CodeBlock('HSB', color.hsb),
        _CodeBlock('CMYK', color.cmyk),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String label, value;
  const _CodeBlock(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showToast(context, '$label copied!', copyText: value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dark,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.white),
            ),
            Text(
              'Tap to copy',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.muted2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  const _SliderRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.mid,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.muted,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _CombinationsRow extends StatelessWidget {
  final ColorData color;
  const _CombinationsRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ComboCard('Complementary', [
            Color.lerp(color.color, Colors.orange, 0.5) ?? Colors.orange,
            color.color,
          ]),
          _ComboCard('Analogous', [
            color.color,
            Color.lerp(color.color, Colors.blue, 0.1) ?? Colors.blue,
            Color.lerp(color.color, Colors.purple, 0.1) ?? Colors.purple,
          ]),
          _ComboCard('Mono', [
            Color.lerp(color.color, Colors.black, 0.5) ?? Colors.black,
            color.color,
            Color.lerp(color.color, Colors.white, 0.5) ?? Colors.white,
          ]),
          _ComboCard('Triadic', [color.color, Colors.pink, Colors.green]),
          _ComboCard('Tetradic', [
            color.color,
            Colors.orange,
            Colors.green,
            Colors.pink,
          ]),
        ],
      ),
    );
  }
}

class _ComboCard extends StatelessWidget {
  final String label;
  final List<Color> colors;
  const _ComboCard(this.label, this.colors);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Row(
              children:
                  colors
                      .map((c) => Expanded(child: Container(color: c)))
                      .toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            color: AppColors.dark,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContrastCard extends StatelessWidget {
  final String label, ratio;
  final bool pass;
  const _ContrastCard(this.label, this.ratio, this.pass);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dark,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFddd)),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  ratio,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: pass ? const Color(0x1A7fff9a) : const Color(0x0FFF6B6B),
              border: Border.all(
                color: pass ? const Color(0x337fff9a) : const Color(0x33ff6b6b),
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              pass ? 'PASS' : 'FAIL',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: pass ? const Color(0xFF7fff9a) : const Color(0xFFff6b6b),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final ColorData color;
  const _PaletteRow({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Color.lerp(color.color, Colors.black, 0.5),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 48,
            color: Color.lerp(color.color, Colors.black, 0.3),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: color.color,
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 48,
            color: Color.lerp(color.color, Colors.white, 0.5),
          ),
        ),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Color.lerp(color.color, Colors.white, 0.7),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaletteTags extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _PaletteTags({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final tags = state.palettes.map((p) => p.name).toList();
    tags.add('+ New');
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          tags
              .map(
                (t) => GestureDetector(
                  onTap: () {
                    if (t == '+ New') {
                      _showNewPaletteDialog(context, state);
                      return;
                    }
                    onSelect(t);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: t == selected ? AppColors.white : AppColors.dark,
                      border: Border.all(
                        color:
                            t == selected ? AppColors.white : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            t == selected ? AppColors.black : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  void _showNewPaletteDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.offBlack,
            title: Text(
              'New Palette',
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: TextField(
              controller: controller,
              style: GoogleFonts.inter(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Palette name',
                hintStyle: GoogleFonts.inter(color: AppColors.muted),
                filled: true,
                fillColor: AppColors.dark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: AppColors.muted),
                ),
              ),
              TextButton(
                onPressed: () {
                  state.addPalette(controller.text);
                  Navigator.pop(context);
                  showToast(context, 'Palette created');
                },
                child: Text(
                  'Create',
                  style: GoogleFonts.inter(color: AppColors.white),
                ),
              ),
            ],
          ),
    );
  }
}
