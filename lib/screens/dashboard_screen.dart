import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
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
  static const _accentBlue = Color(0xFFe8f0e9); // Using hero bg color as placeholder or just keep original
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: SvgPicture.asset(
          'assets/images/logo-roady.svg',
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text('Roady',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _activeBlue)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black87),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black87),
            onPressed: () => context.push('/shop'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
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
          // Show active page with directional slide animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final isEntering = child.key == ValueKey<int>(_selectedIndex);
              // Calculate offset based on direction and whether entering or exiting
              // If forward: Enter from right (1), Exit to left (-1)
              // If backward: Enter from left (-1), Exit to right (1)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/home'),
        elevation: 4,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.home, color: _activeBlue, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Theorie',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'Oefenvragen',
          ),
          const BottomNavigationBarItem(
            icon: SizedBox.shrink(), // Dummy item
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Examen',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'AI',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _getCurrentColor(),
        unselectedItemColor: Colors.grey[700],
        iconSize: 30,
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
