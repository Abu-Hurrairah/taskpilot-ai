import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.config import settings
from app.models.schemas import GenerateRequest
from app.planner.local import local_plan

@pytest.fixture
def client(tmp_path, monkeypatch):
    monkeypatch.setattr(settings, "DATABASE_PATH", str(tmp_path / "test.db"))
    return TestClient(app)

def test_health(client):
    assert client.get("/health").json()["status"] == "ok"

@pytest.mark.parametrize("goal", ["Prepare for an AI engineering interview", "Study for an exam", "Build a mobile app", "Apply to jobs", "Start a fitness routine", "Create a video", "Organize my room"])
def test_templates(goal):
    plan = local_plan(GenerateRequest(goal=goal, available_days=3))
    assert len(plan.tasks) >= 3
    assert all(1 <= t.suggested_day <= 3 and t.subtasks and t.estimated_minutes >= 5 for t in plan.tasks)
    assert [t.suggested_day for t in plan.tasks] == sorted(t.suggested_day for t in plan.tasks)

def test_mixed_goal():
    plan = local_plan(GenerateRequest(goal="I need to finish my portfolio, prepare for an interview, apply to jobs, and complete my project this week."))
    assert len(plan.tasks) == 14
    assert any("case studies" in t.title for t in plan.tasks)
    assert any("mock interview" in t.title for t in plan.tasks)

@pytest.mark.parametrize("payload", [{"goal":""}, {"goal":"    "}, {"goal":"?????"}, {"goal":"Valid goal", "available_days":0}, {"goal":"Valid goal", "available_days":31}, {"goal":"x" * 3001}])
def test_invalid(client, payload):
    assert client.post("/api/plans/generate", json=payload).status_code == 422

def test_full_lifecycle(client):
    draft = client.post("/api/plans/generate", json={"goal":"Prepare for an AI engineering interview in 3 days", "available_days":3})
    assert draft.status_code == 200
    assert client.get("/api/plans").json() == [] # generation is a preview
    saved = client.post("/api/plans", json=draft.json())
    assert saved.status_code == 201
    plan = saved.json()
    assert client.get(f"/api/plans/{plan['id']}").status_code == 200
    task_id = plan['tasks'][0]['id']
    assert client.patch(f"/api/tasks/{task_id}", json={"completed":True}).json()["completed"]
    assert client.get(f"/api/plans/{plan['id']}").json()['tasks'][0]['completed']
    assert not client.patch(f"/api/tasks/{task_id}", json={"completed":False}).json()["completed"]
    assert client.delete(f"/api/plans/{plan['id']}").status_code == 204
    assert client.get(f"/api/plans/{plan['id']}").status_code == 404

def test_missing_task(client):
    assert client.patch('/api/tasks/missing', json={"completed":True}).status_code == 404

def test_ollama_fallback(client, monkeypatch):
    monkeypatch.setattr(settings, 'AI_PROVIDER', 'ollama')
    monkeypatch.setattr(settings, 'OLLAMA_URL', 'http://127.0.0.1:1')
    assert client.post('/api/plans/generate', json={"goal":"Build my software project"}).json()['provider'] == 'local'

def test_advanced():
    basic = local_plan(GenerateRequest(goal="Prepare for interview"))
    advanced = local_plan(GenerateRequest(goal="Prepare for interview", advanced=True))
    assert len(basic.tasks[0].subtasks) == 2
    assert len(advanced.tasks[0].subtasks) == 3


def test_save_duplicate_draft_has_unique_task_ids(client):
    draft = client.post('/api/plans/generate', json={"goal":"Build a project"}).json()
    first = client.post('/api/plans', json=draft).json()
    second = client.post('/api/plans', json=draft).json()
    assert first['tasks'][0]['id'] != second['tasks'][0]['id']

def test_invalid_saved_schedule(client):
    draft = client.post('/api/plans/generate', json={"goal":"Prepare for interview", "available_days":3}).json()
    draft['tasks'][0]['suggested_day'] = 4
    assert client.post('/api/plans', json=draft).status_code == 422

def test_local_date_and_source_saved(client):
    draft = client.post('/api/plans/generate', json={"goal":"Build a project"}).json()
    result = client.post('/api/plans', json={**draft, 'source_goal': 'original goal text', 'start_date':'2026-10-01'}).json()
    assert result['start_date'] == '2026-10-01'
    assert result['source_goal'] == 'original goal text'
