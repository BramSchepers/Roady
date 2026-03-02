import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/revenuecat_constants.dart';

/// Central service for RevenueCat: configuration, entitlement checks, customer info.
///
/// Only initializes on iOS/Android (not web). Use [isSupported] before calling
/// purchase/paywall APIs.
class RevenueCatService {
  RevenueCatService._();

  static final RevenueCatService instance = RevenueCatService._();

  /// True when running on a platform where RevenueCat IAP is supported (iOS/Android).
  static bool get isSupported => !kIsWeb;

  bool _initialized = false;

  final _customerInfoController = StreamController<CustomerInfo>.broadcast();

  /// Stream of customer info updates (entitlements, active subscriptions, etc.).
  Stream<CustomerInfo> get customerInfoUpdates => _customerInfoController.stream;

  /// One-time initialization. Call once after Firebase (e.g. in main.dart).
  /// Skips initialization on web.
  Future<void> initialize({String? appUserId}) async {
    if (!isSupported) return;
    if (_initialized) return;

    try {
      await Purchases.setLogLevel(LogLevel.debug);
      final config = PurchasesConfiguration(revenueCatApiKey)
        ..appUserID = appUserId;
      await Purchases.configure(config);
      _initialized = true;

      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfoUpdated(info);
    } catch (e, st) {
      debugPrint('RevenueCat initialize error: $e\n$st');
      rethrow;
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    if (!_customerInfoController.isClosed) {
      _customerInfoController.add(info);
    }
  }

  /// Call when user logs in. Identifies the user in RevenueCat (e.g. Firebase UID).
  Future<void> logIn(String appUserId) async {
    if (!isSupported) return;
    try {
      await Purchases.logIn(appUserId);
    } catch (e, st) {
      debugPrint('RevenueCat logIn error: $e\n$st');
    }
  }

  /// Call when user logs out. Switches back to anonymous ID.
  Future<CustomerInfo?> logOut() async {
    if (!isSupported) return null;
    try {
      return await Purchases.logOut();
    } catch (e, st) {
      debugPrint('RevenueCat logOut error: $e\n$st');
      return null;
    }
  }

  /// Whether the user has the "Roady Pro" entitlement active.
  Future<bool> hasProEntitlement() async {
    if (!isSupported) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementRoadyPro);
    } catch (e) {
      debugPrint('RevenueCat hasProEntitlement error: $e');
      return false;
    }
  }

  /// Current customer info (cached when possible). Use for subscription status, expiry, etc.
  Future<CustomerInfo> getCustomerInfo() async {
    if (!isSupported) {
      throw UnsupportedError('RevenueCat is not supported on this platform');
    }
    return Purchases.getCustomerInfo();
  }

  /// Restore previous purchases. Call from a "Restore" button.
  Future<CustomerInfo> restorePurchases() async {
    if (!isSupported) {
      throw UnsupportedError('RevenueCat is not supported on this platform');
    }
    return Purchases.restorePurchases();
  }

  /// Fetches current offerings (products/packages). Use to build custom UI or pass to paywall.
  Future<Offerings?> getOfferings() async {
    if (!isSupported) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      debugPrint('RevenueCat getOfferings error: $e');
      return null;
    }
  }

  /// Finds the monthly subscription package from the current offering.
  /// Matches by package identifier, packageType, or store product id.
  Future<Package?> getMonthlyPackage() async {
    final offerings = await getOfferings();
    final packages = offerings?.current?.availablePackages;
    if (packages == null || packages.isEmpty) return null;
    for (final p in packages) {
      if (p.identifier == packageIdMonthly) return p;
      if (p.packageType == PackageType.monthly) return p;
      if (p.storeProduct.identifier.toLowerCase().contains('month')) return p;
    }
    return null;
  }

  /// Finds the yearly subscription package from the current offering.
  Future<Package?> getYearlyPackage() async {
    final offerings = await getOfferings();
    final packages = offerings?.current?.availablePackages;
    if (packages == null || packages.isEmpty) return null;
    for (final p in packages) {
      if (p.identifier == packageIdYearly) return p;
      if (p.packageType == PackageType.annual) return p;
      final id = p.storeProduct.identifier.toLowerCase();
      if (id.contains('year') || id.contains('annual')) return p;
    }
    return null;
  }

  /// Purchases the given package (e.g. monthly or yearly). Returns new [CustomerInfo] on success.
  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!isSupported) return null;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return result.customerInfo;
    } catch (e) {
      debugPrint('RevenueCat purchasePackage error: $e');
      rethrow;
    }
  }

  /// Dispose listeners. Call when app is shutting down if needed.
  Future<void> dispose() async {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    await _customerInfoController.close();
  }
}
