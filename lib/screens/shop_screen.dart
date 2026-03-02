import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../services/revenuecat_service.dart';
import '../utils/onboarding_constants.dart';
import '../utils/revenuecat_constants.dart';
import '../widgets/subscription_card.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  bool _isPro = false;
  bool _loading = true;
  String? _error;
  /// Toggle: true = jaar, false = maand (zoals op statische website, standaard jaar).
  bool _isYearlySelected = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadProStatus();
    if (RevenueCatService.isSupported) {
      RevenueCatService.instance.customerInfoUpdates.listen((_) {
        if (mounted) _loadProStatus();
      });
    }
  }

  Future<void> _loadProStatus() async {
    if (!RevenueCatService.isSupported) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }
    try {
      final isPro = await RevenueCatService.instance.hasProEntitlement();
      if (mounted) {
        setState(() {
          _isPro = isPro;
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _presentPaywall() async {
    if (!RevenueCatService.isSupported) return;
    try {
      final result = await RevenueCatUI.presentPaywall();
      if (mounted) {
        if (result == PaywallResult.purchased ||
            result == PaywallResult.restored) {
          _loadProStatus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: $e')),
        );
      }
    }
  }

  /// Koop het geselecteerde abonnement (maand of jaar). Valt terug op paywall als pakket niet gevonden.
  Future<void> _purchaseSelectedPlan() async {
    if (!RevenueCatService.isSupported) return;
    setState(() => _purchasing = true);
    try {
      final package = _isYearlySelected
          ? await RevenueCatService.instance.getYearlyPackage()
          : await RevenueCatService.instance.getMonthlyPackage();
      if (package != null) {
        await RevenueCatService.instance.purchasePackage(package);
        if (mounted) _loadProStatus();
      } else {
        if (mounted) await _presentPaywall();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _presentCustomerCenter() async {
    if (!RevenueCatService.isSupported) return;
    try {
      await RevenueCatUI.presentCustomerCenter();
      if (mounted) _loadProStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideWeb =
        kIsWeb && MediaQuery.sizeOf(context).width >= kNarrowViewportMaxWidth;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Shop',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: isWideWeb
            ? Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: kShopContentMaxWidth),
                  child: _buildShopContent(),
                ),
              )
            : _buildShopContent(),
      ),
    );
  }

  Widget _buildShopContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Kies jouw plan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Upgrade voor meer mogelijkheden',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Toggle Maand / Jaar (zoals op statische website)
        _buildPricingToggle(),
        const SizedBox(height: 16),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        if (RevenueCatService.isSupported) ...[
          if (_loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ))
          else if (_isPro) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Je hebt $entitlementRoadyPro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _presentCustomerCenter,
                      icon: const Icon(Icons.settings),
                      label: const Text('Beheer abonnement'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade800,
                        side: BorderSide(color: Colors.orange.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ]
          else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _purchasing ? null : _purchaseSelectedPlan,
                icon: _purchasing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.workspace_premium),
                label: Text(_purchasing ? 'Bezig…' : 'Upgrade naar Roady Pro'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ]
        else
          const SizedBox(height: 8),
        SubscriptionCard(
          title: 'Basic',
          price: '€0',
          features: const [
            'Alles offline beschikbaar',
            'Geen reclame',
            'Beperkte oefeningen',
          ],
          color: Colors.blue.shade50,
          textColor: Colors.blue.shade900,
          // Basic is alleen “actief” als je nog geen Pro hebt.
          isCurrent: !_isPro,
          // Wanneer Pro actief is, tonen we Basic als gedeactiveerd (gedimd).
          isDimmed: _isPro,
        ),
        const SizedBox(height: 16),
        SubscriptionCard(
          title: 'Pro',
          price: _isYearlySelected ? '€14,99 / jaar (−50%)' : '€4,99 / maand',
          features: const [
            'Onbeperkte examens (meer dan 1000 vragen)',
            'Alle oefeningen',
          ],
          color: Colors.orange.shade50,
          textColor: Colors.orange.shade900,
          isCurrent: _isPro,
          isPopular: true,
        ),
        const SizedBox(height: 16),
        SubscriptionCard(
          title: 'Premium AI',
          price: '--',
          features: const [
            'Alles in Pro',
            'AI Coach ondersteuning',
            'Persoonlijke leerroute'
          ],
          color: Colors.purple.shade50,
          textColor: Colors.purple.shade900,
          isCurrent: false,
          isComingSoon: true,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Toggle 1 Maand | 1 Jaar -50% (zoals op statische website).
  Widget _buildPricingToggle() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '1 Maand',
            style: TextStyle(
              fontSize: 15,
              fontWeight: _isYearlySelected ? FontWeight.w600 : FontWeight.w800,
              color: _isYearlySelected ? Colors.grey : Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _isYearlySelected = !_isYearlySelected),
            child: Container(
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _isYearlySelected ? Colors.orange : Colors.grey.shade300,
                border: Border.all(
                  color: _isYearlySelected ? Colors.orange : Colors.grey,
                ),
              ),
              child: Align(
                alignment: _isYearlySelected ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '1 Jaar ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: _isYearlySelected ? FontWeight.w800 : FontWeight.w600,
              color: _isYearlySelected ? Colors.black87 : Colors.grey,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '-50%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
