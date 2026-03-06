import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const LiturApp());
}

class LiturApp extends StatelessWidget {
  const LiturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      ),
      home: const PhoneShell(),
    );
  }
}

class AppColors {
  static const Color black = Color(0xFF0a0a0a);
  static const Color offBlack = Color(0xFF111);
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
];

final List<PaletteData> palettes = [
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
              style: GoogleFonts.syne(
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
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(52),
            border: Border.all(color: const Color(0xFF222), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 140,
                offset: Offset(0, 60),
              ),
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(52),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 12),
                    _buildStatusBar(),
                    Expanded(
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
                                        (f) =>
                                            setState(() => _selectedFilter = f),
                                    onColorTap: _openDetail,
                                    onCameraTap: () => _onTabTapped(2),
                                  ),
                                  const ExploreScreen(),
                                  const PickerScreen(),
                                  const PalettesScreen(),
                                  const SettingsScreen(),
                                ],
                              ),
                    ),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 126,
                      height: 37,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 40),
                          Dot(size: 6),
                          SizedBox(width: 8),
                          Dot(size: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!_showDetail) _buildTabBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: GoogleFonts.syne(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, color: AppColors.white, size: 17),
              const SizedBox(width: 7),
              Icon(Icons.battery_full, color: AppColors.white, size: 17),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 26),
        decoration: const BoxDecoration(
          color: Color(0xF20a0a0a),
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(0, 'Library', Icons.grid_view_rounded),
            _buildTabItem(1, 'Explore', Icons.explore_outlined),
            _buildCamTab(),
            _buildTabItem(3, 'Palettes', Icons.palette_outlined),
            _buildTabItem(4, 'Settings', Icons.settings_outlined),
          ],
        ),
      ),
    );
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
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.white : AppColors.muted2,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.white : AppColors.muted2,
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
      child: Transform.translate(
        offset: const Offset(0, -16),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26ffffff),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final double size;
  const Dot({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        shape: BoxShape.circle,
        border:
            size > 6
                ? Border.all(color: const Color(0xFF0d0d0d), width: 2)
                : null,
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
    return Stack(
      children: [
        Column(
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
                        'Colors',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        'Your Library',
                        style: GoogleFonts.syne(
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
                        () => showToast(context, 'Search colors'),
                      ),
                      _IconBtn(Icons.sort, () => _showSortSheet(context)),
                      _IconBtn(
                        Icons.download,
                        () => showToast(context, 'All colors exported!'),
                      ),
                      _IconBtn(Icons.share, () => _showShareSheet(context)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StatCard('145', 'Colors'),
                  const SizedBox(width: 8),
                  _StatCard('8', 'Palettes'),
                  const SizedBox(width: 8),
                  _StatCard('12', 'Favorites'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isActive = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => onFilterChanged(filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.white : Colors.transparent,
                        border: Border.all(
                          color: isActive ? AppColors.white : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.black : AppColors.muted,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: colorLibrary.length,
                itemBuilder: (context, index) {
                  final color = colorLibrary[index];
                  return _ColorCard(
                    color: color,
                    onTap: () => onColorTap(color),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 90,
          right: 18,
          child: GestureDetector(
            onTap: onCameraTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Color(0x66000000), blurRadius: 24),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortSheet(),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSheet(),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.dark,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              num,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ],
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
    final isLight = color.r > 200 && color.g > 200 && color.b > 200;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.color,
          borderRadius: BorderRadius.circular(14),
          border:
              color.hex == '#0F0F0F'
                  ? Border.all(color: AppColors.border)
                  : null,
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x8C000000)],
                  ),
                ),
                child: Text(
                  color.hex,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: isLight ? Colors.black54 : Colors.white,
                  ),
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
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sort By',
            style: GoogleFonts.syne(
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
            style: GoogleFonts.syne(
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

class _ShareSheet extends StatelessWidget {
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
            'Share',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: const [
              _ShareItem('🔗', 'Copy Link'),
              _ShareItem('🖼️', 'Save Image'),
              _ShareItem('💬', 'Messages'),
              _ShareItem('📸', 'Instagram'),
              _ShareItem('🐦', 'X (Twitter)'),
              _ShareItem('📌', 'Pinterest'),
              _ShareItem('🎨', 'Figma'),
              _ShareItem('⋯', 'More'),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ShareItem extends StatelessWidget {
  final String emoji, label;
  const _ShareItem(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showToast(context, '$label tapped');
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.syne(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
            textAlign: TextAlign.center,
          ),
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
            style: GoogleFonts.syne(
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
            style: GoogleFonts.syne(
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Discover Colors',
                    style: GoogleFonts.syne(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              _IconBtn(
                Icons.search,
                () => showToast(context, 'Search trending'),
              ),
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
              _SectionHeader('Trending Palettes', 'See All →'),
              const SizedBox(height: 10),
              _TrendingRow(),
              const SizedBox(height: 20),
              _SectionHeader('Recent Colors', 'See All →'),
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
                    style: GoogleFonts.playfairDisplay(
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
                      style: GoogleFonts.jetBrainsMono(
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
                      style: GoogleFonts.syne(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '#1C1C1C',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _IconBtn(
                      Icons.favorite_border,
                      () => showToast(context, 'Saved!'),
                    ),
                    const SizedBox(width: 6),
                    _IconBtn(Icons.share, () => _showShareSheet(context)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, action;
  const _SectionHeader(this.title, this.action);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.syne(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        Text(
          action,
          style: GoogleFonts.syne(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
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
          ]),
          _TrendCard('Sunset Fade', '1.8k', [
            const Color(0xFFC0392B),
            const Color(0xFFE67E22),
            const Color(0xFFFBCE50),
          ]),
          _TrendCard('Deep Ocean', '1.4k', [
            const Color(0xFF0d2240),
            const Color(0xFF5386C0),
            const Color(0xFFc2d8f0),
          ]),
          _TrendCard('Botanical', '980', [
            const Color(0xFF505518),
            const Color(0xFF2ECC71),
            const Color(0xFFE1FEE0),
          ]),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String name, count;
  final List<Color> colors;
  const _TrendCard(this.name, this.count, this.colors);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  '$count saves',
                  style: GoogleFonts.syne(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
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
    return Container(
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
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  'Access your colors on your wrist',
                  style: GoogleFonts.syne(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});

  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  String _selectedZoom = '0.5×';
  final List<String> _zoomLevels = ['0.5×', '1×', '2×', '3×'];

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
                    'Picker',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Point & Capture',
                    style: GoogleFonts.syne(
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
                    Icons.flash_on,
                    () => showToast(context, 'Flash toggled'),
                  ),
                  _IconBtn(
                    Icons.grid_3x3,
                    () => showToast(context, 'Grid toggled'),
                  ),
                  _IconBtn(
                    Icons.photo_library,
                    () => showToast(context, 'Photo library opened'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _zoomLevels
                  .map(
                    (z) => GestureDetector(
                      onTap: () => setState(() => _selectedZoom = z),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _selectedZoom == z
                                  ? AppColors.white
                                  : AppColors.dark,
                          border: Border.all(
                            color:
                                _selectedZoom == z
                                    ? AppColors.white
                                    : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          z,
                          style: GoogleFonts.syne(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                _selectedZoom == z
                                    ? AppColors.black
                                    : AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Container(color: const Color(0xFF0a0a0a)),
              Positioned(
                top: 30,
                left: 30,
                child: _AnimatedBlob(180, 180, const Color(0xFF2e2e2e), 0),
              ),
              Positioned(
                bottom: 100,
                right: 20,
                child: _AnimatedBlob(140, 140, const Color(0xFF1a1a1a), 1),
              ),
              Positioned(
                top: 200,
                left: 150,
                child: _AnimatedBlob(100, 100, const Color(0xFF3a3a3a), 2),
              ),
              CustomPaint(painter: _GridPainter(), size: Size.infinite),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                bottom: 16,
                child: Text(
                  'TAP TO LOCK',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    color: Colors.white38,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.offBlack,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c1c1c),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Graphite Black',
                          style: GoogleFonts.syne(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          '#1C1C1C · Auto-detected',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _IconBtn(
                        Icons.edit,
                        () => showToast(context, 'Edit name'),
                      ),
                      _IconBtn(
                        Icons.colorize,
                        () => showToast(context, 'Eyedropper ready'),
                      ),
                      _IconBtn(Icons.share, () => _showShareSheet(context)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _CodePill('HEX', '#1C1C1C'),
                    _CodePill('RGB', '28, 28, 28'),
                    _CodePill('HSB', '0°, 0%, 11%'),
                    _CodePill('CMYK', '0, 0, 0, 89'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _MainButton(
                      'Save to Library',
                      () => showToast(context, 'Saved to Library!'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _GhostButton(
                    '+ Palette',
                    () => showToast(context, 'Added to palette!'),
                  ),
                  const SizedBox(width: 8),
                  _OutlineButton(Icons.info_outline, () {}),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSheet(),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineButton(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 14, color: AppColors.white),
      ),
    );
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.08);
    canvas.drawLine(
      Offset(size.width * 0.33, 0),
      Offset(size.width * 0.33, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CodePill extends StatelessWidget {
  final String tag, value;
  const _CodePill(this.tag, this.value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showToast(context, '$tag copied!', copyText: value),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.dark,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: GoogleFonts.syne(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.muted,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PalettesScreen extends StatelessWidget {
  const PalettesScreen({super.key});

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
                    'Palettes',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Collections',
                    style: GoogleFonts.syne(
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
                  _IconBtn(Icons.search, () {}),
                  _IconBtn(
                    Icons.download,
                    () => showToast(context, 'Import palette'),
                  ),
                  _IconBtn(Icons.share, () => _showShareSheet(context)),
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
                      (f) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              f == 'All' ? AppColors.white : Colors.transparent,
                          border: Border.all(
                            color:
                                f == 'All' ? AppColors.white : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          f,
                          style: GoogleFonts.syne(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                f == 'All' ? AppColors.black : AppColors.muted,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => showToast(context, 'New palette created!'),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppColors.muted, size: 16),
                const SizedBox(width: 8),
                Text(
                  'New Palette',
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: palettes.length,
            itemBuilder: (context, index) {
              final palette = palettes[index];
              return _PaletteCard(palette: palette);
            },
          ),
        ),
      ],
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSheet(),
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final PaletteData palette;
  const _PaletteCard({required this.palette});

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
                  palette.colors
                      .map((c) => Expanded(child: Container(color: c.color)))
                      .toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Text(
                  palette.name,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${palette.colors.length} colors',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
                const Spacer(),
                _IconBtn(
                  Icons.copy,
                  () => showToast(context, '${palette.name} copied!'),
                ),
                const SizedBox(width: 4),
                _IconBtn(Icons.share, () => _showShareSheet(context)),
                const SizedBox(width: 4),
                _IconBtn(
                  Icons.delete_outline,
                  () => showToast(context, '${palette.name} deleted'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSheet(),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'Preferences',
                    style: GoogleFonts.syne(
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
                  trailing: Icon(
                    Icons.chevron_right,
                    color: AppColors.muted2,
                    size: 14,
                  ),
                ),
                _SettingsRow(Icons.visibility, 'Show Names', '', toggle: true),
              ]),
              _SettingsSection('Color Codes', [
                _SettingsRow(
                  Icons.text_fields,
                  'Copy Format',
                  'HEX',
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
                ),
                _SettingsRow(
                  Icons.vibration,
                  'Haptic Feedback',
                  '',
                  toggle: false,
                ),
              ]),
              _SettingsSection('Sync & Backup', [
                _SettingsRow(Icons.cloud, 'iCloud Sync', '', toggle: true),
                _SettingsRow(
                  Icons.sync,
                  'Sync Now',
                  '2 min ago',
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
                style: GoogleFonts.playfairDisplay(
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
                  style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  '145 colors · 8 palettes',
                  style: GoogleFonts.syne(fontSize: 11, color: AppColors.muted),
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
              style: GoogleFonts.syne(
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
          style: GoogleFonts.syne(
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

class _SettingsRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool toggle;
  final bool danger;
  const _SettingsRow(
    this.icon,
    this.label,
    this.value, {
    this.trailing,
    this.toggle = false,
    this.danger = false,
  });

  @override
  State<_SettingsRow> createState() => _SettingsRowState();
}

class _SettingsRowState extends State<_SettingsRow> {
  bool _toggle = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showToast(context, '${widget.label} tapped'),
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
                widget.icon,
                size: 15,
                color: widget.danger ? Colors.redAccent : AppColors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.danger ? Colors.redAccent : AppColors.white,
                ),
              ),
            ),
            if (widget.toggle)
              GestureDetector(
                onTap: () => setState(() => _toggle = !_toggle),
                child: Container(
                  width: 42,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _toggle ? AppColors.offWhite : const Color(0xFF333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Align(
                    alignment:
                        _toggle ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: _toggle ? Colors.black : const Color(0xFF888),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              )
            else if (widget.value != null && widget.value!.isNotEmpty)
              Text(
                widget.value!,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              )
            else
              widget.trailing ?? const SizedBox(),
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
                    _CircleBtn(Icons.favorite_border),
                    _CircleBtn(Icons.edit),
                    _CircleBtn(Icons.share),
                    _CircleBtn(Icons.delete, danger: true),
                  ],
                ),
              ),
              Positioned(
                bottom: 14,
                left: 14,
                child: Text(
                  color.name,
                  style: GoogleFonts.playfairDisplay(
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
                  Expanded(child: _MainButton('Apply Changes', () {})),
                  const SizedBox(width: 8),
                  _GhostButton('Reset', () {}),
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
                  Expanded(child: _MainButton('Share Palette', () {})),
                  const SizedBox(width: 8),
                  _GhostButton('Save', () {}),
                ],
              ),
              const SizedBox(height: 16),
              _SectionTitle('Add to Palette'),
              _PaletteTags(),
              const SizedBox(height: 12),
              _MainButton('Confirm', () {}),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final bool danger;
  const _CircleBtn(this.icon, {this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        style: GoogleFonts.syne(
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
              style: GoogleFonts.syne(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: AppColors.white,
              ),
            ),
            Text(
              'Tap to copy',
              style: GoogleFonts.syne(fontSize: 9, color: AppColors.muted2),
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
              style: GoogleFonts.syne(
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
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
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
              style: GoogleFonts.syne(
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
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  ratio,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
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
              style: GoogleFonts.syne(
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
  @override
  Widget build(BuildContext context) {
    final tags = [
      'Zimmer',
      'Supernova',
      'Ocean Calm',
      'Desert Dusk',
      'Mono Studio',
      '+ New',
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          tags
              .map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: t == 'Zimmer' ? AppColors.white : AppColors.dark,
                    border: Border.all(
                      color: t == 'Zimmer' ? AppColors.white : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    t,
                    style: GoogleFonts.syne(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: t == 'Zimmer' ? AppColors.black : AppColors.muted,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
