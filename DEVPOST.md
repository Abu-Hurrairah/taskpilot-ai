# TaskPilot AI — Turn goals into action

## Inspiration
Big goals often arrive as messy thoughts: finish a portfolio, prepare for an interview, apply to jobs, complete a project. The hardest part can be deciding what to do next. I wanted a calm mobile experience that turns those thoughts into practical steps without making a paid AI API a prerequisite.

## What it does
TaskPilot AI takes natural-language goals and creates structured tasks with priorities, effort estimates, subtasks and suggested days. Users preview and save a plan, mark tasks complete, track progress, search tasks and see today's unfinished work. A local planner works without any AI credentials. Optional Ollama enables a local LLM with automatic fallback.

The Pro screen integrates RevenueCat offerings, purchases, restore and the taskpilot_pro entitlement. Free includes three successful plan generations per installation. Pro unlocks unlimited generations, deeper local breakdowns, priority-first planning within a daily time budget and completion insights. When no billing key is configured, an explicitly labelled demo preview lets users inspect Pro features without pretending a purchase happened.

## How we built it
Flutter and Material 3 provide the Android-first interface. A Python FastAPI backend validates requests and planner output with Pydantic, and stores saved plans in SQLite. A provider abstraction separates deterministic planning from optional Ollama inference. Flutter stores settings and a read-only plan cache locally. RevenueCat SDK calls live in a dedicated service and active CustomerInfo entitlements control premium features.

## Challenges we ran into
The main design challenge was keeping planning useful and predictable without depending on a paid model. Category templates, coordinated goal splitting and ordered day allocation provide a dependable baseline. Another challenge was keeping billing demos honest: no-key preview state is deliberately separate from actual RevenueCat transactions and entitlements.

## Accomplishments that we're proud of
A complete goal-to-action workflow, a transparent free planning engine, persistent task progress and an isolated RevenueCat integration. Generation is a preview rather than an automatic save, so users retain control over which plans enter their task list. Optional model failures do not break the core flow.

## What we learned
A useful AI product needs clear next actions, honest capability labels and reliable error handling as much as model output. Entitlements, packages and restore flows are easier to reason about when billing code is isolated from the screen widgets.

## What's next for TaskPilot AI
Independent subtask completion, calendar blocks, reminders, richer templates and secure account-based entitlement enforcement. Production deployment would add authentication, user isolation and server-side quota checks; this submission uses a local demo user.

## Built with
Flutter, Dart, Python, FastAPI, RevenueCat, SQLite, REST API, AI, Mobile, Ollama, LLM (optional).
Add GitHub only after pushing the repository. Add Generative AI only if demonstrating the Ollama mode, since the default planner uses deterministic rules.

## Submission evidence to add
- Your public source repository URL.
- Your actual 2–3 minute demo video URL.
- Runtime screenshots captured from this app.
- Successful RevenueCat Test Store transaction and dashboard evidence after configuring your own free test key.
Do not claim that the no-key Pro preview is a completed RevenueCat purchase.
