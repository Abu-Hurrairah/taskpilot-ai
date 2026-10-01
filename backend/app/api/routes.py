from uuid import uuid4
from datetime import datetime, timezone, date
from fastapi import APIRouter, HTTPException, Response
from app.models.schemas import GenerateRequest, PlanDraft, SaveRequest, Plan, TaskPatch, Task
from app.services.ai import generate
from app.database import store
router = APIRouter(prefix="/api")

@router.post("/plans/generate", response_model=PlanDraft)
async def generate_plan(request: GenerateRequest):
    return await generate(request)

@router.post("/plans", response_model=Plan, status_code=201)
def save_plan(draft: SaveRequest):
    plan = Plan(**draft.model_dump(), created_at=datetime.now(timezone.utc).isoformat())
    for task in plan.tasks:
        task.id = str(uuid4())
    return store.save(plan)

@router.get("/plans", response_model=list[Plan])
def list_plans():
    return store.all_plans()

@router.get("/plans/{plan_id}", response_model=Plan)
def get_plan(plan_id: str):
    plan = store.get(plan_id)
    if plan is None:
        raise HTTPException(404, "Plan not found")
    return plan

@router.delete("/plans/{plan_id}", status_code=204)
def delete_plan(plan_id: str):
    if not store.delete(plan_id):
        raise HTTPException(404, "Plan not found")
    return Response(status_code=204)

@router.patch("/tasks/{task_id}", response_model=Task)
def patch_task(task_id: str, patch: TaskPatch):
    changes = patch.model_dump(exclude_none=True)
    if not changes:
        raise HTTPException(422, "Provide a task field to update")
    task = store.patch_task(task_id, changes)
    if task is None:
        raise HTTPException(404, "Task not found")
    return task
