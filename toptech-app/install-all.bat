@echo off
setlocal

set "APK=build\app\outputs\flutter-apk\app-release.apk"

for /f "skip=1 tokens=1,2" %%A in ('adb devices') do (
    if "%%B"=="device" (
        echo Installing on %%A...
        adb -s %%A install -r "%APK%"
    )
)

pause