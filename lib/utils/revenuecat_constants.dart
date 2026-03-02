/// RevenueCat configuration constants for Roady.
///
/// Dashboard: https://app.revenuecat.com
/// - Create an entitlement "Roady Pro" and attach your products (monthly, yearly).
/// - For production: use separate API keys per platform (Project Settings > API keys).
const String revenueCatApiKey = 'test_edfMsyrbszqcIobMgOioagGchUi';

/// Entitlement identifier for Roady Pro. Must match the entitlement ID in RevenueCat dashboard.
const String entitlementRoadyPro = 'Roady Pro';

/// Product identifiers for your offerings. Configure in RevenueCat dashboard:
/// - Create products "monthly" and "yearly" (or your store product IDs).
/// - Add them to an Offering and attach to entitlement "Roady Pro".
const String productIdMonthly = 'monthly';
const String productIdYearly = 'yearly';

/// Package identifiers in RevenueCat. Often $rc_monthly / $rc_annual, or custom.
/// Used to select the right package when user chooses monthly vs yearly.
const String packageIdMonthly = '\$rc_monthly';
const String packageIdYearly = '\$rc_annual';
