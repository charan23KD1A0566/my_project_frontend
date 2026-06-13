#!/usr/bin/env powershell
$API = "https://my-project-80ir.onrender.com/api"

Write-Host "==== QR ATTENDANCE TEST ==== `n" -ForegroundColor Cyan

# Step 1: Get all teachers to find valid teacher ID
Write-Host "[STEP 1] Getting all teachers..." -ForegroundColor Yellow
try {
    $adminResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body (ConvertTo-Json @{email='admin@gmail.com';password='admin123';role='admin'})
    $adminToken = $adminResp.token
    
    $teachers = Invoke-RestMethod -Uri "$API/admin/teachers" -Method GET `
        -Headers @{"Authorization"="Bearer $adminToken"}
    
    Write-Host "✅ Found $($teachers.Count) teachers" -ForegroundColor Green
    if ($teachers.Count -gt 0) {
        $firstTeacher = $teachers[0]
        Write-Host "   First teacher: ID=$($firstTeacher.id), Name=$($firstTeacher.name), Email=$($firstTeacher.email)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Failed to get teachers" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit
}

# Step 2: Teacher login
Write-Host "`n[STEP 2] Teacher login..." -ForegroundColor Yellow
try {
    $teacherResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body (ConvertTo-Json @{email='teacher1@college.com';password='teacher123';role='teacher'})
    $teacherToken = $teacherResp.token
    Write-Host "✅ Teacher logged in" -ForegroundColor Green
} catch {
    Write-Host "❌ Teacher login failed" -ForegroundColor Red
    Write-Host $_.Exception.Message
    exit
}

# Step 3: Generate QR with correct data
Write-Host "`n[STEP 3] Generate QR..." -ForegroundColor Yellow
try {
    $qrResp = Invoke-RestMethod -Uri "$API/teacher/generateQR" -Method POST `
        -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $teacherToken"} `
        -Body (ConvertTo-Json @{
            teacherId = 1
            teacherName = "Dr. CTeacher0"
            subjectId = 1
            qrExpiryTime = 5
            teacherLatitude = 40.7128
            teacherLongitude = -74.0060
        })
    
    Write-Host "✅ QR Generated" -ForegroundColor Green
    Write-Host "   Session ID: $($qrResp.sessionId)" -ForegroundColor Cyan
    Write-Host "   Token: $($qrResp.token.Substring(0,20))..." -ForegroundColor Cyan
    
    $sessionId = $qrResp.sessionId
    $qrToken = $qrResp.token
} catch {
    Write-Host "❌ QR generation failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    # Try to get more error details
    try {
        $webResp = Invoke-WebRequest -Uri "$API/teacher/generateQR" -Method POST `
            -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $teacherToken"} `
            -Body (ConvertTo-Json @{teacherId=1;teacherName="Dr. CTeacher0";subjectId=1;qrExpiryTime=5;teacherLatitude=40.7128;teacherLongitude=-74.0060}) `
            -ErrorAction SilentlyContinue
    } catch {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error Response: $errorBody" -ForegroundColor Magenta
        }
    }
    exit
}

# Step 4: Student login
Write-Host "`n[STEP 4] Student login..." -ForegroundColor Yellow
try {
    $studentResp = Invoke-RestMethod -Uri "$API/auth/login" -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body (ConvertTo-Json @{email='student1@college.com';password='student123';role='student'})
    $studentToken = $studentResp.token
    Write-Host "✅ Student logged in" -ForegroundColor Green
} catch {
    Write-Host "❌ Student login failed" -ForegroundColor Red
    exit
}

# Step 5: Mark attendance
Write-Host "`n[STEP 5] Mark attendance..." -ForegroundColor Yellow
try {
    $attResp = Invoke-RestMethod -Uri "$API/student/mark-attendance" -Method POST `
        -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $studentToken"} `
        -Body (ConvertTo-Json @{
            sessionId = $sessionId
            token = $qrToken
            studentLatitude = 40.7128
            studentLongitude = -74.0060
        })
    
    Write-Host "✅ Attendance marked" -ForegroundColor Green
    Write-Host "   Response: $attResp" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Mark attendance failed" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
    
    # Try to get error details
    try {
        $webResp = Invoke-WebRequest -Uri "$API/student/mark-attendance" -Method POST `
            -Headers @{"Content-Type"="application/json"; "Authorization"="Bearer $studentToken"} `
            -Body (ConvertTo-Json @{sessionId=$sessionId;token=$qrToken;studentLatitude=40.7128;studentLongitude=-74.0060}) `
            -ErrorAction SilentlyContinue
    } catch {
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error Response: $errorBody" -ForegroundColor Magenta
        }
    }
}

# Step 6: Check attendance history
Write-Host "`n[STEP 6] Check attendance history..." -ForegroundColor Yellow
try {
    $histResp = Invoke-RestMethod -Uri "$API/student/attendance-history" -Method GET `
        -Headers @{"Authorization"="Bearer $studentToken"}
    
    Write-Host "✅ Attendance history retrieved" -ForegroundColor Green
    Write-Host "   Records: $($histResp.Count)" -ForegroundColor Cyan
    if ($histResp.Count -gt 0) {
        Write-Host "   Latest: $($histResp[0].subjectName) on $($histResp[0].date)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Failed to get history" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host "`n==== TEST COMPLETE ====" -ForegroundColor Cyan
