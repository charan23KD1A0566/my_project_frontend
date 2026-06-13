#!/usr/bin/env powershell

$API = "https://my-project-80ir.onrender.com/api"

# Get teacher token
$teacher = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
    -Headers @{"Content-Type"="application/json"} `
    -Body (ConvertTo-Json @{email='teacher1@college.com';password='teacher123';role='teacher'})

$token = $teacher.token

# Try QR generation with error details
Write-Host "Testing QR Generation with error handling..."
try {
    $resp = Invoke-WebRequest -Uri "$API/teacher/generateQR" -Method POST `
        -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $token"} `
        -Body (ConvertTo-Json @{teacherId=1;teacherName="Dr. CTeacher0";subjectId=1;qrExpiryTime=5;teacherLatitude=40.7128;teacherLongitude=-74.0060}) `
        -UseBasicParsing
    Write-Host "✅ Success!"
    Write-Host $resp.Content | ConvertFrom-Json | ConvertTo-Json -Depth 2
} catch {
    Write-Host "❌ Error: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Response Body:"
        Write-Host $errorBody -ForegroundColor Yellow
    }
}
