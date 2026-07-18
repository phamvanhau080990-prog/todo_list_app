@echo off
set URL=http://todonote.duckdns.org:8000/todos

for /L %%i in (1,1,1000) do (
    echo Request %%i
    curl -s %URL% > nul
)

echo Hoan thanh 1000 request
pause