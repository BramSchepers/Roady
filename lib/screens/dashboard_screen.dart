import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // _selectedIndex is the index of the BottomNavigationBar (0..4)
  late int _selectedIndex;

  // Web narrow viewport: hamburger menu (zelfde breakpoint als home)
  bool _webMenuOpen = false;
  static const _webMenuPanelWidth = 300.0;
  late AnimationController _webMenuController;
  late Animation<double> _webMenuAnimation;

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
    _webMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _webMenuAnimation = CurvedAnimation(
      parent: _webMenuController,
      curve: Curves.easeInOut,
    );
    // Map logical index (0..3) to visual index (0, 1, 3, 4)
    // 0 -> 0 (Theorie)
    // 1 -> 1 (Oefenvragen)
    // 2 -> 3 (Examen)
    // 3 -> 4 (AI)
    var index = _mapLogicalToVisual(widget.initialIndex);
    if (FirebaseAuth.instance.currentUser?.isAnonymous == true && index != 0) {
      index = 0;
    }
    _selectedIndex = index;
  }

  @override
  void dispose() {
    _webMenuController.dispose();
    super.dispose();
  }

  void _closeWebMenu() {
    _webMenuController.reverse().then((_) {
      if (mounted) setState(() => _webMenuOpen = false);
    });
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

    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous == true;
    if (isGuest && index != 0) {
      if (index == 1) {
        _showGuestDialog(
          message: 'Maak een account of log in om oefenvragen te gebruiken.',
          buttonLabel: 'Account aanmaken',
          onPressed: () => context.go('/auth'),
        );
      } else if (index == 3 || index == 4) {
        _showGuestDialog(
          message: 'Examen en AI zijn premium functies. Upgrade uw account om door te gaan.',
          buttonLabel: 'Upgrade uw account',
          onPressed: () => context.go('/shop'),
        );
      }
      return;
    }

    setState(() {
      _isForward = index > _selectedIndex;
      _selectedIndex = index;
    });
  }

  void _showGuestDialog({
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account nodig'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPressed();
            },
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
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

  /// Menu-item in het slide-out panel (narrow web).
  Widget _buildWebMenuTile(
    BuildContext context,
    IconData icon,
    String label,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: _webNavIconSize),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: _webNavFontSize,
          color: _webNavTextColor,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildWebMenuOverlay(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: _closeWebMenu,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.black54),
          ),
        ),
        AnimatedBuilder(
          animation: _webMenuAnimation,
          builder: (context, child) {
            return Positioned(
              right: -_webMenuPanelWidth +
                  _webMenuAnimation.value * _webMenuPanelWidth,
              top: 0,
              bottom: 0,
              width: _webMenuPanelWidth,
              child: child!,
            );
          },
          child: Material(
            elevation: 8,
            color: Colors.white,
            child: SafeArea(
              left: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: _webNavTextColor),
                          onPressed: _closeWebMenu,
                        ),
                      ],
                    ),
                  ),
                  _buildWebMenuTile(
                    context,
                    Icons.menu_book,
                    'Theorie',
                    _activeBlue,
                    () {
                      _closeWebMenu();
                      _onItemTapped(0);
                    },
                  ),
                  _buildWebMenuTile(
                    context,
                    Icons.quiz,
                    'Oefenvragen',
                    _tealColor,
                    () {
                      _closeWebMenu();
                      _onItemTapped(1);
                    },
                  ),
                  _buildWebMenuTile(
                    context,
                    Icons.school,
                    'Examen',
                    _orangeColor,
                    () {
                      _closeWebMenu();
                      _onItemTapped(3);
                    },
                  ),
                  _buildWebMenuTile(
                    context,
                    Icons.smart_toy,
                    'AI',
                    _purpleColor,
                    () {
                      _closeWebMenu();
                      _onItemTapped(4);
                    },
                  ),
                  _buildWebMenuTile(
                    context,
                    Icons.person,
                    FirebaseAuth.instance.currentUser?.isAnonymous == true
                        ? 'Account maken'
                        : 'Profiel',
                    _webNavTextColor,
                    () {
                      _closeWebMenu();
                      if (FirebaseAuth.instance.currentUser?.isAnonymous ==
                          true) {
                        context.go('/auth');
                      } else {
                        context.push('/profile');
                      }
                    },
                  ),
                  _buildWebMenuTile(
                    context,
                    Icons.shopping_cart,
                    'Shop',
                    _webNavTextColor,
                    () {
                      _closeWebMenu();
                      context.push('/shop');
                    },
                  ),
                  _buildWebMenuTile(
                    context,
                    Icons.logout,
                    'Uitloggen',
                    _webNavTextColor,
                    () async {
                      _closeWebMenu();
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) context.go('/auth?mode=login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sideMargin = kIsWeb ? _webNavSideMargin(context) : 0.0;
    final width = MediaQuery.sizeOf(context).width;
    final isNarrowWeb = kIsWeb && width < kWebNavBarBreakpoint;

    final scaffold = Scaffold(
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
                    if (!isNarrowWeb) ...[
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
                  child: isNarrowWeb
                      ? IconButton(
                          icon: const Icon(Icons.menu,
                              color: _webNavTextColor, size: 32),
                          onPressed: () {
                            setState(() => _webMenuOpen = true);
                            _webMenuController.forward();
                          },
                          tooltip: 'Menu',
                        )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.person,
                            size: _webNavIconSize, color: _webNavTextColor),
                        label: Text(
                            FirebaseAuth.instance.currentUser?.isAnonymous == true
                                ? 'Account maken'
                                : 'Profiel',
                            style: TextStyle(
                                fontSize: _webNavFontSize,
                                color: _webNavTextColor)),
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
                            context.go('/auth');
                          } else {
                            context.push('/profile');
                          }
                        },
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
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
                      context.go('/auth');
                    } else {
                      context.push('/profile');
                    }
                  },
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
              child: Image.asset(
                'assets/images/background.webp',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (FirebaseAuth.instance.currentUser?.isAnonymous == true)
                Material(
                  color: _activeBlue.withValues(alpha: 0.12),
                  child: SafeArea(
                    bottom: false,
                    child: InkWell(
                      onTap: () => context.go('/auth'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: _activeBlue, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Maak een account om je voortgang te bewaren.',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                              ),
                            ),
                            Text('Account maken', style: TextStyle(fontWeight: FontWeight.w600, color: _activeBlue, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child:
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
              ),
            ],
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

    if (kIsWeb) {
      return Stack(
        children: [
          scaffold,
          if (_webMenuOpen)
            Positioned.fill(
              child: _buildWebMenuOverlay(context),
            ),
        ],
      );
    }
    return scaffold;
  }
}
// _DirectionalSlideTransition removed as logic is now inline
