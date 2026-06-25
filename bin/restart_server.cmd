@echo off
setlocal
powershell -ExecutionPolicy Bypass -File "%~dp0restart_server.ps1" %*