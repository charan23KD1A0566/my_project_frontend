@echo off
setlocal enabledelayedexpansion

set BASE_URL=http://localhost:8080/api

REM Get teacher token
echo Getting teacher token...
powershell -Command "Invoke-WebRequest -Uri 'http://localhost:8080/api/auth/login' -Method POST -ContentType 'application/json' -Body '{\"email\":\"teacher1@college.com\",\"password\":\"teacher123\"}' -UseBasicParsing | ConvertFrom-Json | Select-Object -First 1 | ForEach-Object { Write-Host `$_.token }" > token.txt

setlocal disabledelayedexpansion
for /f %%A in (token.txt) do set TEACHER_TOKEN=%%A
endlocal & set "TEACHER_TOKEN=%TEACHER_TOKEN%"

echo Token: %TEACHER_TOKEN:~0,50%...

REM Generate QR
echo Generating QR...
powershell -Command "$headers = @{'Authorization'='Bearer %TEACHER_TOKEN%'}; $req = @{ teacherId=1; teacherName='Dr. CTeacher0'; subjectId=21; year=1; section='A'; department='CS'; teacherLatitude=37.7749; teacherLongitude=-122.4194; qrExpiryTime=600000 } | ConvertTo-Json; Invoke-WebRequest -Uri 'http://localhost:8080/api/teacher/generateQR' -Method POST -Headers `$headers -ContentType 'application/json' -Body `$req -UseBasicParsing | ConvertFrom-Json | Select-Object sessionId, token"
