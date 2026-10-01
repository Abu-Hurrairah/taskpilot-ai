from datetime import date
from typing import Literal
from uuid import uuid4
from pydantic import BaseModel, Field, field_validator, model_validator

class GenerateRequest(BaseModel):
    goal: str = Field(min_length=5, max_length=3000)
    available_days: int = Field(default=7, ge=1, le=30)
    advanced: bool = False

    @field_validator("goal")
    @classmethod
    def normalize(cls, value):
        value = " ".join(value.split())
        if len(value) < 5 or not any(c.isalnum() for c in value):
            raise ValueError("Please describe a goal in at least 5 characters")
        return value

class Task(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid4()))
    title: str = Field(min_length=1, max_length=200)
    description: str = Field(default="", max_length=1000)
    priority: Literal["high", "medium", "low"]
    estimated_minutes: int = Field(ge=5, le=480)
    suggested_day: int = Field(ge=1, le=30)
    category: str = Field(max_length=60)
    subtasks: list[str] = Field(default_factory=list, max_length=10)
    completed: bool = False

class PlanDraft(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    summary: str = Field(max_length=2000)
    tasks: list[Task] = Field(min_length=1, max_length=60)
    provider: str = "local"
    available_days: int = Field(ge=1, le=30)

    @model_validator(mode="after")
    def valid_schedule(self):
        if any(task.suggested_day > self.available_days for task in self.tasks):
            raise ValueError("Task day exceeds the plan horizon")
        return self

class SaveRequest(PlanDraft):
    source_goal: str = Field(default="", max_length=3000)
    start_date: date = Field(default_factory=date.today)

class Plan(PlanDraft):
    id: str = Field(default_factory=lambda: str(uuid4()))
    created_at: str
    start_date: date
    source_goal: str

class TaskPatch(BaseModel):
    completed: bool | None = None
    title: str | None = Field(default=None, min_length=1, max_length=200)
    priority: Literal["high", "medium", "low"] | None = None
    @field_validator("title")
    @classmethod
    def title_not_blank(cls, value):
        if value is not None and not value.strip():
            raise ValueError("Title cannot be blank")
        return value.strip() if value else value
