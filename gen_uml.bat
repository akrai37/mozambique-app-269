@echo off
set "BASE=C:\Users\gnp20\Documents\GitHub\mozambique_app\lib"
set "TEMP=%BASE%\uml_temp"

REM Clean and create temp folder
rmdir /S /Q "%TEMP%"
mkdir "%TEMP%"

REM Copy MVVM Dart files
xcopy /S /Y "%BASE%\model\*.dart" "%TEMP%\"
xcopy /S /Y "%BASE%\view_model\*.dart" "%TEMP%\"
xcopy /S /Y "%BASE%\view\*.dart" "%TEMP%\"
xcopy /S /Y "%BASE%\services\*.dart" "%TEMP%\" 2>nul

REM Run code_uml (assumes globally installed)
code_uml --from="%TEMP%" --to=console --uml=plantuml