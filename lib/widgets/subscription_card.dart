import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final Color color;
  final Color textColor;
  final bool isCurrent;
  final bool isPopular;
  final bool isComingSoon;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    required this.color,
    required this.textColor,
    this.isCurrent = false,
    this.isPopular = false,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? textColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: textColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          kIsWeb
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isComingSoon ? null : () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isComingSoon
                              ? Colors.grey[300]
                              : (isCurrent ? Colors.grey[200] : textColor),
                          foregroundColor: isComingSoon
                              ? Colors.grey[600]
                              : (isCurrent ? Colors.black : Colors.white),
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[600],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isComingSoon
                              ? 'Coming soon'
                              : (isCurrent ? 'Huidig plan' : 'Kies $title'),
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isComingSoon ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isComingSoon
                          ? Colors.grey[300]
                          : (isCurrent ? Colors.grey[200] : textColor),
                      foregroundColor: isComingSoon
                          ? Colors.grey[600]
                          : (isCurrent ? Colors.black : Colors.white),
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isComingSoon
                          ? 'Coming soon'
                          : (isCurrent ? 'Huidig plan' : 'Kies $title'),
                    ),
                  ),
                ),
        ],
      ),
    );

    return Stack(
      children: [
        Opacity(opacity: isComingSoon ? 0.6 : 1, child: content),
        if (isPopular)
          Positioned(
            top: 0,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Text(
                'Populair',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
