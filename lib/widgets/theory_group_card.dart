import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../utils/theory_groups.dart';

/// Kaart voor één theorie-groep: icoon, titel, "Start nu"-knop.
/// Web: grotere kaart; mobiel: compact.
class TheoryGroupCard extends StatelessWidget {
  final TheoryGroup group;
  final VoidCallback onStart;

  const TheoryGroupCard({
    super.key,
    required this.group,
    required this.onStart,
  });

  static double get _iconSize => kIsWeb ? 100 : 56;
  static double get _iconInnerSize => kIsWeb ? 52 : 32;
  static double get _titleFontSize => kIsWeb ? 20 : 16;
  static EdgeInsets get _padding =>
      kIsWeb ? const EdgeInsets.all(24) : const EdgeInsets.all(14);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onStart,
        child: Padding(
          padding: _padding,
          child: Column(
            mainAxisSize: kIsWeb ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: _iconSize,
                  color: primaryColor.withValues(alpha: 0.15),
                  child: Center(
                    child: Icon(
                      group.icon,
                      size: _iconInnerSize,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: kIsWeb ? 16 : 12),
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
              if (kIsWeb) const Spacer(),
              SizedBox(height: kIsWeb ? 16 : 12),
              FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: kIsWeb ? 14 : 12),
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: const Text('Start nu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
