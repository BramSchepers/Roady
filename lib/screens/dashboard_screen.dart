import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../models/energy_state.dart';
import '../utils/onboarding_constants.dart';
import 'ai_screen.dart';
import 'exam_screen.dart';
import 'oefenvragen_screen.dart';
import 'theory_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // _selectedIndex is the index of the BottomNavigationBar (0..4)
  late int _selectedIndex;

  // Colors from HomeScreen
  static const _accentBlue = Color(
      0xFFe8f0e9); // Using hero bg color as placeholder or just keep original
  static const _activeBlue = Color(0xFF2563EB);
  static final _tealColor = Colors.teal.shade800;
  static final _orangeColor = Colors.orange.shade800;
  static final _purpleColor = Colors.purple.shade800;

  // Track animation direction
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    // Map logical index (0..3) to visual index (0, 1, 3, 4)
    // 0 -> 0 (Theorie)
    // 1 -> 1 (Oefenvragen)
    // 2 -> 3 (Examen)
    // 3 -> 4 (AI)
    _selectedIndex = _mapLogicalToVisual(widget.initialIndex);
  }

  int _mapLogicalToVisual(int logicalIndex) {
    if (logicalIndex >= 2) return logicalIndex + 1;
    return logicalIndex;
  }

  int _mapVisualToLogical(int visualIndex) {
    if (visualIndex >= 3) return visualIndex - 1;
    return visualIndex;
  }

  static const _heroBg = Color(0xFFe8f0e9);

  // De pagina's die we willen tonen (logical order)
  final List<Widget> _pages = const [
    TheoryScreen(),
    OefenvragenScreen(),
    ExamScreen(),
    AiScreen(),
  ];

  void _onItemTapped(int index) {
    // Prevent selecting the dummy item (index 2)
    if (index == 2) return;

    setState(() {
      _isForward = index > _selectedIndex;
      _selectedIndex = index;
    });
  }

  Color _getCurrentColor() {
    switch (_selectedIndex) {
      case 0:
        return _activeBlue;
      case 1:
        return _tealColor;
      case 3:
        return _orangeColor;
      case 4:
        return _purpleColor;
      default:
        return _activeBlue;
    }
  }

  static const _webNavIconSize = 32.0;
  static const _webNavFontSize = 20.0;
  static const _webNavTextColor = Color(0xFF282828);

  /// Web-only: icoon behoudt kleur (blauw/teal/oranje/paars), tekst altijd _webNavTextColor (#282828).
  Widget _buildWebNavItem(IconData icon, String label, VoidCallback onTap,
      {bool isSelected = false, Color? iconColor}) {
    final iconClr = iconColor ?? _webNavTextColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        icon: Icon(icon, size: _webNavIconSize, color: iconClr),
        label: Text(label,
            style: TextStyle(
                fontSize: _webNavFontSize,
                color: _webNavTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: _webNavTextColor,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  double _webNavSideMargin(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final margin = (width - kWebNavContentMaxWidth) / 2;
    return margin.clamp(24.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final sideMargin = kIsWeb ? _webNavSideMargin(context) : 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: kIsWeb
            ? Padding(
                padding: EdgeInsets.only(left: sideMargin),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: EnergyState().hasUnseenDashboardUpdates,
                      builder: (context, hasUnseen, _) {
                        final logo = InkWell(
                          onTap: () => context.go('/home'),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Image.asset(
                              'assets/images/logo-roady.png',
                              height: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Text('Roady',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _activeBlue)),
                            ),
                          ),
                        );
                        if (!hasUnseen) return logo;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            logo,
                            Positioned(
                              top: 12,
                              right: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: 24),
                    _buildWebNavItem(
                      Icons.menu_book,
                      'Theorie',
                      () => _onItemTapped(0),
                      isSelected: _selectedIndex == 0,
                      iconColor: _activeBlue,
                    ),
                    _buildWebNavItem(
                      Icons.quiz,
                      'Oefenvragen',
                      () => _onItemTapped(1),
                      isSelected: _selectedIndex == 1,
                      iconColor: _tealColor,
                    ),
                    _buildWebNavItem(
                      Icons.school,
                      'Examen',
                      () => _onItemTapped(3),
                      isSelected: _selectedIndex == 3,
                      iconColor: _orangeColor,
                    ),
                    _buildWebNavItem(
                      Icons.smart_toy,
                      'AI',
                      () => _onItemTapped(4),
                      isSelected: _selectedIndex == 4,
                      iconColor: _purpleColor,
                    ),
                  ],
                ),
              )
            : Image.asset(
                'assets/images/logo-roady.png',
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text('Roady',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _activeBlue)),
              ),
        actions: kIsWeb
            ? [
                Padding(
                  padding: EdgeInsets.only(right: sideMargin),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.person,
                            size: _webNavIconSize, color: _webNavTextColor),
                        label: Text('Profiel',
                            style: TextStyle(
                                fontSize: _webNavFontSize,
                                color: _webNavTextColor)),
                        onPressed: () => context.push('/profile'),
                        style: TextButton.styleFrom(
                          foregroundColor: _webNavTextColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.shopping_cart,
                            size: _webNavIconSize, color: _webNavTextColor),
                        label: Text('Shop',
                            style: TextStyle(
                                fontSize: _webNavFontSize,
                                color: _webNavTextColor)),
                        onPressed: () => context.push('/shop'),
                        style: TextButton.styleFrom(
                          foregroundColor: _webNavTextColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.logout,
                            size: _webNavIconSize, color: _webNavTextColor),
                        label: Text('Uitloggen',
                            style: TextStyle(
                                fontSize: _webNavFontSize,
                                color: _webNavTextColor)),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) context.go('/auth?mode=login');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _webNavTextColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.black87),
                  iconSize: 24,
                  onPressed: () => context.push('/profile'),
                ),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.black87),
                  iconSize: 24,
                  onPressed: () => context.push('/shop'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black87),
                  iconSize: 24,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go('/auth?mode=login');
                  },
                ),
              ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: SvgPicture.asset(
                'assets/illustrations/Background_hero.svg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholderBuilder: (_) => const SizedBox.shrink(),
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Show active page: geen slide/shake op web, wel op mobiel
          AnimatedSwitcher(
            duration:
                kIsWeb ? Duration.zero : const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              if (kIsWeb) return child;
              final isEntering = child.key == ValueKey<int>(_selectedIndex);
              final double startX = (_isForward == isEntering) ? 1.0 : -1.0;
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(startX, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _pages[_mapVisualToLogical(_selectedIndex)],
            ),
          ),
        ],
      ),
      floatingActionButton: kIsWeb
          ? null
          : ValueListenableBuilder<bool>(
              valueListenable: EnergyState().hasUnseenDashboardUpdates,
              builder: (context, hasUnseen, _) {
                final fab = FloatingActionButton(
                  onPressed: () => context.go('/home'),
                  elevation: 4,
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: Icon(
                    Icons.home,
                    color: _activeBlue,
                    size: 30,
                  ),
                );
                return Badge(
                  isLabelVisible: hasUnseen,
                  smallSize: 10,
                  backgroundColor: Colors.red,
                  child: fab,
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: kIsWeb
          ? null
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: 'Theorie',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.quiz),
                  label: 'Oefenvragen',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox.shrink(), // Dummy item
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.school),
                  label: 'Examen',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy),
                  label: 'AI',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: _getCurrentColor(),
              unselectedItemColor: Colors.grey[700],
              iconSize: 36.0,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 8,
              showUnselectedLabels: true,
            ),
    );
  }
}
// _DirectionalSlideTransition removed as logic is now inline
