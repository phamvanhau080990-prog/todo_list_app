from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from database import SessionLocal, engine
from models import Todo
from schemas import TodoCreate, TodoUpdate, TodoResponse

import models
from database import Base

Base.metadata.create_all(bind=engine)

app = FastAPI()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def root():
    return {"message": "Todo API Running"}


@app.get("/todos", response_model=list[TodoResponse])
def get_todos(db: Session = Depends(get_db)):
    return (
        db.query(Todo)
        .order_by(Todo.deadline.asc())
        .all()
    )


@app.post("/todos", response_model=TodoResponse)
def create_todo(todo: TodoCreate,
                db: Session = Depends(get_db)):

    new_todo = Todo(
        title=todo.title,
        deadline=todo.deadline
    )

    db.add(new_todo)
    db.commit()
    db.refresh(new_todo)

    return new_todo


@app.put("/todos/{todo_id}", response_model=TodoResponse)
def update_todo(
        todo_id: int,
        todo: TodoUpdate,
        db: Session = Depends(get_db)
):

    db_todo = db.query(Todo).filter(
        Todo.id == todo_id
    ).first()

    if not db_todo:
        raise HTTPException(
            status_code=404,
            detail="Todo not found"
        )

    db_todo.title = todo.title
    db_todo.deadline = todo.deadline
    db_todo.completed = todo.completed

    db.commit()
    db.refresh(db_todo)

    return db_todo


@app.delete("/todos/{todo_id}")
def delete_todo(
        todo_id: int,
        db: Session = Depends(get_db)
):

    db_todo = db.query(Todo).filter(
        Todo.id == todo_id
    ).first()

    if not db_todo:
        raise HTTPException(
            status_code=404,
            detail="Todo not found"
        )

    db.delete(db_todo)
    db.commit()

    return {"message": "Deleted"}