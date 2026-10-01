# Verification results

Verified in the build environment on 1 October 2026. Python 3.12, Flutter 3.47.5 stable, Dart 3.13.4. Flutter dependency resolution selected purchases_flutter 10.13.2 under the ^10.10.0 constraint; the committed pubspec.lock records exact resolved versions.

| Check | Result |
|---|---|
| Backend requirements installed | Passed with the versions in requirements.txt |
| Python syntax (`compileall`) | Passed |
| Backend pytest | **22 passed** |
| Uvicorn startup | Passed |
| Live GET /health | 200 |
| Live mixed-goal generation | 200, 14 tasks, local provider |
| Live save | 201 |
| Live task completion | 200, completed=true |
| Live malformed request | 422 |
| Live delete | 204 |
| flutter pub get | Passed |
| flutter analyze | **No issues found** |
| flutter test | **3 passed** |
| Flutter web release build | Passed |
| Actual browser workflow | Generate → save → complete 2/14 → Today → Pro preview passed |
| Browser uncaught runtime errors during final workflow | None |
| Screenshots | Nine real web runtime PNGs captured and visually inspected |
| Native Android APK/emulator | Not verified: Android SDK is absent here |
| Native iOS | Not verified: no macOS/Xcode environment |
| RevenueCat Test Store purchase/restore | SDK implementation present; transaction not verified because no user key was supplied |
| Actual Ollama model inference | Not verified: no model installed |
| Unavailable Ollama fallback | Passed in backend tests |

## Tests included
Backend: health; seven goal categories; mixed-goal decomposition; blank/punctuation/oversize/invalid-day requests; preview vs save semantics; save/get/list/complete/uncomplete/delete lifecycle; missing task; Ollama fallback; basic vs advanced subtask depth; unique task IDs across repeat saves; invalid saved schedule; source-goal/local-date persistence.

Flutter: JSON model/progress calculations; task card metadata, expansion and checkbox callback; free quota gate and distinction between preview state and a RevenueCat entitlement.

## Nonblocking environment warnings
- Python's TestClient reports an upstream AnyIO alias deprecation warning. All tests pass.
- Flutter web build reports a Cupertino icon-family optimization warning from bundled code. The app uses Material icons; inspected screens render their icons correctly, and the release build passes.
- Flutter doctor confirms the Android SDK is absent and its proxy diagnostics cannot enumerate interfaces in this container. These do not prevent the verified web build/tests.
- The first Flutter startup environment probe was blocked by automatic review because it contacted a cloud metadata endpoint. After inspecting Flutter's bot-detector source, verification ran with the standard CI flag, which skips that endpoint. No cloud metadata access is needed or authorized for this project.

## Scope of the evidence
Web UI validation does not prove native billing. The supplied Pro screenshots are **DEMO MODE**, not successful subscription proof. Configure your free RevenueCat Test Store key and follow REVENUECAT_SETUP.md on Android before recording the billing portion of your submission. No deployment, store publication or Devpost submission has been performed.
