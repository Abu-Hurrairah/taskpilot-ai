# Architecture

## App flow
Onboarding → dashboard → create goal → generate draft → inspect breakdown → save → tasks/Today → completion progress.

The backend does not save during generation. The extra POST /api/plans makes the Save button meaningful. The mobile sends the original source goal and its local calendar date when saving. Day 1 is that date; Today includes unfinished tasks whose relative day is now due, including overdue work.

## Mobile boundaries
- core/config.dart: compile-time config, free limit and entitlement identifier.
- models/plan.dart: typed JSON models and completion calculations.
- services/api_service.dart: HTTP requests, timeout and backend errors.
- services/revenue_cat_service.dart: SDK lifecycle, offerings, purchase/restore, CustomerInfo updates. Session preview is a separate boolean and never writes an entitlement.
- state/app_state.dart: shared app state, local settings/cache, successful-generation counter and feature gates.
- screens/: user flows and presentation.
- widgets/components.dart: consistent cards, task breakdowns, metrics and empty states.

Material 3 uses the bundled platform font and icons. No paid assets. Widgets are constrained to a readable max width on larger screens. Cached plans are read-only offline. Backend is the source of truth; refresh replaces the cache.

## Backend boundaries
- models/: strict request/output shape, size and enum validation.
- planner/local.py: category detection and ordered task templates.
- services/ai.py: provider Protocol, deterministic provider, optional Ollama provider and fallback.
- database/store.py: parameterized SQLite queries and transactional task updates.
- api/routes.py: generate, save, list/get/delete and task patch.
- config/: dotenv/environment values for local setup.

Plans are stored as validated JSON documents in a SQLite table. This minimizes migration and relationship complexity for a single-user hackathon. Task patches scan plans in one transaction; suitable for small demo data, not large-scale workloads.

## Planning algorithm
Normalize → split action clauses → category match → template decomposition → subtask depth → priority → effort-weighted day allocation → validation.
Each goal's task order is preserved. Splits are capped at eight goals, results at sixty tasks. Estimated effort is a heuristic. Optional Ollama requests schema-constrained JSON; malformed output, out-of-horizon days, network errors and timeouts fall back to rules. Model-generated identifiers and completion flags are replaced.

## Monetization boundary
RevenueCat public SDK key → configure → CustomerInfo → current offerings/packages → purchase(PurchaseParams.package(...)) → updated CustomerInfo → taskpilot_pro check.
Restore is explicitly user-triggered. A CustomerInfo listener updates gates on SDK changes. No key or unsupported platform → labelled no-purchase demo mode. Key errors do not silently turn into a simulated successful purchase.
Pro unlocks the third subtask per local task, unlimited mobile generations, daily budget selection and insights. Priorities are visible on Free; Pro uses them to order Today.

## Deployment boundary
Nothing is deployed. No private API keys, accounts, analytics or paid remote AI. The local API has no authentication or server billing enforcement. A production version needs user isolation, RevenueCat server verification, quotas, HTTPS and backups. See README limitations.
