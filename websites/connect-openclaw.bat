@echo off
REM OpenClaw Browser Relay SSH Tunnel
REM This creates an SSH tunnel to the OpenClaw gateway

echo ========================================
echo  OpenClaw Browser Relay Connector
echo ========================================
echo.
echo Connecting to Jack's OpenClaw Gateway...
echo.
echo IMPORTANT: Keep this window open!
echo The tunnel stays active while this window is running.
echo.

REM SSH tunnel command
REM Maps local port 18789 to OpenClaw gateway port 18789 on the VPS
ssh -L 18789:localhost:18789 root@72.62.252.124 -p 22 -N

echo.
echo Tunnel closed.
pause
