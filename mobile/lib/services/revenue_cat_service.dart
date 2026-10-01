import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/config.dart';

/// All SDK calls live here. Preview is never represented as a purchase/entitlement.
class RevenueCatService extends ChangeNotifier {
  bool ready = false, entitled = false, preview = false, busy = false;
  String? error;
  List<Package> packages = [];
  bool get demoMode =>
      AppConfig.revenueCatKey.isEmpty || !AppConfig.supportedPurchases;
  bool get isPro => entitled || (demoMode && preview);
  String get mode => demoMode
      ? 'DEMO MODE • no purchases'
      : (AppConfig.testKey.isNotEmpty
          ? 'RevenueCat Test Store'
          : 'Store billing • use a sandbox tester');
  void updateInfo(CustomerInfo info) {
    entitled = info.entitlements.all[AppConfig.entitlement]?.isActive ?? false;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (demoMode) {
      notifyListeners();
      return;
    }
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);
      await Purchases.configure(
          PurchasesConfiguration(AppConfig.revenueCatKey));
      ready = true;
      Purchases.addCustomerInfoUpdateListener(updateInfo);
      await refresh();
    } catch (e) {
      error = 'RevenueCat configuration failed: $e';
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!ready) {
      return;
    }
    try {
      error = null;
      updateInfo(await Purchases.getCustomerInfo());
      packages =
          (await Purchases.getOfferings()).current?.availablePackages ?? [];
      if (packages.isEmpty) {
        error =
            'No packages found. Map products to the current offering in RevenueCat.';
      }
    } catch (e) {
      error = 'Unable to load offerings: $e';
    }
    notifyListeners();
  }

  Future<String> purchase(Package package) async {
    if (!ready || demoMode) {
      return 'Purchase unavailable. Demo preview does not charge or create a subscription.';
    }
    busy = true;
    notifyListeners();
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      updateInfo(result.customerInfo);
      return entitled
          ? 'Pro entitlement is active.'
          : 'Transaction returned, but taskpilot_pro is not active. Check product mapping.';
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return 'Purchase cancelled. Your plan is unchanged.';
      }
      return 'Purchase failed: ${e.message}';
    } catch (e) {
      return 'Purchase failed: $e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<String> restore() async {
    if (demoMode) {
      return 'Demo mode has no purchases to restore. Configure a Test Store key first.';
    }
    if (!ready) {
      return 'RevenueCat is not configured. Restart after checking your key.';
    }
    busy = true;
    notifyListeners();
    try {
      updateInfo(await Purchases.restorePurchases());
      return entitled
          ? 'Pro restored.'
          : 'No active Pro entitlement found for this customer.';
    } catch (e) {
      return 'Restore failed: $e';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void setPreview(bool value) {
    if (demoMode) {
      preview = value;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (ready) {
      Purchases.removeCustomerInfoUpdateListener(updateInfo);
    }
    super.dispose();
  }
}
