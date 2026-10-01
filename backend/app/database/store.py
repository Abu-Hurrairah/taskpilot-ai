import json
import sqlite3
from contextlib import contextmanager
from app.config import settings
from app.models.schemas import Plan

@contextmanager
def connection():
    db = sqlite3.connect(settings.DATABASE_PATH, timeout=10)
    try:
        db.execute("CREATE TABLE IF NOT EXISTS plans (id TEXT PRIMARY KEY, payload TEXT NOT NULL)")
        yield db
        db.commit()
    finally:
        db.close()

def save(plan: Plan):
    with connection() as db:
        db.execute("INSERT OR REPLACE INTO plans VALUES (?, ?)", (plan.id, plan.model_dump_json()))
    return plan

def all_plans():
    with connection() as db:
        return [Plan.model_validate_json(row[0]) for row in db.execute("SELECT payload FROM plans ORDER BY rowid DESC")]

def get(plan_id):
    with connection() as db:
        row = db.execute("SELECT payload FROM plans WHERE id = ?", (plan_id,)).fetchone()
        return Plan.model_validate_json(row[0]) if row else None

def delete(plan_id):
    with connection() as db:
        return db.execute("DELETE FROM plans WHERE id = ?", (plan_id,)).rowcount > 0

def patch_task(task_id, changes):
    # Single transaction prevents concurrent task updates from overwriting each other.
    with connection() as db:
        db.execute("BEGIN IMMEDIATE")
        for plan_id, raw in db.execute("SELECT id,payload FROM plans").fetchall():
            plan = Plan.model_validate_json(raw)
            for task in plan.tasks:
                if task.id == task_id:
                    for key, value in changes.items():
                        setattr(task, key, value)
                    db.execute("UPDATE plans SET payload=? WHERE id=?", (plan.model_dump_json(), plan_id))
                    return task
    return None
