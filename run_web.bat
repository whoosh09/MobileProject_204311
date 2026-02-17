@echo off
title Quackle Game (Safe Mode)
echo Updating dependencies...
call flutter pub get
echo ---------------------------------------------------
echo    Starting Quackle on Chrome (Port 5000)
echo    Data will be saved locally.
echo    Don't close this window while playing!
echo ---------------------------------------------------
flutter run -d chrome --web-port=5000
pause