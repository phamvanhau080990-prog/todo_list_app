@echo off

cd /d D:\todo_list_app\todo_backend

venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8000

pause