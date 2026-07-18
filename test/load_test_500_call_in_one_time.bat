@echo off
set URL=http://todonote.duckdns.org:8000/todos

for /L %%i in (1,1,500) do (
    start "" /B curl -s %URL%
)

echo Da gui 100 request dong thoi
pause