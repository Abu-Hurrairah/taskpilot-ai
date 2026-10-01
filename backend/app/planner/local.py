"""Transparent rules, not a claim that a neural model is running."""
import re
from app.models.schemas import GenerateRequest, PlanDraft, Task

# Each template preserves dependency order. Durations are estimates, not predictions.
TEMPLATES = {
 "interview": ("Career", [
  ("Research the role and company", 30, ["Read the job description", "List five required skills", "Write three questions for the interviewer"]),
  ("Prepare interview stories", 45, ["Choose three relevant projects", "Draft STAR answers", "Practice a 60-second introduction"]),
  ("Practice a mock interview", 60, ["Review technical fundamentals", "Answer questions aloud", "Record weak areas and revise"]),
  ("Complete interview preparation", 20, ["Check meeting link or route", "Prepare documents", "Review your notes"])]),
 "study": ("Learning", [
  ("Map the syllabus and weak areas", 25, ["List examinable topics", "Rank confidence by topic", "Gather notes and past papers"]),
  ("Study the highest-priority topics", 60, ["Read one section", "Make concise recall notes", "Explain concepts without looking"]),
  ("Practice exam questions", 60, ["Attempt a timed question set", "Check answers", "Log and fix mistakes"]),
  ("Review with active recall", 30, ["Test weak topics", "Review key formulas", "Prepare the next revision session"])]),
 "portfolio": ("Career", [
  ("Audit your portfolio", 30, ["Choose your strongest projects", "List missing evidence", "Decide what a recruiter should see first"]),
  ("Write project case studies", 60, ["Describe the problem and your role", "Add screenshots and results", "Link source code or a demo"]),
  ("Polish and test your portfolio", 60, ["Check mobile layout", "Fix broken links", "Proofread and prepare a shareable version"])]),
 "project": ("Development", [
  ("Define the project scope", 30, ["Write the core user journey", "Choose three essential features", "Define what done looks like"]),
  ("Build the core project workflow", 90, ["Set up the project", "Implement the main feature", "Connect inputs to outputs"]),
  ("Test and fix the project", 60, ["Test a successful flow", "Test errors and empty states", "Fix the most serious issues"]),
  ("Prepare the project handoff", 45, ["Write setup instructions", "Capture demo evidence", "Rehearse a short walkthrough"])]),
 "applications": ("Career", [
  ("Build a target job shortlist", 30, ["Choose suitable roles", "Check requirements and location", "Save application links"]),
  ("Tailor your CV and applications", 60, ["Match relevant experience", "Adjust the summary", "Proofread each application"]),
  ("Submit and track applications", 45, ["Submit the strongest matches", "Record dates and contacts", "Schedule follow-up reminders"])]),
 "fitness": ("Wellbeing", [
  ("Set a realistic fitness baseline", 20, ["Choose a measurable goal", "Check your available time", "Select a comfortable activity"]),
  ("Complete a manageable workout", 30, ["Warm up gently", "Follow your chosen routine", "Cool down and record how you feel"]),
  ("Review your routine and recovery", 20, ["Plan rest and sleep", "Record progress", "Adjust the next session"])]),
 "content": ("Creative", [
  ("Choose your audience and content angle", 25, ["Define the audience", "Pick one useful message", "Outline a hook and takeaway"]),
  ("Create the first content draft", 60, ["Write or record the draft", "Add supporting visuals", "Check clarity and accuracy"]),
  ("Edit and publish your content", 40, ["Proofread or trim", "Add a title and description", "Publish and note what to improve"])]),
 "general": ("Personal", [
  ("Define the outcome", 20, ["Write a specific success condition", "List constraints", "Choose the smallest useful next step"]),
  ("Complete the first focused work session", 45, ["Gather what you need", "Work without distractions", "Record what remains"]),
  ("Review and finish the outcome", 30, ["Check against your success condition", "Resolve remaining gaps", "Document the next action"])])}

RULES = [
 ("portfolio", r"portfolio|resume website"),
 ("interview", r"interview"),
 ("applications", r"apply|applications|job search|find.*job"),
 ("study", r"study|exam|revision|learn|course|assignment"),
 ("fitness", r"fitness|workout|exercise|running|gym|weight"),
 ("content", r"content|video|blog|article|youtube|post"),
 ("project", r"project|build|software|app|website|code|develop")]

def split_goals(text):
    # Split coordinated action clauses, keeping e.g. 'research and development' intact.
    parts = re.split(r"[,;\n]+|\band\s+(?=(?:I\s+)?(?:prepare|finish|complete|apply|build|study|learn|create|write|start|improve|exercise|review|launch|make)\b)", text, flags=re.I)
    return [p.strip(" .") for p in parts if len(p.strip()) >= 3][:8] or [text]

def local_plan(request: GenerateRequest) -> PlanDraft:
    parts = split_goals(request.goal)
    tasks = []
    for part in parts:
        kind = next((key for key, pattern in RULES if re.search(pattern, part, re.I)), "general")
        category, steps = TEMPLATES[kind]
        label = re.sub(r"^(?:i\s+)?(?:need to|want to|have to)\s+", "", part, flags=re.I)
        label = label[:100]
        for index, (title, minutes, subtasks) in enumerate(steps):
            tasks.append(Task(title=title if kind != "general" else f"{title}: {label[:60]}",
                description=f"Move forward on: {label}.", priority="high" if index == 0 else "medium",
                estimated_minutes=minutes, suggested_day=1, category=category,
                subtasks=subtasks if request.advanced else subtasks[:2]))
    # Spread dependent steps evenly in time, preserving input and template order.
    total = sum(t.estimated_minutes for t in tasks)
    elapsed = 0
    for task in tasks:
        task.suggested_day = min(request.available_days, 1 + int(elapsed / max(total, 1) * request.available_days))
        if task.suggested_day == request.available_days and task.priority != "high":
            task.priority = "low"
        elapsed += task.estimated_minutes
    title = "Your weekly action plan" if len(parts) > 1 else re.sub(r"^(?:i\s+)?(?:need to|want to|have to)\s+", "", request.goal, flags=re.I).capitalize()[:120]
    return PlanDraft(title=title, summary=f"{len(tasks)} practical steps across {request.available_days} days. Start with the high-priority groundwork, then build momentum. Estimated effort: {total // 60}h {total % 60}m. Adjust estimates to your circumstances.",
        tasks=tasks, available_days=request.available_days, provider="local")
