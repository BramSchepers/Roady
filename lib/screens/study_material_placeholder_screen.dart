import 'package:flutter/material.dart';

/// Placeholder for Study Material until content exists.
class StudyMaterialPlaceholderScreen extends StatelessWidget {
  const StudyMaterialPlaceholderScreen({super.key});

  static const _primaryBlue = Color(0xFF1A56DB);
  static const _grey = Color(0xFF6B7280);
  static const _lightGrey = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Lesmateriaal',
          style: TextStyle(
            color: _primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 64, color: _lightGrey),
              const SizedBox(height: 24),
              Text(
                'Binnenkort beschikbaar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _grey,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Lesmateriaal komt hier later beschikbaar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _lightGrey,
                    ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Terug'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
