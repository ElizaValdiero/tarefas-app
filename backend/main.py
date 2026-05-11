from fastapi import FastAPI, HTTPException
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from pydantic import BaseModel
import os

DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Task(Base):
    __tablename__ = "tasks"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    status = Column(String, default="a_iniciar")
    
Base.metadata.create_all(bind=engine)

app= FastAPI()
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class TaskSchema(BaseModel):
    title: str
    status: str = "a_iniciar"
    
@app.get("/tasks")
def get_tasks():
    db = SessionLocal()
    tasks = db.query(Task).all()
    db.close()
    return tasks
@app.post("/tasks")
def create_task(task: TaskSchema):
    db = SessionLocal()
    new_task = Task(title=task.title, status=task.status)
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    db.close()
    return new_task
@app.put("/tasks/{task_id}")
def update_task(task_id: int, task: TaskSchema):
    db = SessionLocal()
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Tarefa não encontrada")
    db_task.title = task.title
    db_task.status = task.status
    db.commit()
    db.refresh(db_task)
    db.close()
    return db_task
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):
    db = SessionLocal()
    db_task = db.query(Task).filter(Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Tarefa não encontrada")
    db.delete(db_task)
    db.commit()
    db.close()
    return {"message": "Tarefa deletada"}

        