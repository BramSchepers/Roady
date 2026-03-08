import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../utils/theory_groups.dart';

/// Kaart voor één theorie-groep: icoon, titel, "Start nu"-knop.
/// Toont visuele afronding (badge, groene stijl) wanneer alle lessen van deze categorie voltooid zijn.
/// Web: grotere kaart; mobiel: compact.
class TheoryGroupCard extends StatelessWidget {
  final TheoryGroup group;
  final VoidCallback onStart;
  final int completedCount;
  final int totalCount;

  const TheoryGroupCard({
    super.key,
    required this.group,
    required this.onStart,
    this.completedCount = 0,
    this.totalCount = 0,
  });

  bool get _isComplete => totalCount > 0 && completedCount == totalCount;

  /// Op mobiel: voltooide categorie als compacte rij (minder schermruimte); tik opent nog steeds.
  bool get _useMinimizedCard => !kIsWeb && _isComplete;

  static double get _iconSize => kIsWeb ? 100 : 56;
  static double get _iconInnerSize => kIsWeb ? 52 : 32;
  static double get _titleFontSize => kIsWeb ? 20 : 16;
  static EdgeInsets get _padding =>
      kIsWeb ? const EdgeInsets.all(24) : const EdgeInsets.all(14);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // Mobiel + voltooid: minimale kaart (één rij, weinig hoogte)
    if (_useMinimizedCard) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.shade400, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onStart,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Colors.green.shade50,
                    child: Icon(
                      group.icon,
                      size: 22,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        group.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Voltooid · Tik om te herbekijken',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: _isComplete ? 3 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: _isComplete
            ? BorderSide(color: Colors.green.shade400, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onStart,
          child: Stack(
            children: [
              Padding(
                padding: _padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: _iconSize,
                            color: _isComplete
                                ? Colors.green.shade50
                                : primaryColor.withValues(alpha: 0.15),
                            child: Center(
                              child: Icon(
                                group.icon,
                                size: _iconInnerSize,
                                color: _isComplete
                                    ? Colors.green.shade700
                                    : primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: kIsWeb ? 12 : 8),
                        Text(
                          group.title,
                          style: TextStyle(
                            fontSize: _titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (totalCount > 0 && !_isComplete) ...[
                          SizedBox(height: kIsWeb ? 6 : 4),
                          Text(
                            '$completedCount / $totalCount lessen',
                            style: TextStyle(
                              fontSize: kIsWeb ? 13 : 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: kIsWeb ? 12 : 10),
                      child: FilledButton.icon(
                        onPressed: onStart,
                        style: FilledButton.styleFrom(
                          backgroundColor: _isComplete
                              ? Colors.green.shade600
                              : primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: kIsWeb ? 12 : 10),
                          minimumSize: const Size(double.infinity, 40),
                        ),
                        icon: Icon(
                          _isComplete ? Icons.check_circle : Icons.play_arrow,
                          size: 18,
                        ),
                        label: Text(_isComplete ? 'Voltooid · Bekijk' : 'Start nu'),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isComplete)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Voltooid',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
