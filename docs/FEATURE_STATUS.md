# Feature status

## Completed
All requested P0 source flows: app boot/loading/onboarding, dashboard, create goal, FastAPI planner, validated result preview, explicit save, saved tasks, completion toggles, SQLite persistence, RevenueCat service, custom offering-based paywall and README.

P1 and extras: Today, progress, local read-only cache, settings/about, restore implementation, tests, dark mode, task title editing, plan deletion, search/filter and Pro time-budget/insight view. Optional Ollama provider with validated output and automatic fallback. Android and web runners, package lock, custom app icon, actual web screenshots and prebuilt web preview included.

## Requires your free configuration / local check
- RevenueCat account, Test Store key, entitlement attachment and current offering mapping.
- Real Test Store purchase, cancellation and restore verification on Android/iOS.
- Android SDK/device for native build and final mobile screenshot/video recording.
- Optional Ollama installation/model download if you want to demonstrate actual LLM inference.
- Your GitHub repository/video URLs and your final submission through Devpost.

## Not implemented
Authentication, multi-user isolation, server-enforced quotas/entitlements, calendar sync, notifications, task-level deletion, individually checkable subtasks, in-place regeneration, production billing/webhooks, production hosting and store release.

There is no APK included. Native builds were not validated in this environment. Source analysis, Flutter tests and the release web build passed; see TEST_RESULTS.md. Daily personalization is a priority-first fit into a selected time budget, not a learned user model.
