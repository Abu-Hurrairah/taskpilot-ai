# TaskPilot AI — 2–3 minute demo

Before recording: backend running, Android app open, free generations available (fresh emulator installation if needed), RevenueCat Test Store key configured and packages visible. Use a real Test Store transaction if available. If billing is not configured, explicitly say “This is no-purchase demo preview; the real integration still needs my test key.” Do not call preview a purchase.

## 0:00–0:20 — Introduction and problem
“Hi, I'm Abu Hurrairah and this is TaskPilot AI. When I have a portfolio, interview, applications and a project all competing for attention, a long to-do list doesn't tell me where to start. TaskPilot turns those messy goals into a practical next-step plan.”

Show onboarding briefly, then dashboard: “Turn goals into action.”

## 0:20–0:55 — Generate
Tap Create a plan → Use the demo goal, or type:
“I need to finish my portfolio, prepare for an interview, apply to jobs, and complete my project this week.”
Keep seven days → Generate my plan.
“Planning works for free through a local Python rules-and-templates provider. Optional Ollama adds a local open-source model; if it is unavailable, the app falls back automatically.”

## 0:55–1:25 — Inspect and save
Scroll the generated plan. Expand a task's subtasks. Point to priority, estimated minutes and suggested day.
“Instead of one vague goal, I have concrete steps: audit the portfolio, write case studies, prepare interview stories and submit applications. Estimates are suggestions, not guaranteed durations.”
Tap Save this plan.

## 1:25–1:50 — Progress and Today
Open Tasks. Complete one or two tasks. Show progress. Open Today.
“Saved plans persist in SQLite. Today's view includes due and unfinished work. I can track progress, edit task titles, or find tasks with search and filters.”

## 1:50–2:30 — RevenueCat
Open Pro. Show the RevenueCat Test Store label, package price and purchase flow. Choose the Test Store success outcome; point to Pro active. Tap Restore purchases if time permits.
“This custom paywall loads packages from RevenueCat. Pro unlocks only when CustomerInfo reports the taskpilot_pro entitlement. Free includes three generations. Pro adds unlimited generations, a deeper breakdown, priority-first selection within my daily time budget and completion insights.”
Show Today budget slider briefly.
Alternative without credentials: show DEMO MODE and say “This button previews Pro features without billing. It does not create a RevenueCat entitlement. The actual purchase and restore calls are isolated in RevenueCatService, ready for my Test Store configuration.”

## 2:30–2:45 — Close
“TaskPilot AI helps users move from 'I need to do this' to 'here is exactly what I should do next.'”

## Recording tips
Record Android Studio emulator or the physical phone screen. Keep notification text hidden. Use Windows Xbox Game Bar or a free screen recorder. Keep SDK keys and dashboard personal information off-screen. Upload video yourself and add its link to Devpost. Do not spend the deadline on video effects.
