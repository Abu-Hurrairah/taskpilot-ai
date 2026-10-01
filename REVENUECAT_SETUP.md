# RevenueCat setup — free Test Store first

This app uses `purchases_flutter` ^10.10.0 and a custom Flutter paywall populated from the current offering. It does not require hosted paywall templates or purchases_ui_flutter. Official references checked while building:
- https://www.revenuecat.com/docs/getting-started/installation/flutter
- https://www.revenuecat.com/docs/getting-started/configuring-sdk
- https://www.revenuecat.com/docs/getting-started/making-purchases
- https://www.revenuecat.com/docs/getting-started/restoring-purchases
- https://www.revenuecat.com/docs/test-and-launch/sandbox/test-store

## 1. Create a free project
Create an account at https://app.revenuecat.com and a project named TaskPilot AI. Use the automatically created Test Store, or add a Test Store under the project's apps/providers settings. Test Store avoids Apple/Google account fees and does not charge real money. Do not configure live billing for the hackathon demo.

## 2. Create an entitlement
In Product catalog → Entitlements, create the identifier **taskpilot_pro** exactly. The app checks this identifier, not product IDs.

## 3. Create and attach products
Create Test Store subscription products (or use its generated test products):
- `taskpilot_pro_monthly` — monthly subscription, choose a test price.
- `taskpilot_pro_yearly` — yearly subscription, choose a test price.
Attach both to taskpilot_pro. These are catalog examples, not hardcoded IDs in the app.

## 4. Configure the offering
Create an offering named `default` and make it the **current** offering. Add a monthly package (`$rc_monthly`) mapped to the monthly Test Store product and an annual package (`$rc_annual`) mapped to the annual product. If the dashboard already generated products/packages, ensure they are attached to taskpilot_pro and the current offering. The custom paywall displays every available package returned by `getOfferings().current` and the product's localized price string.

## 5. Copy the public SDK key
Project settings → API keys → select **Test Store public SDK key** (typically `test_...`). Never copy a secret API key into Flutter.
```powershell
cd mobile
Copy-Item config.example.json config.json
```
Edit config.json:
```json
{
  "API_BASE_URL": "http://10.0.2.2:8000",
  "REVENUECAT_TEST_KEY": "YOUR_PUBLIC_TEST_STORE_KEY",
  "REVENUECAT_ANDROID_KEY": "",
  "REVENUECAT_IOS_KEY": ""
}
```
Then **stop and restart** the app (hot reload does not replace compile-time defines):
```powershell
flutter run --dart-define-from-file=config.json
```
Do not commit personal config.json. Public SDK keys are designed for clients, but all personal configuration stays out of this repository.

## 6. Test a purchase on Android
1. Start the backend and app on emulator/device.
2. Open Pro. It should say **RevenueCat Test Store**, not DEMO MODE.
3. Confirm real catalog package titles and prices are visible.
4. Tap a package and choose success in the SDK's Test Store purchase dialog.
5. Confirm `taskpilot_pro` becomes active and Pro gates open.
6. Confirm the test customer/purchase in the RevenueCat dashboard. SDK logs show the anonymous App User ID for locating the customer.
7. Test cancellation and failure outcomes as well. These must not grant Pro.
8. Restart the app and confirm CustomerInfo still reports the entitlement.

Test Store transactions are simulated billing transactions processed by RevenueCat, not actual store charges. No-key preview is different: it does not invoke purchase, create CustomerInfo or appear in the dashboard.

## 7. Restore purchases
After a successful Test Store purchase, close/reopen the same installation, then tap **Restore purchases**. The app calls `Purchases.restorePurchases()` and checks returned CustomerInfo. Confirm “Pro restored.” when active, and an honest no-active-entitlement message otherwise. Do not clear app data for this basic test: the app uses RevenueCat's anonymous identity, and reinstall/cross-device continuity is not promised without an account strategy. Check the Test Store/customer state in the dashboard when testing expiration or resetting a customer.

## 8. Optional Google Play sandbox later
This is not needed for the free demo. A Play developer account may have a registration fee, so use Test Store under the zero-cost constraint. For an existing account: register Android app `com.taskpilot.taskpilot_ai`, create subscriptions/base plans, connect the store in RevenueCat, attach products to the same entitlement, configure offerings, add license testers, distribute through a test track and use the Android public SDK key. Clear REVENUECAT_TEST_KEY to select the platform key. Use authorized sandbox testers; a platform key alone does not make all purchases free.

## Common issues
- No offerings: current offering missing or package/product mapping incorrect.
- Purchase succeeds but Pro stays locked: product not attached to taskpilot_pro.
- DEMO MODE with a key: web/unsupported platform or compile-time config not passed. Use Android/iOS.
- Configuration error: wrong key type, no network or mismatched platform. The UI displays an error and does not fake entitlement.
- Duplicate/in-flight actions: purchase and restore buttons are disabled during SDK operations.
- Android launchMode is singleTop as required for purchase backgrounding.

## Files to show judges
`mobile/lib/services/revenue_cat_service.dart` and `mobile/lib/state/app_state.dart` make the integration and gates easy to explain. No RevenueCat secret keys, receipt-validation service or webhooks are implemented.
